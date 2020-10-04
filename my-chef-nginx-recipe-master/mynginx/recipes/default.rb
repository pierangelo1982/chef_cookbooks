#
# Cookbook Name:: mynginx
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

package 'git'
package 'tree'

package 'nginx' do
  action :install
end


service 'nginx' do
  action [ :enable, :start ]
end


cookbook_file "/var/www/html/index.html" do
  source "index.html"
  mode "0644"
end

template "/etc/nginx/nginx.conf" do
   source "nginx.conf.erb"
   notifies :reload, "service[nginx]"
end
