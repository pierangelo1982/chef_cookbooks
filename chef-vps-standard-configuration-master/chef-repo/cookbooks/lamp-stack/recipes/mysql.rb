#
# Cookbook:: lamp-stack
# Recipe:: mysql
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Load MySQL passwords from the 'passwords' data bag.
passwords = data_bag_item('passwords', 'mysql')

# Configure the MySQL client.
mysql_client 'default' do
  action :create
end

mysql_service 'default' do
  version '5.5'
  bind_address '0.0.0.0'
  port '3306'
  data_dir '/data'
  initial_root_password passwords['root_password']
  action [:create, :start]
end


#template '/etc/mysql-default/my.cnf' do
#  source 'my.cnf.erb'
#end
#  action :create
