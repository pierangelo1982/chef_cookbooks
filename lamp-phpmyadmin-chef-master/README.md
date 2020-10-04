### install chefdk
```
curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c stable
```

### Create the cookbook in your chef-repo
Create a folder named cookbooks if not exist already in your chef-repo

Generate a cookbook named lamp
```
chef generate cookbook cookbooks/lamp

```
### create the recipes
PhpMyAdmin have need of an Apache or NGINIX (in our case APACHE) web server, a mysql database and php.

In /cookbooks/lamp generate 4 recipes, named apache, mysql, php and phpmyadmin:
```
chef generate recipe apache
```
```
chef generate recipe mysql
```
```
chef generate recipe php
```
```
chef generate recipe phpmyadmin
```

Now in your recipes folder should appear 5 file:
* default.rb
* apache.rb
* mysql.rb
* php.rb
* phpmyadmin.rb

In default.rb we put useful standard tools (git etc...) and the command apt-get update for keep updated our package manager:

default.rb
```
apt_update 'Update the apt cache daily' do
    frequency 86_400
    action :periodic
end


package 'git'
package 'tree'
package 'curl'
```

### APACHE:
Rdit apache.rb
```
package "apache2" do
    action :install
end


service "apache2" do
    action [:enable, :start]
end
```

### mysql:
Edit mysql.rb
```
# Configure the MySQL client.
mysql_client 'default' do
  action :create
end

mysql_service 'default' do
  version '5.5'
  bind_address '0.0.0.0'
  port '3306'
  data_dir '/data'
  initial_root_password "password123"
  action [:create, :start]
end
```
### Create a data_bags for store mysql password:
In root folder of the chef-repo create a folder named data_bags, with inside another folder named passwords
```
mkdir data_bags

mkdir data_bags/passwords
```
inside passwords folder create a json file named mysql.json

mysql.json
```
{
    "id": "mysql",
    "root_password": "mypassword"
}
```

in metadata.rb, in the lamp cookbooks folder add this:
```
depends 'mysql', '~> 8.5.1'
```

### PHP
Now we must install php library

Edit php.rb in recipes folder:
```
# install php.
package "php" do
    action :install
end

package "php-pear" do
    action :install
end

package 'libapache2-mod-php' do
  action :install
  notifies :restart, "service[apache2]"
end


# Install php-mysql.
package 'php-mysql' do
    action :install
    notifies :restart, "service[apache2]"
end
```

### PhpMyAdmin
Edit phpmyadmin.rb in recipes folder:
```
package "phpmyadmin" do
    action :install
end

execute "link_in_www" do
  command "sudo ln -s /usr/share/phpmyadmin/ /var/www/html"
  user "root"
  not_if { ::File.exist?('/var/www/html/phpmyadmin') }
end

# call passwords databags
passwords = data_bag_item('passwords', 'mysql')

template '/etc/phpmyadmin/config.inc.php' do
    variables(
      'phpmyadmin_password': passwords['root_password']
    )
    source 'phpmyadmin.config.inc.php.erb'
    action :create
end
```

### Now we must generate a template file with our custom configuration of phpmyadmin.

Inside your cookbook lamp generate a template file named phpmyadmin.config.inc.php:
```
chef generate template phpmyadmin.config.inc.php
```
Now in your cookbooks/lamp/templates folder you find a file named phpmyadmin.config.inc.php.rb

In phpmyadmin.config.inc.php.rd add this code:
```
<?php
/**
 * Debian local configuration file
 *
 * This file overrides the settings made by phpMyAdmin interactive setup
 * utility.
 *
 * For example configuration see
 *   /usr/share/doc/phpmyadmin/examples/config.sample.inc.php
 * or
 *   /usr/share/doc/phpmyadmin/examples/config.manyhosts.inc.php
 *
 * NOTE: do not add security sensitive data to this file (like passwords)
 * unless you really know what you're doing. If you do, any user that can
 * run PHP or CGI on your webserver will be able to read them. If you still
 * want to do this, make sure to properly secure the access to this file
 * (also on the filesystem level).
 */

if (!function_exists('check_file_access')) {
    function check_file_access($path)
    {
        if (is_readable($path)) {
            return true;
        } else {
            error_log(
                'phpmyadmin: Failed to load ' . $path
                . ' Check group www-data has read access and open_basedir restrictions.'
            );
            return false;
        }
    }
}

// Load secret generated on postinst
if (check_file_access('/var/lib/phpmyadmin/blowfish_secret.inc.php')) {
    require('/var/lib/phpmyadmin/blowfish_secret.inc.php');
}

// Load autoconf local config
if (check_file_access('/var/lib/phpmyadmin/config.inc.php')) {
    require('/var/lib/phpmyadmin/config.inc.php');
}

/**
 * Server(s) configuration
 */
$i = 0;
// The $cfg['Servers'] array starts with $cfg['Servers'][1].  Do not use $cfg['Servers'][0].
// You can disable a server config entry by setting host to ''.
$i++;

/**
 * Read configuration from dbconfig-common
 * You can regenerate it using: dpkg-reconfigure -plow phpmyadmin
 */
if (check_file_access('/etc/phpmyadmin/config-db.php')) {
    require('/etc/phpmyadmin/config-db.php');
}



/* Authentication type */
//$cfg['Servers'][$i]['auth_type'] = 'cookie';
/* Server parameters */
$cfg['Servers'][$i]['host'] = '0.0.0.0';
//$cfg['Servers'][$i]['connect_type'] = 'tcp';
//$cfg['Servers'][$i]['compress'] = false;
/* Select mysqli if your server has it */
$cfg['Servers'][$i]['extension'] = 'mysql';
/* Optional: User for advanced features */
$cfg['Servers'][$i]['controluser'] = 'root';
$cfg['Servers'][$i]['controlpass'] = '<%= @phpmyadmin_password %>';

/* Storage database and tables */
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['designer_coords'] = 'pma__designer_coords';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
/* Uncomment the following to enable logging in to passwordless accounts,
 * after taking note of the associated security risks. */
// $cfg['Servers'][$i]['AllowNoPassword'] = TRUE;

/*
 * End of servers configuration
 */

/*
 * Directories for saving/loading files from server
 */
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

/* Support additional configurations */
foreach (glob('/etc/phpmyadmin/conf.d/*.php') as $filename)
{
    include($filename);
}
```
### test
Associate a node (in my case an UBUNTU vagrant vps) to your chef server
```
knife bootstrap 127.0.0.1 --ssh-port 2222 --ssh-user ubuntu --sudo --identity-file /my/path/chefworkspace/devops-config/chef-repo/.vagrant/machines/default/virtualbox/private_key -N vpsdev
```
Associate the recipes to your run list:
```
knife node run_list add myvps "recipe[lamp::default],recipe[lamp::apache],recipe[lamp::mysql],recipe[lamp::php],recipe[lamp::phpmyadmin]"
```

Inside your VPS run sudo chef-client
```
sudo chef-client
```

Check on your ip if run: http://my-ip/phpmyadmin


## FASE 2
### create Environments
in chef-repo folder:
```
mkdir environments
```

import environment:
```
knife environment from file production.rb
```

associate environment to a node:
```
knife node environment set vpsprod production
```


### APACHE virtualhosts
Create a data bag named apache_domains
```
knife data bag create apache_domains
```

Add domain
knife data bag from file apache_domains data_bags/apache_domains/jenkins.json```

```
myvps

knife bootstrap 54.37.153.249 --ssh-user root --sudo --ssh-password x1234 -N vpsprod
