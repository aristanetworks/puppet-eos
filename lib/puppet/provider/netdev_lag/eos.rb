=begin
* Puppet Module  : netdev_stdlib_eos
* Author         : Peter Sprygada
* File           : puppet/provider/netdev_lag/eos.rb
* Version        : 2013-03-22
* Platform       : EOS 4.10.x 
* Description    : 
*
*   This file contains the EOS specific code to implement a 
*   netdev_lag.  This provider will allow you to manage and 
    create LAG interfaces in EOS.
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

Puppet::Type.type(:netdev_lag).provide(:eos) do
  confine :exists => "/etc/EOS-release"
  @doc = "Mangae EOS Port-Channel interfaces"
  
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
  
  def lacp
    @property_hash[:lacp]
  end 
  
  def lacp=(value)
    @property_flush[:lacp] = value
  end
  
  def minimum_links
    @property_hash[:minimum_links]
  end
  
  def minimum_links=(value)
    @property_flush[:minimum_links] = value
  end
  
  def links
    @property_hash[:links]
  end
  
  def links=(value)
    @property_flush[:links] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end
 
  def create
    Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
    begin
      params = []
      (params << '--lacp' << resource['lacp']) if @property_hash[:lacp]
      (params << '--minimum_links' << resource['minimum_links']) if @property_hash[:minimum_links]
      (params << '--links' << resource['links'].join(',')) if @property_hash[:links]
      netdev('lag', 'create', resource[:name], params)
      @property_hash[:ensure] = :present
    rescue Puppet::ExecutionFailure =>  e
      Puppet.debug("Unable to create lag interface")
    end
  end
 
  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    begin
      netdev('lag', 'delete', resource[:name])
      @property_hash.clear
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to destroy interface")
    end
  end
 
  def self.instances
    Puppet.debug("Searching device for resources")
    lags = eval netdev('lag', 'list', '--output', 'ruby-hash')
    lags.each.collect do |key, value|
      new(:name => key,
          :ensure => :present,
          :lacp => value['lacp'],
          :minimum_links => value['minimum_links'],
          :links => value['links']
         )
    end
  end
 
  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    lags = instances
    resources.each do |name, params|
      if provider = lags.find { |lag| lag.name == params[:name] }
        Puppet.debug("Setting #{name} provider to #{provider}")
        resources[name].provider = provider
      end
    end
  end

  def flush
    Puppet.debug("#{self.resource.type}: FLUSH #{resource[:name]}")
    if @property_flush
      Puppet.debug("Flushing changed parameters")
      params = []
      (params << '--lacp' << resource['lacp']) if @property_flush[:lacp]
      (params << '--minimum_links' << resource['minimum_links']) if @property_flush[:minimum_links]
      (params << '--links' << resource['links'].join(',')) if @property_flush[:links]
      netdev('lag', 'edit', resource[:name],  params) if !params.empty?
    end
    @property_hash = resource.to_hash
  end
end