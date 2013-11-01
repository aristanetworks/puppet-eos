#
# Puppet Module  : eos
# File           : puppet/type/eos_vxlan.rb
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

Puppet::Type.newtype(:eos_vxlan) do
  @doc = "EOS Vxlan tunnel interface resource"

  ensurable

  newparam(:name, :namevar=>true) do
    desc "Vxlan tunnel interace name"
  end

  newproperty(:description) do
    desc "Vxlan tunnel interface description"
  end

  newproperty(:multicast_group) do
    desc "Vxlan Flood multicast group"
  end

  newproperty(:source_interface) do
    desc "Vxlan source interface"
  end

  newproperty(:map, :array_matching=>:all) do
    desc "Vlan ID to Vxlan VNI mapping"
    munge { |v|  Array(v) }

    # the order of the array elements is not important
    # so we need to do a sort-compare
    def insync?( is )
      is.sort == @should.sort.map(&:to_s)
    end
  end

end
