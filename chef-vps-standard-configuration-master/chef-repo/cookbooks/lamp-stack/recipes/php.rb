#
# Cookbook:: lamp-stack
# Recipe:: php
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#
#
# update the main pear channel


# install php5.
package "php5" do
    action :install
end

package "php-pear" do
    action :install
end


# Install php5-mysql.
package 'php5-mysql' do
    action :install
    notifies :restart, "service[apache2]"
end

