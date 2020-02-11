@"
===============================================================================
Title:         DataStore_Report.ps1
Description:   Pull DataStore Information from mentioned vCenters. 
Usage:         .\VC-AlarmCheck_Report.ps1
Date:          09/09/2019
Author:        Amol Patil
Verion:        v1.0
===============================================================================
"@

# Used PSWriteHTML  0.0.71
# Used Dashimo 0.0.22
rv * -ErrorAction SilentlyContinue


#region Simple Do-WriteHost Function
# It will write notmal time based logs on the screen

Function Do-WriteHost {
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 

                [Parameter(Mandatory=$false)] 
        [ValidateSet("Red","Yellow","Green")] 
        [string]$Color="White",

                [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info"
        )

$FormattedDate = Get-Date -Format "[yyyy-MM-dd-HH:mm:ss]"
switch ($Level) { 
            'Error' {
                $LevelText = 'ERROR:' 
                Write-Host $FormattedDate $LevelText $Message -ForegroundColor Red
                 } 
            'Warn' { 
                $LevelText = 'WARNING:'
                Write-Host $FormattedDate $LevelText $Message -ForegroundColor Yellow
                 } 
            'Info' { 
                #Write-Host $FormattedDate $Message 
                #Write-Host $LevelText $FormattedDate $Message
                $LevelText = 'INFO:'
                Write-Host $FormattedDate $LevelText $Message -ForegroundColor $Color
                } 
            } 
}
#endregion


# Get Start Time | to get the total elepsed time to complete this script.
$startMain = (Get-Date) 

#region VMWARE PLUGIN
if(-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue))
{
   Add-PSSnapin VMware.VimAutomation.Core -WarningAction 0
}
#endregion

$vCs = "vc1.apshell.com","vc2.apshell.com" #, 


$SCRIPT_PARENT   = Split-Path -Parent $MyInvocation.MyCommand.Definition 

$Date = Get-Date -Format "dd-MM-yyyy"
try{
Remove-Item -Path ($SCRIPT_PARENT + "\VC_DataStores_Report(Complete)_$($date).csv")

Do-WriteHost "Old output file has been removed."
}
Catch{

Do-WriteHost "There is no old Output file" -Level Warn
}

sleep -Seconds 5
  $outputfile = ($SCRIPT_PARENT + "\VC_DataStores_Report(Complete)_$($date).csv")

Function Get-@VMDataStores {

$Result = @()

$clusters = Get-Cluster #| select -First 1

#foreach ($cluster in Get-Cluster | select -First 2){
foreach ($cluster in $clusters ){
          Get-VMHost -Location $cluster | Get-Datastore | %{
        $info = "" | select VCName, DataStoreName, DataCenterName, ClusterName, CapacityGB, ProvisionedSpaceGB,UsedSpaceGB,FreeSpaceGB,FreeSpacePer,NumVM,OverProvisioned,'Shared Storage'
        $info.VCName = $_.ExtensionData.Client.ServiceUrl.Split('/')[2]
        $info.DataStoreName = $_.Name
        $info.DataCenterName = $_.Datacenter
        $info.ClusterName = $cluster.Name         
        $info.CapacityGB = [math]::Round($_.capacityMB/1024,2) 
        $info.ProvisionedSpaceGB = [math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2) 
        $info.UsedSpaceGB = [Math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace)/1GB,2)
        $info.FreeSpaceGB = [Math]::Round(($_.ExtensionData.Summary.FreeSpace)/1GB,2)
        $info.FreeSpacePer = [int][math]::Round(((100* ($_.ExtensionData.Summary.FreeSpace/1GB))/ ($_.ExtensionData.Summary.Capacity/1GB)),0) 
        $info.NumVM = @($_ | Get-VM | where {$_.PowerState -eq "PoweredOn"}).Count 
        $info.OverProvisioned = IF(($info.ProvisionedSpaceGB) -gt ($info.CapacityGB) ) {"True"} else {"False"}
        $info.'Shared Storage' = $_.ExtensionData.Summary.MultipleHostAccess
        $report = $info 
        $Result += $report 
    }

  }

  $Resultout = $Result | sort -property FreeSpacePer
   $Resultout


} # END Function Get-@VMDataStores


Foreach($VC in $VCs){

If(Test-Connection $VC -Quiet -Count 1  ){

Do-WriteHost "Connecting to VC >> $VC" -Color Green
#$VC_Connect = Connect-VIServer $VC -User $U -Password $P -WarningAction 0
$VC_Connect = Connect-VIServer -WarningAction 0
}

Else {
    Do-WriteHost  "VC is not available $($VC) " -Level Error -Color Red

}

If($VC_Connect.IsConnected){

$DataStoresOut = Get-@VMDataStores
#$DataStoresOut | Out-GridView

  $SCRIPT_PARENT = Split-Path -Parent $MyInvocation.MyCommand.Definition 

  $DataStoresOut | Export-Csv -path $outputfile -NoTypeInformation -Append
  $DataStoresOut 





Disconnect-VIServer $VC -Confirm:$False
}

} # Foreach VC loop end



#region HTML Dashboard

$importData = Import-Csv $outputfile
$outputfileHTML = "$SCRIPT_PARENT\VC_DataStores_Report_$($date).html"


$allData = $importData 

#region Datastores Count
$DSCount = $importData | select vcname | Group-Object vcname | select @{
    Label = "Name"
    Expression = { if ($_.Name) { $_.Name } else { "[No Value]" } }
  },@{N=“Total Count“;E={$_.count}} | sort 'Total Count' -Descending

#endregion

#region Cluster Datastores Count
$ClusterNameCount = $importData | select ClusterName | Group-Object ClusterName | select @{
    Label = "Name"
    Expression = { if ($_.Name) { $_.Name } else { "[No Value]" } }
  },@{N=“Total Count“;E={$_.count}} | sort 'Total Count' -Descending

#endregion


#region Overprovisioned Datastores
$OverProvisioned = $importData | Where-Object {$_.OverProvisioned -eq 'True'} 

#endregion

#region Lowspace Datastores
$LowSpaceDS = $importData | Where-Object {(($_.FreeSpacePer -le 15) -and ($_.FreeSpacePer -notlike 100))} 
#endregion


#region Local/Storage Datastores Count
$SharedStorageCount = $importData | select 'Shared Storage' | Group-Object 'Shared Storage' | select @{
    Label = "Name"
    Expression = { if ($_.Name -eq $true) { "Shared" } elseif ($_.Name -eq $False) { "Local" } else { "[No Value]" } }
  },@{N=“Total Count“;E={$_.count}} | sort 'Total Count' -Descending

#endregion

#region Datastores Usage
$StorageUsed = $importData | select 'Shared Storage' | Group-Object 'Shared Storage' | select @{
    Label = "Name"
    Expression = { if ($_.Name -eq $true) { "Shared" } elseif ($_.Name -eq $False) { "Local" } else { "[No Value]" } }
  },@{N=“Total Count“;E={$_.count}} | sort 'Total Count' -Descending

#endregion

#region Overprovissioned Datastores Count
$ToalDS =@()
$TotalOverprovissonDS =@()
$VCnames = ($importData | select vcname -Unique ).vcname
for ($i = 0; $i -lt $VCnames.Count; $i++) {
$ToalDS += ($importData | Where-Object {(($_.vcname -eq $VCnames[$i]) -and ($_.DataStoreName -like "*"))}).count
$TotalOverprovissonDS += ($importData | Where-Object {(($_.vcname -eq $VCnames[$i]) -and ($_.OverProvisioned -like "True"))}).count
}

#endregion

#region Shared/Local Datastores Count
$ToalDS =@()
$TotalSharedDS =@()
$TotalLocalDS =@()
$VCnames = ($importData | select vcname -Unique ).vcname
for ($i = 0; $i -lt $VCnames.Count; $i++) {
$ToalDS += ($importData | Where-Object {(($_.vcname -eq $VCnames[$i]) -and ($_.DataStoreName -like "*"))}).count
$TotalSharedDS += ($importData | Where-Object {(($_.vcname -eq $VCnames[$i]) -and ($_.'Shared Storage' -like "True"))}).count
$TotalLocalDS += ($importData | Where-Object {(($_.vcname -eq $VCnames[$i]) -and ($_.'Shared Storage' -like "False"))}).count
}
#endregion

#region Dashboard HTML code
Dashboard -Name 'VMWare DataStore Dashboard ' -FilePath $outputfileHTML -Show {

TabOptions -SlimTabs  -SelectorColor Allports -Transition -LinearGradient -SelectorColorTarget DodgerBlue
    Tab -Name 'Summary'   {
       Section -Name 'Count Summary' -Collapsable -HeaderBackGroundColor Astral{ 

        Panel  {
              $Data1 = @($DSCount.'Total Count') 
                $DataNames1 = @($DSCount.Name) 
                Chart -Title 'DataStores per Virtual Centers' -TitleAlignment center {
                ChartBarOptions -Type bar -DataLabelsOffsetX 10 -Distributed 
                    ChartLegend -Name 'Total'
                    for ($i = 0; $i -lt $Data1.Count; $i++) {
                        ChartBar -Name $DataNames1[$i]  -Value $Data1[$i] 
                    }
                }
                    
           }
        Panel  {
              $Data1 = @($ClusterNameCount.'Total Count') 
                $DataNames1 = @($ClusterNameCount.Name) 
                Chart -Title 'DataStores per vClusters' -TitleAlignment center  {
                ChartBarOptions -Type bar -DataLabelsOffsetX 10 
                    ChartLegend -Name 'Total' 
                    for ($i = 0; $i -lt $Data1.Count; $i++) {
                        ChartBar -Name $DataNames1[$i] -Value $Data1[$i] 
                    }
                }
                    
           }

             Panel  {
              $Data1 = @($SharedStorageCount.'Total Count') 
                $DataNames1 = @($SharedStorageCount.Name) 
                Chart -Title 'DataStores Type' -TitleAlignment center  {
                ChartBarOptions -Type bar -DataLabelsOffsetX 10 
                    ChartLegend -Name 'Total' 
                    for ($i = 0; $i -lt $Data1.Count; $i++) {
                        ChartBar -Name $DataNames1[$i] -Value $Data1[$i] 
                    }
                }    
           }
           }

        Section -Name 'Datastores Summary' -Collapsable -HeaderBackGroundColor Astral {
            
            Panel {
               $D1 =@($ToalDS)
               $D2 =@($TotalOverprovissonDS)
               $DN1 =@($VCnames)


            Chart -Title 'Overprovissioned Datastores per VC' -TitleAlignment center {
            ChartBarOptions -Type bar -DataLabelsOffsetX 15 
            ChartLegend -Name 'Total Datastores','Overprovissioned Datastores' -Color SeaGreen,IndianRed #CoralRed
                for ($i = 0; $i -lt $D1.Count; $i++) {
                        ChartBar -Name $DN1[$i]  -Value $D1[$i],$D2[$i] 
                        #ChartBar -Name $DN1[$i]  -Value $D2[$i] 
                    }
            }
        }
            
            Panel {
               $D1 =@($ToalDS)
               $D2 =@($TotalSharedDS)
               $D3 =@($TotalLocalDS)
               $DN1 =@($VCnames)


            Chart -Title 'Shared & Local Datastores per VC' -TitleAlignment center {
            ChartBarOptions -Type barStacked100Percent    #-DataLabelsOffsetX 15 
            ChartLegend -Name 'Shared Datastores','Local Datastores'   #-Color CornflowerBlue,SeaGreen,IndianRed #CoralRed
                for ($i = 0; $i -lt $D1.Count; $i++) {
                        ChartBar -Name $DN1[$i]  -Value $D2[$i],$D3[$i]  #$D1[$i],$D2[$i],$D3[$i]  
                        #ChartBar -Name $DN1[$i]  -Value $D2[$i] 
                    }
            }
        }    
         }
        
        Section -Name 'Low Space Datastores' -Collapsable -HeaderBackGroundColor Astral{
        Table -DataTable $LowSpaceDS -PagingOptions 5,15,25 {
        TableConditionalFormatting -Name 'FreeSpacePer' -ComparisonType number -Operator le -Value 15 -Color black -BackgroundColor amber 
        TableConditionalFormatting -Name 'FreeSpacePer' -ComparisonType number -Operator le -Value 10 -Color black -BackgroundColor Crimson 
        }

        }

        Section -Name 'Over provisioned Datastores' -Collapsable -HeaderBackGroundColor Astral{
        Table -DataTable $OverProvisioned -PagingOptions 5,15,25 {
        TableConditionalFormatting -Name 'OverProvisioned' -ComparisonType string -Operator like -Value 'True' -Color black -BackgroundColor Crimson
        }

        }

    }
    Tab -Name 'Data'  {
    Table -DataTable $allData -DefaultSortColumn 'FreeSpacePer', 'OverProvisioned' -PagingOptions 5,15,25   {
        TableConditionalFormatting -Name 'FreeSpacePer' -ComparisonType number -Operator le -Value 15 -Color black -BackgroundColor amber 
        TableConditionalFormatting -Name 'FreeSpacePer' -ComparisonType number -Operator le -Value 10 -Color black -BackgroundColor Crimson 
        TableConditionalFormatting -Name 'OverProvisioned' -ComparisonType string -Operator like -Value 'True' -Color black -BackgroundColor Crimson 

    }
    }
}


#endregion


#$MailTextT =  Get-Content $outputfileHTML

$Sig =  "<html><p class=MsoNormal><o:p>&nbsp;</o:p></p><B> Regards, <p> Amol Patil</B></p></html>"
$Top = "<html> .</html>"
$MailText= $Top + $Sig
$smtpServer = "smtp.apshell.com " # SMTP server
$smtpFrom = "amol.patil@apshell.com"
$smtpTo = "amol.patil@apshell.com"
$messageSubject = "Datastores Usage Report > $(Get-date -Format "dd-MM-yyyy") (Week - $(get-date -UFormat %V))"
$messageBody = $MailText #+  $MailTextT 
$Attachment = $outputfile, $outputfileHTML <# If any attachment then you can define the  $Attachment#>


$mailMessageParameters = @{
       From       = $smtpFrom
       To         = $smtpTo
       Subject    = $messageSubject
       SmtpServer = $smtpServer
       Body       = $messageBody
      Attachment = $Attachment
}

Send-MailMessage @mailMessageParameters -BodyAsHtml 


Do-WriteHost "Email has been sent..... $(Get-date -format "dd-MMM-yyyy HH:mm:ss")" -Color Green
#*****************************************

# Get End Time
$EndMain = (Get-Date)
$MainElapsedTime = $EndMain-$startMain
$MainElapsedTimeOut =[Math]::Round(($MainElapsedTime.TotalMinutes),3)

Do-WriteHost "[Total Elapsed Time] $MainElapsedTimeOut Min."   

#***************************************** 
