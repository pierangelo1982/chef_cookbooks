# ELK-STACK with Chef
## Elasticsearch, Logstash, Kibana (and maybe Filebeat)

Create a chef-repo in your chef console, download and unzip chef start, put the chef-repo folder into your project:
https://manage.chef.io


go inside chef-repo

in cookbook starter recipe add some standard library such as curl, git, vim etc...
```
cd cookbooks/starter/recipes/

vim default.rb
``` 
### 1 - some useful things:
my default.rb:
```
log "Welcome to Chef, #{node["starter_name"]}!" do
  level :info
end

execute "update-upgrade" do
    command "apt-get update && apt-get upgrade -y"
    action :run
end

package 'git'
package 'tree'
package 'curl'
```

update the version of the file metadata.rb inside the cookbooks that you had update:
```
name 'starter'
description 'A basic starter cookbook'
version '1.0.1'
maintainer 'Orizio Pierangelo'
maintainer_email 'pierangelo1982@gmail.com'
```

update the chef server:
```
berks install

berks upload

or if berks not run, try:

knife upload cookbooks/starter
```

### 2 The elk cookbook
From inside the root of chef-repo folder, create a cookbook named my-elk:
```
chef generate cookbook cookbooks/my-elk
```

go inside my-elk cookbook

edit metadata.rb and add elasticsearch depends:
```
depends 'elasticsearch', '~> 4.0.0'
```
edit default.rb and insert:
```
# Cookbook:: my-elk
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package 'default-jdk'

elasticsearch_user 'elasticsearch'
#elasticsearch_install 'elasticsearch'

elasticsearch_install 'my_es_installation' do
    type 'package' # type of install
    version '6.2.3'
    action :install # could be :remove as well
end

elasticsearch_configure 'elasticsearch' do
configuration ({
    'network.host' => '0.0.0.0',
    'http.port' => 9200,
  })
end
elasticsearch_service 'elasticsearch'

```

update the chef server:
```
berks install

berks upload
```
### 3 associate VPS:
```
knife bootstrap 159.65.122.58 --ssh-port 22 --ssh-user root --sudo --ssh-password 123456 -N testvps
```

# associate cookbooks or recipe:
```
knife node run_list add testvps "recipe[starter]"
knife node run_list add testvps "recipe[my-elk]"
```

connect in ssh to your vps and launch chef-client:
```
sudo chef-client
```
