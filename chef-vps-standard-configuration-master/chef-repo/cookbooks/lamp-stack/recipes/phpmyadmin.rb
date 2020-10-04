
# Cookbook:: lamp-stack
# Recipe:: phpmyadmin
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#


package "phpmyadmin" do
    action :install
end

execute "link_in_www" do
  #command "sudo ln -s /usr/share/phpmyadmin/ /var/www/phpmyadmin"
  command "sudo ln -s /usr/share/phpmyadmin/ /var/www/html"
  user "root"
  not_if { ::File.exist?('/var/www/html/phpmyadmin') }
end



template '/etc/phpmyadmin/config.inc.php' do
    source 'phpmyadmin_config.erb'
    action :create
end
