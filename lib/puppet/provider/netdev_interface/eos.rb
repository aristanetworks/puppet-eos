=begin
# Puppet Module  : netdev_stdlib_eos
# Author         : Peter Sprygada
# File           : puppet/provider/netdev_interface/eos.rb
# Version        : 2013-03-22
# Platform       : EOS 4.12.x or later
# Description    : 
#
#   This file contains the EOS specific code to implement a 
#   netdev_interface.  The netdev_interface resource allows 
#   management of physical Ethernet interfaces on EOS systems.
#
# Copyright (c) 2013, Arista Networks
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
#   Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
#   Redistributions in binary form must reproduce the above copyright notice, this
#   list of conditions and the following disclaimer in the documentation and/or
#   other materials provided with the distribution.
# 
#   Neither the name of the {organization} nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
=end

Puppet::Type.type(:netdev_interface).provide(:eos) do
  confine :exists => "/etc/Eos-release"
  @doc = "Manage EOS physical interfaces"
  
  commands :devops => "devops" 

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def admin
    @property_hash[:admin]
  end
  
  def admin=(value)
    @property_flush[:admin] = value
  end

  def description
    @property_hash[:description]
  end
  
  def description=(value)
    @property_flush[:description] = value
  end

  def mtu
    @property_hash[:mtu]
  end
  
  def mtu=(value)
    @property_flush[:mtu] = value
  end

  def speed
    @property_hash[:speed]
  end
  
  def speed=(value)
    @property_flush[:speed] = value
  end

  def duplex
    @property_hash[:duplex]
  end
  
  def duplex=(value)
    @property_flush[:duplex] = value
  end
  
  def exists?
    @property_hash[:ensure] == :present
  end
  
  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    raise "The interface name #{resource[:name]} is invalid"
 end
 
  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    devops('interface', 'delete', resource[:name])
  end

  def self.instances
    Puppet.debug("Searching device for resources")
    resp = eval devops('interface', 'list', '--output', 'ruby-hash')
    resp['result'].each.collect do |key, value|
      new(:name => key,
          :ensure => :present,
          :admin => value['admin'],
          :descripton => value['description'],
          :mtu => value['mtu'],
          :speed => value['speed'],
          :duplex => value['duplex']
         )
    end
  end
  
  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    interfaces = instances
    resources.each do |name, params|
      if provider = interfaces.find { |interface| interface.name == params[:name] }
        Puppet.debug("Setting #{name} provider to #{provider}")
        resources[name].provider = provider
      end
    end
  end

  def flush
    Puppet.debug("Start flush")
    if @property_flush
      Puppet.debug("Flushing changed parameters")
      params= []
      (params << '--admin' << resource['admin']) if @property_flush[:admin]
      (params << '--description' << "#{resource['description']}") if @property_flush[:description]
      (params << '--mtu' << resource['mtu']) if @property_flush[:mtu]
      (params << '--speed' << resource['speed']) if @property_flush[:speed]
      (params << '--duplex' << resource['duplex']) if @property_flush[:duplex]
      devops('interface', 'edit', resource[:name], params)
    end
    @property_hash = resource.to_hash
  end


end