=begin
# Puppet Module  : netdev_stdlib_eos
# Author         : Peter Sprygada
# File           : puppet/provider/netdev_vlan/eos.rb
# Version        : 2013-03-22
# Platform       : EOS 4.10.x 
# Description    : 
#
#   This file contains the EOS specific code to implement a 
#   netdev_vlan resource.  The netdev_vlan resource allows 
#   for the management of the VLAN database in EOS.
#
#
# Copyright 2013 Arista Networks
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
=end

Puppet::Type.type(:netdev_vlan).provide(:eos) do
  confine :exists => "/etc/Eos-release"
  @doc = "Manage EOS VLAN database"
  
  commands :netdev => "netdev"

  def initialize(value={})
    super(value)
    @property_flush = {}
  end
  
  def name
    @property_hash[:name]
  end

  def name=(value)
    @property_flush[:name] = value
  end
  
  def vlan_id
    @property_hash[:vlan_id]
  end
  
  def vlan_id=(value)
    @property_flush[:vlan_id]
  end 

  def exists?
    @property_hash[:ensure] == :present
  end
  
  def create
    begin
      Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
      params= []
      params << '--name' << resource['name']
      netdev('vlan', 'create', resource[:vlan_id], params)
      @property_hash[:ensure] = :present
    rescue Puppet::ExecutionFailure =>  e
      Puppet.debug("Unable to create vlan resource")
    end
  end
 
  def destroy
    begin
      Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
      netdev('vlan', 'delete', @property_hash[:vlan_id])
      @property_hash.clear
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to destroy vlan resource")
    end
  end
 
  def self.instances
    Puppet.debug("Searching device for resources")
    resp = eval netdev('vlan', 'list', '--output', 'ruby-hash')
    resp['result'].each.collect do |key, value|
      new(:name => value['name'],
          :ensure => :present,
          :vlan_id => key
         )
    end
  end
 
  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    vlans = instances
    resources.each do |name, params|
      if provider = vlans.find { |vlan| vlan.vlan_id == params[:vlan_id] }
        Puppet.debug("Setting #{name} provider to #{provider}")
        resources[name].provider = provider
      end
    end
  end

  def flush
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    begin
      if @property_flush
        Puppet.debug("Flushing changed parameters")
        params = []
        (params << '--name' << resource['name']) if @property_flush[:name]
        netdev('vlan', 'edit', resource[:vlan_id],  params) if !params.empty?
      end
      @property_hash = resource.to_hash
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to flush vlan resource")
    end
  end
  
end