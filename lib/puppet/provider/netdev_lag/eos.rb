=begin
# Puppet Module  : netdev_stdlib_eos
# Author         : Peter Sprygada
# File           : puppet/provider/netdev_lag/eos.rb
# Version        : 2013-06-13
# Platform       : EOS 4.12.x or later
# Description    : 
#
#   This file contains the EOS specific code to implement a 
#   netdev_lag.  This provider will allow you to manage and 
#   create LAG interfaces in EOS.
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

Puppet::Type.type(:netdev_lag).provide(:eos) do
  confine :exists => "/etc/Eos-release"
  @doc = "Mangae EOS Port-Channel interfaces"
  
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
      (params << '--lacp' << resource['lacp']) 
      (params << '--minimum_links' << resource['minimum_links']) 
      (params << '--links' << resource['links'].join(',')) 
      devops('lag', 'create', resource[:name], params)
      @property_hash[:ensure] = :present
    rescue Puppet::ExecutionFailure =>  e
      Puppet.debug("Unable to create lag interface")
    end
  end
 
  def destroy
    Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
    begin
      devops('lag', 'delete', resource[:name])
      @property_hash.clear
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to destroy interface")
    end
  end
 
  def self.instances
    Puppet.debug("Searching device for resources")
    resp = eval devops('lag', 'list', '--output', 'ruby-hash')
    resp['result'].each.collect do |key, value|
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
      devops('lag', 'edit', resource[:name],  params) if !params.empty?
    end
    @property_hash = resource.to_hash
  end
end