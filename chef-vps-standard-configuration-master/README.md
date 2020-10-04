### VPS STANDARD CONFIGURATION WITH CHEF

* APACHE
* MYSQL
* PHPMYADMIN
* FTP (vsftpd)
* DOCKER ?
* GIT
* TREE


## CHEF SERVER:
1 - Create a free account on chef.io

2 - Create an Organization iside chef console,

3 - download the chef-starter kit.

### VPS:
I use 2 instance, a local DEBIAN vagrant virtual machine on my computer for testing, and in production a very cheap (2,99 €/month) DEBIAN vps on OVH
* https://www.ovh.it/vps/

 vagrant:
 ```
 vagrant init debian/stretch64
 ```


## associa vps

vagrant:
```
knife bootstrap 127.0.0.1 --ssh-port 2222 --ssh-user vagrant --sudo --identity-file /home/pierangelo/chefworkspace/standard-vps-configuration/.vagrant/machines/testvps/virtualbox/private_key -N testvps
```
* http://192.168.10.43/

N.B: Automatically, when you associate the vps to chef-server, it install chefdk.

## generate cookbooks
```
chef generate cookbook cookbooks/lamp-stack
```
## generate recipe inside cookbooks
```
chef generate recipe apache
```
## GENERATE TEMPLATES

From termina, go inside the cookbooks recipe where you want add template file and:
```
chef generate template nome_file
```

## UPLOAD COOKBOOK
```
berks install

berks upload

altrimenti se non funziona

knife upload cookbooks/starter
```
N.B: Rememmber to update metadata version.

## ASSOCIA RECIPE/COOKBOOK to VPS
```
knife node run_list add nomevps "recipe[starter]"
```

```
knife node run_list add testvps "recipe[starter],recipe[lamp-stack::apache],recipe[lamp-stack::mysql]"
```

## Rimuovi associazione cookbooks VPS
```
knife node run_list remove testvps "recipe[phpmyadmin]"
```

## delete cookbooks errati
```
knife cookbook bulk delete nome_cookbook
```

## DATA BAGS

```
knife data bag create users

knife data bag create groups

knife data bag create passwords
```
importa file data BAGS
```
knife data bag from file passwords data_bags/passwords/mysql.json
```
