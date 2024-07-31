# Get Horizon Instant Clone Pool Information

## Overview
<!-- Summary Start -->
Gets information on Instant Clone Pool VMs  
Returns information on Horizon Instant Clone pool VMs, including space consumed, and hierarchy of Parent, Replica, Template, Snapshot, and Master  
Identifies VMs that are potentially orphaned/abandoned by Horizon  
Array of VM objects containing data on their associated IC VMs and a status  

Author: Mark McGill, VMware  
Last Edit: 11/4/2020  
Version 1.0  
<!-- Summary End -->

## Requirements
PowerCLI, VMware.Hv.Helper ,and Powershell 5. VMware.Hv.Helper module is not yet supported in Powershell Core
For instructions on installing VMware.Hv.Helper, see https://blogs.vmware.com/euc/2020/01/vmware-horizon-7-powercli.html

## Usage
Load function in order to call function  
`. .\Get-ICPoolInfo.ps1`

Gets all Instant Clone pools in the pod.  If not currently connected to the Connection Server and vCenter Server, you will be prompted for credentials  
`Get-ICPoolInfo -connectionServer "horizon-01.corp.local"`

Create credential object that can be used for Horizon and vCenter authentication  
`$credentials = Get-Credential`
`Get-ICPoolInfo -connectionServer "horizon-01.corp.local" -credential $credentials`

Write the returned array of objects to a CSV file  
`Get-ICPoolInfo -connectionServer "horizon-01.corp.local" | Export-Csv "c:\temp\icInfo.csv" -NoTypeInformation`

## Parameters
`connnectionServer`  
Required: Yes  
You must specify a Horizon Connection Server to connect to

`credential`  
Required: No  
You can provide a credential object for connection to the Connection Server and vCenter Server.  If you are not already connected to them, you will be prompted for credentials  
Provided credentials should have access to both Horizon Connection Server and vCenter Server
