=begin
# Puppet Module  : netdev_stdlib_eos
# Author         : Peter Sprygada
# File           : puppet/provider/netdev_vlan/eos.rb
# Version        : 2013-03-22
# Platform       : EOS 4.12.x or later
# Description    : 
#
#   This file contains the EOS specific code to implement a 
#   netdev_vlan resource.  The netdev_vlan resource allows 
#   for the management of the VLAN database in EOS.
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

Puppet::Type.type(:netdev_vlan).provide(:eos) do
  confine :exists => "/etc/Eos-release"
  @doc = "Manage EOS VLAN database"
  
  commands :devops => "devops"

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
      devops('vlan', 'create', resource[:vlan_id], params)
      @property_hash[:ensure] = :present
    rescue Puppet::ExecutionFailure =>  e
      Puppet.debug("Unable to create vlan resource")
    end
  end
 
  def destroy
    begin
      Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
      devops('vlan', 'delete', @property_hash[:vlan_id])
      @property_hash.clear
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to destroy vlan resource")
    end
  end
 
  def self.instances
    Puppet.debug("Searching device for resources")
    resp = eval devops('vlan', 'list', '--output', 'ruby-hash')
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
        devops('vlan', 'edit', resource[:vlan_id],  params) if !params.empty?
      end
      @property_hash = resource.to_hash
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to flush vlan resource")
    end
  end
  
end