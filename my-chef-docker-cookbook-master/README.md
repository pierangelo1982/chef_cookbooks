# mydocker

### docker

Go inside the chef-repo folder and generate a cookbook named mydocker:
```
generate cookbook cookbooks/mydocker
```

edit the file metadata.rb in cookbooks/mydocker/ and add this:
```
depends 'docker', '~> 2.0'
```

in cookbooks/mydocker/recipes edit the file default.rb and add this:
```
docker_service 'default' do
  action [:create, :start]
end


# Pull latest image
docker_image 'nginx' do
  tag 'latest'
  action :pull
end


# Run container exposing ports
docker_container 'my_nginx' do
  repo 'nginx'
  tag 'latest'
  port '80:80'
  volumes "/home/docker/default.conf:/etc/nginx/conf.d/default.conf:ro"
  volumes "/home/docker/html:/usr/share/nginx/html"
end

# create file default.conf for volumes doccker
template "/home/docker/default.conf" do
  source "default.conf.erb"
  #notifies :reload, "service[default]"
end

# create file index.html for volumes docker
template '/home/docker/html/index.html' do
  source 'index.html.erb'
  variables(
    :ambiente => node.chef_environment
  )
  action :create
  #notifies :restart, 'service[httpd]', :immediately
end
```
Now we must create two template named index.html.erb and default.conf.erb
```
chef generate template index.html
chef generate template default.conf
```
edit index.html.erb in /templates
```
<html>
  <body>
    <h1>Hello, World!</h1>
    <h3>HOSTNAME: <%= node['hostname'] %></h3>
    <h3>IPADDRESS: <%= node['ipaddress'] %></h3>
    <p><hr></p>
    <h3>ENVIRONMENT: <%= @ambiente %></h3>
</body>
</html>
```
edit default.conf in templates folder:
```
server {
    listen       80;
    server_name  localhost;

    #ssl
    # ssl    on;
    #ssl_certificate    /etc/nginx/ssl/nginx.crt;
    #ssl_certificate_key    /etc/nginx/ssl/nginx.key;

    #charset koi8-r;
    #access_log  /var/log/nginx/log/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
    }
```
link the cookbook to the node:
```
knife node run_list add docker1 "recipe[starter],recipe[mydocker]"
```
from inside the mydocker folder we can upload the new cookbook on the chef-server:
```
berks install
berks upload
```
Now, you can go on your server, and launch chef-client for update your machine with the new configuration.
```
sudo chef-client

