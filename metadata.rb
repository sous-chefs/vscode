name              'sc_vscode'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Installs and manages Visual Studio Code Extensions'
source_url        'https://github.com/sous-chefs/vscode'
issues_url        'https://github.com/sous-chefs/vscode/issues'
chef_version      '>= 15.3'
version           '1.0.6'

%w(ubuntu redhat centos fedora).each do |os|
  supports os
end
