=begin
* Puppet Module  : netdev_stdlib_eos
* Author         : Peter Sprygada
* File           : puppet/provider/netdev_device/eos.rb
* Version        : 2013-03-22
* Platform       : EOS 4.10.x 
* Description    : 
*
*   This file contains the EOS specific code to implement a 
*   netdev_device.  The netdev_device is auto required for 
*   all instantiations of netdev resources.
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

Puppet::Type.type(:netdev_device).provide(:eos) do
  confine :exists => "/etc/EOS-release"
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