# This is a Chef recipe file. It can be used to specify resources which will
# apply configuration to a server.

log "Welcome to Chef, #{node["starter_name"]}!" do
  level :info
end

# For more information, see the documentation: https://docs.chef.io/essentials_cookbook_recipes.html
execute "update-upgrade" do
        command "apt-get update && apt-get upgrade -y"
        action :run
end

package 'git'
package 'tree'
package 'curl'
