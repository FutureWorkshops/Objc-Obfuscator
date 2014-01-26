require 'thor'


module Objc_Obfuscator
  module Obfuscator
    def obfuscate_file(filepath, tmp_dir, key, backup=true)
      keyword = '__obfuscated'
      objc_string_regex = /@"(.*)"\s*;/

      encryptor = Objc_Obfuscator::StringEncryptor.new key

      source_file_path = filepath
      temp_file_path = File.join tmp_dir, "#{File.basename(source_file_path)}.bak"
      
      File.delete(temp_file_path) if File.exist?(temp_file_path)
      
      source_file = File.open(source_file_path, 'r')
      dest_file = File.open(temp_file_path, 'w')

      file_changed = false
      say_status :info, "Processing file: #{source_file_path}", :blue
      while !source_file.eof? 
        line = source_file.readline
        if line.include? keyword 
          unencrypted_string = line.scan(objc_string_regex).last.first
          if unencrypted_string.empty?
            say_status :warning, "Found an occurrence of #{keyword} but there's no obj-string there: \"#{line}\""
          else
            say_status :info, "Found occurrence of __obfuscated string: '#{unencrypted_string}'."
            encrypted_string = encryptor.encrypt unencrypted_string 
            line.slice! keyword # remove keyword
            line = line.gsub("@\"#{unencrypted_string}\"", "[@\"#{encrypted_string}\" unobfuscatedString]") # replace the unencrypted with the encrypted
            file_changed = true
          end
        end
        dest_file.puts line
      end
      source_file.close
      dest_file.close

      if file_changed
        if backup
          FileUtils.mv source_file_path, "#{source_file_path}.bak"
        else
          File.delete source_file_path
        end
        FileUtils.mv temp_file_path, source_file_path
      end
    end

  end
end
