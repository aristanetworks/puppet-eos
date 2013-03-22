=begin
* Puppet Module  : netdev_stdlib_eos
* Author         : Peter Sprygada
* File           : puppet/provider/netdev_vlan/eos.rb
* Version        : 2013-03-22
* Platform       : EOS 4.10.x 
* Description    : 
*
*   This file contains the EOS specific code to implement a 
*   netdev_vlan resource.  The netdev_vlan resource allows 
*   for the management of the VLAN database in EOS.
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

Puppet::Type.type(:netdev_vlan).provide(:eos) do
  confine :exists => "/etc/EOS-release"
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
      netdev('vlans', 'create', resource[:vlan_id], params)
      @property_hash[:ensure] = :present
    rescue Puppet::ExecutionFailure =>  e
      Puppet.debug("Unable to create vlan resource")
    end
  end
 
  def destroy
    begin
      Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
      netdev('vlans', 'delete', @property_hash[:vlan_id])
      @property_hash.clear
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to destroy vlan resource")
    end
  end
 
  def self.instances
    Puppet.debug("Searching device for resources")
    vlans = eval netdev('vlans', 'list', '--output', 'ruby-hash')
    vlans.each.collect do |key, value|
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
        netdev('vlans', 'edit', resource[:vlan_id],  params) if !params.empty?
      @property_hash = resource.to_hash
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to flush vlan resource")
    end
  end
  
end