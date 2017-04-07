#
# Cookbook Name:: jenkins
# Recipe:: deploy
#
# Copyright 2017, Vineet Sharma.
#
# All rights reserved - Do Not Redistribute
#

bash 'jenkins_repo' do
   code <<-EOH
     wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
     echo 'deb https://pkg.jenkins.io/debian-stable binary/' | tee -a /etc/apt/sources.list
     EOH
   action :run
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
        {"default" => %w{ git openjdk-8-jdk tree ntp curl build-essential jenkins }},
    "default" => %w{ git }
 )

pkgs.each do |pkg|
  package pkg do
    action :install
  end
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


#Jenkins Service enable & restart
service 'jenkins' do
  action [ :enable, :start ]
  supports :restart => true
end

user tomcat do
    shell       '/bin/false'
    comment     'tomcat user'
    home        '/opt/tomcat'
    action      :create
end

bash 'starting_ruby_app' do
   code <<-EOH
cd /opt/
wget http://mirror.wanxp.id/apache/tomcat/tomcat-8/v8.5.6/bin/apache-tomcat-8.5.6.tar.gz
tar -xzvf apache-tomcat-8.5.6.tar.gz
mv apache-tomcat-8.5.6 tomcat
chown -hR tomcat:tomcat tomcat
chmod +x /opt/tomcat/bin/*
/opt/tomcat/bin/startup.sh
sleep 10
	EOH
   action :run
end
