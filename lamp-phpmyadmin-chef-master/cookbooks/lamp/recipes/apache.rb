
# Cookbook:: lamp
# Recipe:: apache
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#
package "apache2" do
    action :install
end

service "apache2" do
    action [:enable, :start]
end


#Virtual Hosts Files
domains_data_bag = admins = data_bag('apache_domains')
domains_data_bag.each do |virtual_hosts|
  site_data = data_bag_item("apache_domains",virtual_hosts)
  site_name = site_data["id"]
  apache_log_root = "/var/www/#{site_name}/logs"
  document_root = "/var/www/#{site_name}/public_html"

  template "/etc/apache2/sites-available/#{site_name}.conf" do
    source "virtualhosts.erb"
    mode "0644"
    variables(
      :apache_log_root => apache_log_root,
      :document_root => document_root,
      :port => site_data["port"],
      :serveradmin => site_data["serveradmin"],
      :servername => site_data["domain"],
    )
  end

  directory document_root do
    mode "0755"
    recursive true
  end

  directory apache_log_root do
    mode "777"
    recursive true
  end

  template "#{document_root}/index.html" do
    source "index.html.erb"
    mode "0644"
    variables(
      :site_name => site_name,
      :port => site_data["port"]
    )
  end

  execute "activate site" do
    command "a2ensite #{site_name}.conf"
    notifies :restart, "service[apache2]"
  end

end
# end virtualhosts
