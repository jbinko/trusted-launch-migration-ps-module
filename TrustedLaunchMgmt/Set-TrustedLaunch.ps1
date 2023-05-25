function Set-TrustedLaunch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateCount(1, 1000)]
        [array]$items
    )

    $azContext = Get-AzContext
    if ($null -eq $azContext)
    {
        Write-Error "Get-AzContext is empty. You need to call 'Connect-AzAccount' command first."
        Exit
    }

    $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    if ($null -eq $azProfile)
    {
        Write-Error "AzureRmProfileProvider is empty."
        Exit
    }

    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
    if ($null -eq $profileClient)
    {
        Write-Error "RMProfileClient is empty."
        Exit
    }

    $token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
    if ([string]::IsNullOrWhitespace($token))
    {
        Write-Error "Token is empty."
        Exit
    }

    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'='Bearer ' + $token.AccessToken
    }
    if ($null -eq $authHeader)
    {
        Write-Error "authHeader is empty."
        Exit
    }

    $securityProfile ='{"securityType":"TrustedLaunch","uefiSettings":{"secureBootEnabled":true,"vTpmEnabled":true}}'

    foreach ($i in $items | ForEach-Object {[pscustomobject]@{SubscriptionId = $_[0]; ResourceGroupName = $_[1]; VirtualMachineName = $_[2]}})
    {
        try {
            $SubscriptionId = $i.SubscriptionId
            $ResourceGroupName = $i.ResourceGroupName
            $VirtualMachineName = $i.VirtualMachineName

            if ([string]::IsNullOrWhitespace($SubscriptionId))
            {
                Write-Error "SubscriptionId is empty."
                Exit
            }

            if ([string]::IsNullOrWhitespace($ResourceGroupName))
            {
                Write-Error "ResourceGroupName is empty."
                Exit
            }

            if ([string]::IsNullOrWhitespace($VirtualMachineName))
            {
                Write-Error "VirtualMachineName is empty."
                Exit
            }

            Write-Output "Setting Trusted Launch on: $SubscriptionId / $ResourceGroupName / $VirtualMachineName"

            $uri = "https://management.azure.com/subscriptions/$($SubscriptionId)/resourcegroups/$($ResourceGroupName)/providers/Microsoft.Compute/virtualMachines/$($VirtualMachineName)?api-version=2023-03-01"

            $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $authHeader
            if ($null -eq $response)
            {
                Write-Error "response is empty."
                Exit
            }

            # Do not use nested resources - should be OK
            $response.PSObject.Properties.Remove('resources')
            
            # Add Trusted Launch
            $response.properties | add-member -Name "securityProfile" -value (Convertfrom-Json $securityProfile) -MemberType NoteProperty -Force

            $json = ConvertTo-Json -Depth 100 $response
            $r = Invoke-RestMethod -Uri $uri -Method Put -Headers $authHeader -Body $json -ContentType "application/json"
            
            Write-Output "OK"
        }
        catch {
            Write-Error $_            
        }        
    }
}
