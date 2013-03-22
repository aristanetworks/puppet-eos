=begin
* Puppet Module  : netdev_stdlib_eos
* Author         : Peter Sprygada
* File           : puppet/provider/netdev_l2_interface/eos.rb
* Version        : 2013-03-22
* Platform       : EOS 4.10.x 
* Description    : 
*
*   This file contains the EOS specific code to implement a 
*   netdev_l2_interface.   This module will manage EOS switchport
*   interfaces for providing layer 2 services.
*
*
* Copyright (c) 2013  Arista Networks. All Rights Reserved.
*
* YOU MUST ACCEPT THE TERMS OF THIS DISCLAIMER TO USE THIS SOFTWARE, 
* IN ADDITION TO ANY OTHER LICENSES AND TERMS REQUIRED BY ARISTA NETWORKS.
* 
* ARISTA IS WILLING TO MAKE THE INCLUDED SCRIPTING SOFTWARE AVAILABLE TO YOU
* ONLY UPON THE CONDITION THAT YOU ACCEPT ALL OF THE TERMS CONTAINED IN THIS
* DISCLAIMER. PLEASE READ THE TERMS AND CONDITIONS OF THIS DISCLAIMER
* CAREFULLY.
*
* THE SOFTWARE CONTAINED IN THIS FILE IS PROVIDED "AS IS." ARISTA MAKES NO
* WARRANTIES OF ANY KIND WHATSOEVER WITH RESPECT TO SOFTWARE. ALL EXPRESS OR
* IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY WARRANTY
* OF NON-INFRINGEMENT OR WARRANTY OF MERCHANTABILITY OR FITNESS FOR A
* PARTICULAR PURPOSE, ARE HEREBY DISCLAIMED AND EXCLUDED TO THE EXTENT
* ALLOWED BY APPLICABLE LAW.
*
* IN NO EVENT WILL ARISTA BE LIABLE FOR ANY DIRECT OR INDIRECT DAMAGES, 
* INCLUDING BUT NOT LIMITED TO LOST REVENUE, PROFIT OR DATA, OR
* FOR DIRECT, SPECIAL, INDIRECT, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES
* HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY ARISING OUT OF THE 
* USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF ARISTA HAS BEEN ADVISED OF 
* THE POSSIBILITY OF SUCH DAMAGES.
=end

Puppet::Type.type(:netdev_l2_interface).provide(:eos) do
  confine :exists => "/etc/EOS-release"
  @doc = "Manage EOS switchport interfaces"
  
  commands :netdev => "netdev" 

  def initialize(value={})
    super(value)
    @property_flush = {}
  end
  
  def vlan_tagging
    @property_hash[:vlan_tagging]
  end
  
  def vlan_tagging=(value)
    @property_flush[:vlan_tagging] = value
  end
  
  def description
    @property_hash[:description]
  end
  
  def description=(value)
    @property_flush[:description] = value
  end

  def tagged_vlans
    @property_hash[:tagged_vlans]
  end
  
  def tagged_vlans=(value)
    @property_flush[:tagged_vlans] = value
  end
  
  def untagged_vlan
    @property_hash[:untagged_vlan]
  end

  def untagged_vlan=(value)
    @property_flush[:untagged_vlan] = value
  end
  
  def exists?
    @property_hash[:ensure] == :present
  end
  
  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    begin
      params = []
      params << '--vlan_tagging' << resource['vlan_tagging']
      params << '--description' << resource['description'] 
      params << '--tagged_vlans' << resource['tagged_vlans'].join(',')
      params << '--untagged_vlan' << resource['untagged_vlan']
      netdev('l2interface', 'create', resource[:name], params)
      @property_hash[:ensure] = :present
    rescue Puppet::ExecutionFailure =>  e
      Puppet.debug("Unable to create l2interface")
    end
 end
 
  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    begin
      netdev('l2interface', 'delete', resource[:name])
      @property_hash.clear
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to destroy interface")
    end
  end

  def self.instances
    Puppet.debug("Searching device for resources")
    interfaces = eval netdev('l2interface', 'list', '--output', 'ruby-hash')
    interfaces.each.collect do |key, value|
      new(:name => key,
          :ensure => :present,
          :vlan_tagging => value['vlan_tagging'],
          :descripton => value['description'],
          :tagged_vlans => value['tagged_vlans'],
          :untagged_vlan => value['untagged_vlan']
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
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    if @property_flush
      Puppet.debug("Flushing changed parameters")
      params= []
      (params << '--vlan_tagging' << resource['vlan_tagging']) if @property_flush[:vlan_tagging]
      (params << '--description' << resource['description']) if @property_flush[:description]
      (params << '--untagged_vlan' << resource['untagged_vlan']) if @property_flush[:untagged_vlan]
      (params << '--tagged_vlans' << resource['tagged_vlans'].join(',')) if @property_flush[:tagged_vlans]
      netdev('l2interface', 'edit', resource[:name], params)
    end
    @property_hash = resource.to_hash
  end


end