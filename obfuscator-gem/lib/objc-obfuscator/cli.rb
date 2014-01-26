require 'thor'
require 'objc-obfuscator/obfuscator'
require 'objc-obfuscator/integrator'


module Objc_Obfuscator
  class CLI < Thor

    include Objc_Obfuscator::Obfuscator
    include Objc_Obfuscator::Integrator
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
      
      raise Thor::Error, 'A valid key and file must be provided' if key.empty? || file_paths.empty?

      file_paths.each do |file_path| 
        unless File.exist? file_path
          say_status :warning, "File #{file_path} not found!", :yellow
        else
          Dir.mktmpdir { |tmp_dir| obfuscate_file file_path, tmp_dir, key, options[:backup] }
        end
      end
    end

    desc 'integrate [ENCRYPTION_KEY] [PROJECT_FILE]', "Integrate Objc Obfuscator with the Xcode project PROJECT_FILE."
    long_desc <<-LONGDESC
      Obfuscate build phases will be added to the Xcode project and a Podfile augmented with
      the required library to decode such strings. It requires a valid cocoapods project.
      The strings will be obfuscated using ENCRYPTION_KEY as the obfuscation key.
    LONGDESC
    option :podfile,
           :type => :string,
           :default => '',
           :desc => 'Path for the Podfile. Default: same as the project file'
    option :target,
           :type => :string,
           :default => '',
           :desc => 'Xcode project containing the "compile source" build phase. Default: the first target on the list.'
    def integrate(encryption_key, project_path)
      raise Thor::Error, 'A valid project file should be specified' unless File.exist?(project_path)

      podfile_path = File.join File.dirname(project_path), './Podfile'
      unless options[:podfile].empty? 
        podfile_path = options[:podfile]
      end
      raise Thor::Error, 'The project must be using cocoapods' unless File.exist?(podfile_path)

      integrate_xcode encryption_key, project_path, podfile_path, options[:target]

    end

  end
end
