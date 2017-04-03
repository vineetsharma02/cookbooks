#
# Cookbook Name:: rubyapp
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
                        include_recipe "rubyapp::deploy"
		when "redhat", "centos", "amazon", "scientific"
                        include_recipe "rubyapp::deploy"
                end
        else
                Chef::Log.info("Oops...couldn't understand #{'node.os'} yet!!!")
        end
