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
        {"default" => %w{ git tree ntp unzip nginx ruby ruby-dev curl build-essential libpq-dev nodejs }},
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

git "/home/ubuntu/simple_rails_app" do 
  repository "https://github.com/bsvin33t/simple_rails_app.git"
  reference "master"
  action :sync
  group 'ubuntu'
  user 'ubuntu'
end

gems = value_for_platform(
                ["redhat"] =>
        {"default" => %w{ bundler }},
                ["centos","fedora","scientific"] => {"default" => %w{ bundler }},
                [ "debian", "ubuntu" ] => {"default" => %w{ bundler }},
        "default" => %w{ bundler }
        )

gems.each do |gem|
 gem_package gem do
  gem_binary '/usr/bin/gem'
  version '1.14.6'
  action :install
 end
end

#template '/home/ubuntu/simple_rails_app/Gemfile' do
#  source 'Gemfile.erb'
#  owner 'ubuntu'
#  group 'ubuntu'
#  mode 0644
#  action :create
#end

template '/home/ubuntu/simple_rails_app/config/database.yml' do
  source 'database.yml.erb'
  owner 'ubuntu'
  group 'ubuntu'
  mode 0644
  action :create
end

template '/etc/profile' do
  source 'profile.erb'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

bash 'install_ruby_app' do
   code <<-EOH
     su - ubuntu -c 'cd /home/ubuntu/simple_rails_app; ./bin/setup'
     sleep 30
     EOH
   action :run
end

bash 'starting_ruby_app' do
   code <<-EOH
     su - ubuntu -c 'cd /home/ubuntu/simple_rails_app; bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-production} &'
     sleep 30
     EOH
   action :run
end
