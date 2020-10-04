#
# Cookbook:: lamp
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.


apt_update 'Update the apt cache daily' do
    frequency 86_400
    action :periodic
end

execute "update-upgrade" do
    command "apt-get update && apt-get upgrade -y"
    action :run
end


package 'git'
package 'tree'
package 'curl'

include_recipe 'lamp::apache'
include_recipe 'lamp::mysql'
include_recipe 'lamp::php'
include_recipe 'lamp::phpmyadmin'
