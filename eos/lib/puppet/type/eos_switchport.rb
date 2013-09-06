#
# Puppet Module  : eos_switchport
# File           : puppet/type/eos_switchport.rb
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

Puppet::Type.newtype(:eos_switchport) do
  @doc = "EOS switchport resource"
  
  ensurable

  newparam(:name, :namevar=>true) do
    desc "Switchport interface name"
  end
  
  newproperty(:vlan_tagging) do
    desc "Switchport vlan tagging mode"
    defaultto(:disable)
    newvalues(:enable,:disable)     
  end
    
  newproperty(:tagged_vlans, :array_matching=>:all) do
    desc "Array of VLAN names used for tagged packets"
    defaultto([])
    munge{ |v| Array(v) }
    
    def insync?(is)
      is.sort == @should.sort.map(&:to_s)
    end
    
    def should_to_s( value )
      "[" + value.join(',') + "]"
    end
    def is_to_s( value )
      "[" + value.join(',') + "]"
    end
    
  end
  
  newproperty(:untagged_vlan) do
    desc "VLAN used for untagged packets"
  end
      
  autorequire(:eos_vlan) do    
    vlans = self[:tagged_vlans] || []
    vlans << self[:untagged_vlan] if self[:untagged_vlan]
    vlans.flatten
  end    
  
end
