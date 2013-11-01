#
# Puppet Module  : eos
# File           : puppet/provider/eos_vxlan/eos.rb
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
require 'rubygems'
require 'json'

Puppet::Type.type(:eos_vxlan).provide(:eos) do
  @doc = "EOS Vxlan tunnel interface resource"

  confine :exists=> "/etc/Eos-release"
  commands :devops => "devops"

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def name=(value)
    @property_flush[:name] = value
  end

  def description=(value)
    @property_flush[:description] = value
  end

  def multicast_group=(value)
    @property_flush[:multicast_group] = value
  end

  def source_interface=(value)
    @property_flush[:source_interface] = value
  end

  def map=(value)
    @property_flush[:map] = value
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    begin
      Puppet.debug("#{self.resource.type}: CREATE #{resource[:name]}")
      params= []
      (params << '--description' << resource['description']) if resource['description']
      (params << '--multicast-group' << resource['multicast_group']) if resource['multicast_group']
      (params << '--source-interface' << resource['source_interface']) if resource['source_interface']
      (params << '--map' << resource['map'].join(',')) if resource['map']
      devops('vxlan', 'create', resource[:name], params)
      @property_hash[:ensure] = :present
    rescue Puppet::ExecutionFailure =>  e
      Puppet.debug("Unable to create resource")
    end
  end

  def destroy
    begin
      Puppet.debug("#{self.resource.type}: DESTROY #{resource[:name]}")
      devops('vxlan', 'delete', @property_hash[:name])
      @property_hash.clear
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to destroy resource")
    end
  end

  def self.instances
    Puppet.debug("Searching device for resources")
    resp = JSON.parse(devops('vxlan', 'list'))
    resp['result'].each.collect do |key, value|
     new(:name => key,
          :description => value['description'],
          :multicast_group => value['multicast_group'],
          :source_interface => value['source_interface'],
          :map => value['vni_map'].each.collect { |vid,vni| "#{vid}:#{vni}" },
          :ensure => :present
          )
    end
  end

  def self.prefetch(resources)
    Puppet.debug("Populating existing resources using prefetch")
    current_resources = instances
    resources.keys.each do |name|
      if provider = current_resources.find { |instance| instance.name == name }
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
        (params << '--description' << resource['description']) if @property_flush[:description]
        (params << '--multicast-group' << resource['multicast_group']) if @property_flush[:multicast_group]
        (params << '--source-interface' << resource['source_interface']) if @property_flush[:source_interface]
        (params << '--map' << resource['map'].join(',')) if @property_flush[:map]
        devops('vxlan', 'edit', resource[:name], params) unless params.empty?
      end
      @property_hash = resource.to_hash
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("Unable to flush resource")
    end
  end
end

