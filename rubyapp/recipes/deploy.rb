#
# Cookbook Name:: rubyapp
# Recipe:: deploy
#
# Copyright 2017, Vineet Sharma.
#
# All rights reserved - Do Not Redistribute
#

apt_repository 'nginx-development-trusty' do
    uri 'ppa:nginx/development'
    distribution node['lsb']['codename']
end

apt_update 'all platforms' do
  action :update
end

pkgs = value_for_platform(
                ["redhat"] =>
        {"default" => %w{ unzip git}},
    ["centos","fedora","scientific"] =>
        {"default" => %w{ unzip git}},
    [ "debian", "ubuntu" ] =>
        {"default" => %w{ git tree ntp unzip nginx }},
    "default" => %w{ git }
 )

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

#Nginx Service enable & restart or stop
service 'nginx' do
  action [ :enable, :stop]
end

template "/etc/rsyslog.d/50-default.conf" do
  source '50-default.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  action :create
  notifies :restart, "service[rsyslog]"
end

#Rsyslog Service enable & restart
service 'rsyslog' do
  action [ :enable, :start ]
  supports :restart => true
end


#make necessary changes to our nginx.conf file
template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

#make changes to our default site file
template '/etc/nginx/sites-enabled/default' do
  source 'default.erb'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

#Nginx Service enable & restart or stop
service 'nginx' do
  action [ :enable, :start ]
end
