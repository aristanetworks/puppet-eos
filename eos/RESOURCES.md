# Resources
This document provides a summary of the supported resource types.

## eos_interface

| Name | Type | Added | Description |
|------|------|-------|-------------|
| interface_id | str | 1.0 | The physical interface id (eg Ethernet1, Ethernet1/1)
| description | str | 1.0 | The interface description
| enable | bool | 1.0 | Specifies the administrative state of the interface

## eos_lag

| Name | Type | Added | Description |
|------|------|-------|-------------|
| interface_id | str | 1.0 | The interface id (eg Port-Channel1)
| lacp | str | 1.0 | Specifies the LACP configuration to use.  Valid values are off, passive, active
| minimumum_links | int | 1.0 | The minimumum number of links required to consider the lag interface operationally up
| links | array | 1.0 | Specifies the member interfaces to be included in this lag

## eos_switchport

| Name | Type | Added | Description |
|------|------|-------|-------------|
| interface_id | str | 1.0 | The interface id (eg Ethernet1, Ethernet1/1)
| vlan_tagging | str | 1.0 | Specifies whether the interface supports vlan tagging.  Valid values are enable or disable
| untagged_vlan | str | 1.0 | Configures the name of the vlan to apply to untagged packets
| tagged_vlans | array | 1.0 | Specifies the names of the vlans allowed on this interface


## eos_vlan

| Name | Type | Added | Description |
|------|------|-------|-------------|
| vlan_id | int | 1.0 | Specifies the dot1q tag identifier
| name | str | 1.0 | Configures the name of the vlan

## eos_vxlan

| Name | Type | Added | Description |
|------|------|-------|-------------|
| description | str | 1.1 | Configures a one line interface description
| multicast-group | str | 1.1. | Configures the destination multicast group
| source-interface | str | 1.1 | Configures the VXLAN interface source
| map | str | 1.1 | Sets the vlan id to vni mapping

