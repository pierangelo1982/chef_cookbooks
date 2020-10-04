#
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
