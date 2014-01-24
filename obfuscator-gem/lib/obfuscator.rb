require 'thor'

require 'fileutils'
require 'tmpdir'
require 'objc-obfuscator/stringencryptor'

module Objc_Obfuscator
  class Obfuscator < Thor
    include Thor::Actions

    desc 'obfuscate [ENCRYPTION_KEY] [FILE_NAMES]', "Obfuscate one or more files using a string as the encryption key."
    long_desc <<-LONGDESC
      The app will scan the files for an occurence of an NSString with the keyword
      '__obfuscated' and replace the character of the string with the base64 encoding
      of the the encrypted string using AES256-cbc and the encryption string specified 
      as a parameter.
    LONGDESC
    option :backup,
           :type => :boolean,
           :default => true,
           :desc => 'Saves the original files as a .bak file'
    def obfuscate(key, *file_paths)
      raise Thor::Error, 'A valid key should be specified' if key.empty?

      file_path.each do |file_path| 
        unless File.exist? file_path
          say_status :warning, "File #{file_path} not found!", :yellow
        else
          Dir.mktmpdir { |tmp_dir| obfuscate_file file_path, tmp_dir, key, backup }
        end
      end
    end

    private
    def obfuscate_file(filepath, tmp_dir, key, backup=true)
      keyword = '__obfuscated'
      objc_string_regex = /@"(.*)"\s*;/

      encryptor = Objc_Obfuscator::StringEncryptor.new key

      source_file_path = filepath
      temp_file_path = File.join tmp_dir, "#{source_file_path}.bak"
      
      File.delete(temp_file_path) if File.exist?(temp_file_path)
      
      source_file = File.open(source_file_path, 'r')
      dest_file = File.open(temp_file_path, 'w')

      while !source_file.eof? 
        line = source_file.readline
        if line.include? keyword 
          unencrypted_string = line.scan(objc_string_regex).last.first
          if unencrypted_string.empty?
            say_status :warning, "Found an occurrence of #{keyword} but there's no obj-string there: \"#{line}\""
          else
            say_status :info, "File: #{source_file_path} - Found occurrence of __obfuscated string: '#{unencrypted_string}'."
            encrypted_string = encryptor.encrypt unencrypted_string 
            line.slice! keyword # remove keyword
            line = line.gsub(unencrypted_string, encrypted_string) # replace the unencrypted with the encrypted
          end
        end
        dest_file.puts line
      end
      source_file.close
      dest_file.close

      if backup
        FileUtils.mv source_file_path, "#{source_file_path}.bak"
      else
        File.delete source_file_path
      end
      FileUtils.mv temp_file_path, source_file_path
    end
  end
end

