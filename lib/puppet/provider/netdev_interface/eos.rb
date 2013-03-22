=begin
* Puppet Module  : netdev_stdlib_eos
* Author         : Peter Sprygada
* File           : puppet/provider/netdev_interface/eos.rb
* Version        : 2013-03-22
* Platform       : EOS 4.10.x 
* Description    : 
*
*   This file contains the EOS specific code to implement a 
*   netdev_interface.  The netdev_interface resource allows 
*   management of physical Ethernet interfaces on EOS systems.
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

Puppet::Type.type(:netdev_interface).provide(:eos) do
  confine :exists => "/etc/EOS-release"
  @doc = "Manage EOS physical interfaces"
  
  commands :netdev => "netdev" 

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
  end

  def self.instances
    Puppet.debug("Searching device for resources")
    interfaces = eval netdev('interface', 'list', '--output', 'ruby-hash')
    interfaces.each.collect do |key, value|
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
      netdev('interface', 'edit', resource[:name], params)
    end
    @property_hash = resource.to_hash
  end


end