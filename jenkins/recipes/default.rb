#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2017, Vineet Sharma.
#
# All rights reserved - Do Not Redistribute
#

case node['os']
        when "linux"
                Chef::Log.info("Its Linux")
        case node['platform']
                when "debian", "ubuntu"
                        include_recipe "jenkins::deploy"
		when "redhat", "centos", "amazon", "scientific"
                        include_recipe "jenkins::deploy"
                end
        else
                Chef::Log.info("Oops...couldn't understand #{'node.os'} yet!!!")
        end
