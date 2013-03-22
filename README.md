# OVERVIEW

Netdev is a vendor-neutral network abstraction framework contributed freely to the DevOps 
community.  This module provides the Arista Networks EOS specific provider for implementing 
the netdev types (netdevops/netdev-stdlib) in EOS.


# EXAMPLE USAGE

This module has been tested against Puppet agent 2.7.19. This example assumes that you've also installed 
the Puppet _stdlib_ module as this example uses the _keys_ function.

~~~~
node "myswitch1234.mycorp.com" {
     
  netdev_device { $hostname: }
    
  $vlans = {
    'Blue'    => { vlan_id => 100, description => "This is a Blue vlan" },
    'Green'   => { vlan_id => 101, description => "This is a Green vLAN" },
    'Purple'  => { vlan_id => 102, description => "This is a Puple vlan" },
    'Red'     => { vlan_id => 103, description => "This is a Red vlan" },
    'Yellow'  => { vlan_id => 104, description => "This is a Yellow vlan" }   
  }
    
  create_resources( netdev_vlan, $vlans )
    
  $access_ports = [
    'Ethernet1',
    'Ethernet2',
    'Ethernet3'
  ]
    
  $uplink_ports = [
    'Ethernet51',
    'Ethernet52'
  ]
      
  netdev_l2_interface { $access_ports:
    untagged_vlan => Blue
  }
          
  netdev_l2_interface { $uplink_ports:
    tagged_vlans => keys( $vlans )
  }
}
~~~~
  
# DEPENDENCIES

  * Puppet 2.7.19
  * Puppet module netdevops/netdev-stdlib
  * Netdev extension for EOS

# INSTALLATION ON PUPPET-MASTER

  * puppet module install aristanetworks/netdev_stdlib_eos 

# RESOURCE TYPES

See RESOURCE-STDLIB.md for documentation and usage examples

# CONTRIBUTORS

Peter Sprygada, Juniper Networks

# LICENSE

See LICENSE
