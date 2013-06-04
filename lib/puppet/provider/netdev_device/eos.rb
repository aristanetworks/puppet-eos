=begin
# Puppet Module  : netdev_stdlib_eos
# Author         : Peter Sprygada
# File           : puppet/provider/netdev_device/eos.rb
# Version        : 2013-03-22
# Platform       : EOS 4.10.x 
# Description    : 
#
#   This file contains the EOS specific code to implement a 
#   netdev_device.  The netdev_device is auto required for 
#   all instantiations of netdev resources.
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

Puppet::Type.type(:netdev_device).provide(:eos) do
  confine :exists => "/etc/Eos-release"
  @doc = "EOS Device Managed Resource for auto-require"
  
  
  ##### ------------------------------------------------------------   
  ##### Device provider methods expected by Puppet
  ##### ------------------------------------------------------------  

  def exists?  
    true
  end

  def create
    raise "Unreachable: NETDEV create"    
  end

  def destroy
    raise "Unreachable: NETDEV destroy"        
  end

end