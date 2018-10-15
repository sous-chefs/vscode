#
# Author:: Jason Field
# Cookbook:: vscode
# Library:: vscode_helper
#
# Copyright:: 2018, Sous-Chefs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/mixin/shell_out'

module Vscode
  # helper functions for vscode
  module Helper
    include Chef::Mixin::ShellOut

    def code_installer_name
      case node['os']
      when 'linux'
        'code'
      else
        'vscode'
      end
    end

    def interpreter
      'code'
    end

    def code_command(command, user)
      cmd = Mixlib::ShellOut.new(
        "export HOME=/home/#{user} && #{interpreter} #{command}",
        user: user
      )
      cmdres = cmd.run_command
      raise("Error in #{interpreter} #{command} for #{user}") if cmdres.error!
      cmdres
    end

    def code_installed_packages(user)
      cmdres = code_command('--list-extensions --show-versions', user)
      extensions = cmdres.stdout.split("\n")
      result = {}
      extensions.each do |e|
        info = e.split('@')
        name = info[0].downcase
        version = info[1]
        result[name] = version
      end
      result
    rescue
      nil
    end

    def code_package_installed?(package, user)
      extensions = code_installed_packages(user)
      if extensions[package.downcase]
        true
      else
        false
      end
    rescue
      nil
    end

    def code_install_package(package, user)
      installed = code_package_installed?(package, user)
      if installed
        Chef::Log.info("Nothing to do, extension #{package} installed")
      else
        cmdres = code_command("--install-extension #{package}", user)
        Chef::Log.info("#{package} installed") if cmdres.stdout.include?(
          'successfully installed'
        )
        raise("Error installing extension: #{package} for #{user}")
      end
    end

    def code_uninstall_package(package, user)
      installed = code_package_installed?(package, user)
      if installed
        cmdres = code_command("--uninstall-extension #{package}", user)
        Chef::Log.info("#{package} uninstalled") if cmdres.stdout.include?(
          'successfully uninstalled'
        )
        raise("Error uninstalling extension: #{package}")
      else
        Chef::Log.info("Nothing to do, #{package} not installed")
      end
    end

    def code_upgrade_package(package, user)
      # We are unable to upgrade the package directly at the moment
      # See: https://github.com/Microsoft/vscode/issues/45072
      # and https://github.com/Microsoft/vscode/issues/56578
      # for now we will uninstall and reinstall and check version numbers
      packages = code_installed_packages(user)
      package = package.downcase
      if packages[package]
        previous_version = packages[package]
        code_uninstall_package(package, user)
        code_install_package(package, user)
        packages = code_installed_packages(user)
        new_version = packages[package]
        if previous_version == new_version
          # packages match so we want to show as no converge
          nil
        else
          Chef::Log.info("#{package} upgraded")
          true
        end
      else
        Chef::Log.info("#{package} not installed, will no upgrade")
      end
    end
  end
end
