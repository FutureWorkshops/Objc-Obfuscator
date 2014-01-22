require 'fileutils'

def encrypt(unencrypted_string)
  "2353y54HRTHRTRHTR#34t34tRTH"
end


source_file_path = ARGV[0]
temp_file_path = "#{source_file_path}.tmp"
abort "FATAL: File #{source_file_path} not found!" unless File.exist? source_file_path
File.delete(temp_file_path) if File.exist?(temp_file_path)

source_file = File.open(source_file_path, 'r')
dest_file = File.open(temp_file_path, 'w')

while !source_file.eof? 
  line = source_file.readline
  if line.include? "__obfuscated" 
    unencrypted_string = line.scan(/@"(.*)"\s*;/).last.first
    if unencrypted_string.empty? 
      puts "ERROR: Found occurence of __obfuscated string but can't replace!!!"
    else
      puts "INFO:  Found occurence of __obfuscated string: '#{unencrypted_string}'. Replacing.."
    end
    encrypted = encrypt(unencrypted_string)
    line = line.gsub(unencrypted_string, encrypted)
  end
  dest_file.puts line
end
source_file.close
dest_file.close

FileUtils.mv source_file_path "#{source_file_path}.bak"
FileUtils.mv temp_file_path source_file_path


