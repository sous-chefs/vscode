property :extension_name, String, name_property: true
property :user,           String, required: true
property :home_dir,       String, default: lazy { ::File.expand_path("~#{user}") }

include Vscode::Helper

unified_mode true

# https://github.com/chef/mixlib-shellout for how to use usernames in shell_out.

action :install do
  if code_package_installed?(new_resource.extension_name, new_resource.user, new_resource.home_dir)
    converge_required = code_upgrade_package(
      new_resource.extension_name,
      new_resource.user,
      new_resource.home_dir
    )
    if converge_required
      # Mark as converged,
      # but do nothing as code_upgrade_package did the converge
      converge_by("Upgrading #{new_resource.extension_name} for
        #{new_resource.user}") do
      end
    end
  else
    converge_by("Installing #{new_resource.extension_name} for
      #{new_resource.user}") do
      code_install_package(
        new_resource.extension_name,
        new_resource.user,
        new_resource.home_dir
      )
    end
  end
end

action :uninstall do
  if code_package_installed?(new_resource.extension_name, new_resource.user)
    converge_by("Uninstalling #{new_resource.extension_name}
      for #{new_resource.user}") do
      code_uninstall_package(
        new_resource.extension_name,
        new_resource.user,
        new_resource.home_dir
      )
    end
  end
end
