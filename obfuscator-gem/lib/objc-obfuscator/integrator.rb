require 'thor'
require 'xcodeproj'

module Objc_Obfuscator
  module Integrator
    def integrate_xcode(encryption_key, project_path, podfile_path, target_name)
      project = Xcodeproj::Project.open project_path

      main_target = project.targets.first

      unless target_name.empty?
        main_target = project.targets.select { |a| (a.name == target_name) }.first
      end

      raise Thor::Error, 'Cannot find the specified target' unless main_target

      phase_obf = project.new('PBXShellScriptBuildPhase')
      phase_obf.name = "Obfuscate strings"
      phase_obf.shell_path = '/bin/bash'
      phase_obf.shell_script = <<-SCRIPT
      if [ -f "$HOME/.rvm/scripts/rvm" ];
      then
        source $HOME/.rvm/scripts/rvm
        rvm rvmrc trust
        rvm rvmrc load
      fi
      find ${SRCROOT} -name "*.h" -exec objc-obfuscator obfuscate #{encryption_key} {} \\;
      find ${SRCROOT} -name "*.m" -exec objc-obfuscator obfuscate #{encryption_key} {} \\;
      SCRIPT

      phase_unobf = project.new('PBXShellScriptBuildPhase')
      phase_unobf.name = "Unobfuscate strings"
      phase_unobf.shell_path = '/bin/bash'
      phase_unobf.shell_script = <<-SCRIPT
      find ${SRCROOT} -name "*.bak" -exec bash -c 'mv -f "$1" "${1%.bak}"' _ {} \\;
      SCRIPT

      build_source_phase_idx = main_target.build_phases.index main_target.source_build_phase
      obf_phase_idx = build_source_phase_idx

      main_target.build_phases.insert obf_phase_idx, phase_obf

      phase_unobf_idx = build_source_phase_idx+2
      if(phase_unobf_idx >= main_target.build_phases.size)
        main_target.build_phases << phase_unobf 
      else
         main_target.build_phases.insert phase_unobf_idx, phase_unobf
      end

      project.save

      if File.readlines(podfile_path).grep(/objc_obfuscator/).size == 0
        File.open(podfile_path, 'a') {|f| f.write('pod "FWTObfuscator"') }
      end

      say_status :info, 'The project has been correctly update. Please run "pod install" to install the required pods', :blue
    end
  end
end
