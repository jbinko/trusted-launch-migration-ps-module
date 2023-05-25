# Trusted launch migration for Azure VMs

## Overview

The goal of this project is to publish PowerShell module which will help with migration
of VMs for trusted launch feature for Azure VMs.

Module enables Trusted launch on your existing Gen2 VMs by 
upgrading from Standard to Trusted launch security type.

The Gen2 VM should be stopped and deallocated before you run the script to enable
Trusted launch on your Gen2 VM.

## Prerequisites

- Currently trusted launch feature for Azure VMs is in preview. You need to register your subscription to use this feature. Reach Microsoft representnatives to get your subscription registered for trusted launch feature for Azure VMs.
- Azure PowerShell module. You can download and install it from [here](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell)

## Migration steps

- Stop and deallocate the Gen2 VMs
- Use PowerShell module from this repository, download it to your local machine and switch to the directory where you downloaded the module
- Specify parameters for the script. Subscription ID, Resource Group Name, VM Name. If you will specify just one VM see commented out line. For one record you need to specify initial comma which is PowerShell syntax for array of one object.
- Run the script to enable trusted launch on the Gen2 VMs. See example below
- Verify that the deployment is successful. Check for the security type and UEFI settings of the VM using Azure Portal. Check the Security type section in the Overview tab
- Start the Gen2 VM back and ensure that it has started successfully and verify that you are able to login to the VM using either RDP (for Windows VM) or SSH (for Linux VM)

```powershell
cls
Import-Module "$PSScriptRoot\TrustedLaunchMgmt"

Connect-AzAccount
Set-AzContext -SubscriptionId "your target subscription ID"


# For one VM see the next line - initial comma needs to be specified for one record
#$VMs = ,("your target subscription ID","your resource group name where is target VM", "target VM name")
$VMs = ("your target subscription ID","your resource group name where is target VM", "target VM name"),("your target subscription ID","your resource group name where is target VM", "target VM name")
Set-TrustedLaunch $VMs
```

## TODO for next version

- Add support to customize parameters (secureBootEnabled, vTpmEnabled, attestation)
- Add support to enable Integrity Monitoring for Microsoft Defender for Cloud.
