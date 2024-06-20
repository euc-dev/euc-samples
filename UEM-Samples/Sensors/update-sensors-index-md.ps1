<# Workspace ONE Sensors Importer

  .SYNOPSIS
    This Powershell script allows you to automatically update the euc-samples/UEM-Samples/Sensors/index.md 

  .NOTES
    Created:   	    2024/06/04
    Created by:	    Richard Croft, rcroft@vmware.com
    Contributors:   Josue Negron, jnegron@vmware.com, Chris Halstead, chealstead@vmware.com; Phil Helmling, helmlingp@vmware.com
    Organization:   VMware, Inc.
    Filename:       update-sensors-index-md.ps1
    Updated:        2024/06/04, helmlingp@vmware.com
    Github:         https://github.com/euc-oss/euc-samples/tree/main/UEM-Samples/Sensors/update-sensors-index-md.ps1


  .DESCRIPTION
    Place this PowerShell script in the same directory of all of your samples (.ps1, .sh, .zsh, .py files) or use the -SensorsDirectory parameter 
    to specify your directory. This script will parse the sensors, and update the index.md file.

    For Windows Samples be sure to use the following format when creating new samples so that they are imported correctly:
    # Description: Description
    # Execution Context: SYSTEM | USER
    # Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
    # Return Type: INTEGER | BOOLEAN | STRING | DATETIME
    <YOUR POWERSHELL COMMANDS>

    For macOS Samples be sure to use the following format when creating new samples so that they are imported correctly:
    <YOUR SCRIPT COMMANDS>
    # Description: Description
    # Execution Context: SYSTEM | USER
    # Return Type: INTEGER | BOOLEAN | STRING | DATETIME
    # Variables: KEY,VALUE; KEY,VALUE

    For Linux Samples be sure to use the following format when creating new samples so that they are imported correctly:
    <YOUR SCRIPT COMMANDS>
    # Description: Description
    # Execution Context: SYSTEM | USER
    # Return Type: INTEGER | BOOLEAN | STRING | DATETIME
    # Variables: KEY,VALUE; KEY,VALUE
    # Platform: LINUX

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    VMWARE,INC. BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  .EXAMPLE

    .\update-sensors-index-md.ps1

    .PARAMETER SensorsDirectory
    OPTIONAL: The directory your sensor samples are located, default location is the current PowerShell directory of this script. 

    .PARAMETER Platform
    OPTIONAL: Keep disabled to import all platforms. If enabled, determines what platform's sensors to import. Supported values are "Windows", "macOS" or "Linux".  

#>

[CmdletBinding()]
    Param(

        [Parameter(Mandatory=$False)]
        [string]$SensorsDirectory, 

        [Parameter(Mandatory=$False)]
        [string]$Platform

)

# Parse Local PowerShell Files
Function Get-LocalSensors {
    Write-Host("Parsing Local Files for Sensors")
    #$Sensors = Select-String -Path $SensorsDirectory\* -Pattern 'Return Type' -Context 10000000 -ErrorAction SilentlyContinue
    $ExcludedcTemplates = "import_sensor_samples|get_enrollment_sid_32_64|check_matching_sid_sensor|template*|readme|index|update-sensors-index-md"
    $Sensors = Get-ChildItem -File -Recurse -Path $SensorsDirectory | Where-Object Name -NotMatch $ExcludedcTemplates
    Write-Host("Found " + $Sensors.Count + " Sensors in local folder") -ForegroundColor Green
    Return $Sensors
}

# Display usage info
Function usage {
    param (
        [Parameter(Mandatory=$True)]
        [string]$ScriptName
    )

    Write-Host("*****************************************************************") -ForegroundColor Yellow 
    Write-Host("               $SensorName Header Missing ") -ForegroundColor Yellow 
    Write-Host("*****************************************************************") -ForegroundColor Yellow 
    Write-Host "`rPlease ensure that $SensorName script includes the required header so that it can be imported correctly.`r" -ForegroundColor Yellow

    Write-Host "Example Windows Sensor Header`r" -ForegroundColor Green
    Write-Host "# Description: Description`r"
    Write-Host "# Execution Context: System | User`r"
    Write-Host "# Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY`r"
    Write-Host "# Return Type: INTEGER | BOOLEAN | STRING | DATETIME`r"
    Write-Host "<YOUR POWERSHELL COMMANDS>`r`n"

    Write-Host "Example macOS Sensor Header`r" -ForegroundColor Green
    Write-Host "<YOUR SCRIPT COMMANDS>`r"
    Write-Host "# Description: Description`r"
    Write-Host "# Execution Context: System | User`r"
    Write-Host "# Return Type: INTEGER | BOOLEAN | STRING | DATETIME`r"
    Write-Host "# Variables: KEY,VALUE; KEY,VALUE`r"

    Write-Host "Example Linux Sensor Header`r" -ForegroundColor Green
    Write-Host "<YOUR SCRIPT COMMANDS>`r"
    Write-Host "# Description: Description`r"
    Write-Host "# Execution Context: System | User`r"
    Write-Host "# Return Type: INTEGER | BOOLEAN | STRING | DATETIME`r"
    Write-Host "# Variables: KEY,VALUE; KEY,VALUE`r"
    Write-Host "# Platform: LINUX`r"

    Write-Host "Note: The ""Variables:"" metadata in macOS/Linux scripts are optional. Please do not include if not relevant.`r`n"
    Read-Host -Prompt "Press any key to continue"
}

# Clear variables so they don't get reused
Clear-Variable -Name ("PSSensors", "NumSensors") -ErrorAction SilentlyContinue

# If a custom sensors directory is not provided then use current directory of import_sensor_samples.ps1 
if (!$SensorsDirectory) {
    $SensorsDirectory = Get-Location
}

# change this to say whether its going to deletes, imports, exports or updates sensors
# also say if its going to assign them
if($Platform){
    $platformMessage = "$Platform"
} else {
    $platformMessage = "all"
}

Write-Host("*****************************************************************") -ForegroundColor Yellow 
Write-Host($startmsg) -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 

# Pull in Sensor Samples
$PSSensors = Get-LocalSensors
$NumSensors = $PSSensors.Count - 1

$BaseDirectory = Get-Location
$BaseDirectoryLength = $BaseDirectory.ToString().length

Clear-Content -Path ./index.md
Add-Content -Path ./index.md -Value "# Index.md"
Add-Content -Path ./index.md -Value "`nNumber of sensor samples found: $NumSensors`n"

Add-Content -Path ./index.md -Value "| Sample Name | Summary | Link |"
Add-Content -Path ./index.md -Value "|-------------|---------|------|"

Write-Host "Base Directory: $BaseDirectory"
Write-Host "Base Directory Length: $BaseDirectoryLength"

do {
    $Sensor = $PSSensors[$NumSensors]
    $SensorName = $Sensor.Name.ToLower()
    $SensorFileName = $Sensor.Name.ToLower()
    $SensorFullName = $Sensor.FullName
    $relativeFileName = ($SensorFullName).Substring($BaseDirectoryLength + 1)

    Write-Host("Working on $relativeFileName") -ForegroundColor Green

    $showusage = $false

    Clear-Variable -Name ("scriptPlatform", "Description", "Context", "Architecture", "ResponseType", "Variables", "SensortobeAssigned", "SensorAssigned") -ErrorAction SilentlyContinue

    #Get the actual content
    $content = Get-Content -Path $Sensor.FullName

    # Description: Removes Comment # and Quotes
    $d = $content | Select-String -Pattern 'Description: ' -Raw
    if($d){$Description = $d.Substring($d.LastIndexOf('Description: ')+13) -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Execution Context: USER, SYSTEM
    $c = $content | Select-String -Pattern 'Execution Context: ' -Raw
    if($c){$Context = $c.Substring(($c.LastIndexOf('Execution Context: ')+19))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Execution Architecture: EITHER64OR32BIT | ONLY_32BIT | ONLY_64BIT | LEGACY
    $a = $content | Select-String -Pattern 'Execution Architecture: ' -Raw
    if($a){$Architecture = $a.Substring(($a.LastIndexOf('Execution Architecture: ')+24))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Return Type: INTEGER, BOOLEAN, STRING, DATETIME
    $r = $content | Select-String -Pattern 'Return Type: ' -Raw
    if($r){$ResponseType = $r.Substring(($r.LastIndexOf('Return Type: ')+13))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Variables: Key, Value; Key, Value
    $v = $content | Select-String -Pattern 'Variables: ' -Raw
    if($v){$Varibles = $v.Substring(($v.LastIndexOf('Variables: ')+8))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}
    # Platform: WIN_RT | APPLE_OSX | LINUX
    $p = $content | Select-String -Pattern 'Platform: ' -Raw
    if($p){$scriptPlatform = $p.Substring(($p.LastIndexOf('Platform: ')+10))  -replace '[#]' -replace '"',"" -replace "'",""}else{$showusage = $true}

    switch ($scriptPlatform) {
        "Windows" { $Platform = "Windows" }
        "macOS"   { $Platform = "macOS" }
        "Linux"   { $Platform = "Linux" }
        Default   { $Platform = $null }
    }

    if(!$showusage){
        usage -ScriptName $SensorName;
        $NumScripts--;
        Continue;
    }

    switch -Regex ( $SensorName )
    {
        '^.*\.(ps1)$'
        {
            $query_type = "POWERSHELL"
            $os = "WIN_RT"
            $SensorName = $SensorName.Replace(".ps1","").Replace(" ","_")
        }
        '^.*\.(py)$'
        {
            $query_type = "PYTHON"
            $os = "APPLE_OSX"
            $SensorName = $SensorName.Replace(".py","").Replace(" ","_")
        }
        '^.*\.(zsh)$'
        {
            $query_type = "ZSH"
            $os = "APPLE_OSX"
            $SensorName = $SensorName.Replace(".zsh","").Replace(" ","_")
        }
        '^.*\.(sh)$'
        {
            #macOS and Linux both support BASH shell script
            $ShaBang = $content[0].ToLower()
            switch -Regex ( $ShaBang )
            {
                '^.*(\/bash)$'
                {
                    $query_type = "BASH"
                    if($scriptPlatform -eq "LINUX"){
                        $os = $scriptPlatform
                    }else{
                        $os = "APPLE_OSX"
                    }
                    $SensorName = $SensorName.Replace(".sh","").Replace(" ","_")
                }
                '^.*(\/zsh)$'
                {
                    $query_type = "ZSH"
                    $os = "APPLE_OSX"
                    $SensorName = $SensorName.Replace(".sh","").Replace(".zsh","").Replace(" ","_")
                }
                default
                {
                    $query_type = "BASH"
                    if($scriptPlatform -eq "LINUX"){
                        $os = $scriptPlatform
                    }else{
                        $os = "APPLE_OSX"
                    }                
                    $SensorName = $SensorName.Replace(".sh","").Replace(" ","_")
                }
            }
        }
        default # searches the sha-bang for sensors with no file extension 
        {
            $ShaBang = $content[0].ToLower()
            switch -Regex ( $ShaBang )
            {
                '^.*(\/bash)$'
                {
                    $query_type = "BASH"
                    if($scriptPlatform -eq "LINUX"){
                        $os = $scriptPlatform
                    }else{
                        $os = "APPLE_OSX"
                    }
                    $SensorName = $SensorName.Replace(".sh","").Replace(" ","_")
                }
                '^.*(\/zsh)$'
                {
                    $query_type = "ZSH"
                    $os = "APPLE_OSX"
                    $SensorName = $SensorName.Replace(".sh","").Replace(".zsh","").Replace(" ","_")
                }
                '^.*(\/python)$'
                {
                    $query_type = "PYTHON"
                    $os = "APPLE_OSX"
                    $SensorName = $SensorName.Replace(".py","").Replace(" ","_")
                }
                default
                {
                    $query_type = "BASH"
                    if($scriptPlatform -eq "LINUX"){
                        $os = $scriptPlatform
                    }else{
                        $os = "APPLE_OSX"
                    }
                    $SensorName = $SensorName.Replace(".sh","").Replace(" ","_")
                }
            }
        }
    }

    # Add-Content -Path ./index.md -Value "`n## $SensorName`n"
    # Add-Content -Path ./index.md -Value "| Key | Value |"
    # Add-Content -Path ./index.md -Value "|---|---|"
    # Add-Content -Path ./index.md -Value "| Script Name | $SensorName |"
    # Add-Content -Path ./index.md -Value "| Script Filename | $SensorFileName |"
    # Add-Content -Path ./index.md -Value "| Script Relative Filename | $relativeFileName |"
    # Add-Content -Path ./index.md -Value "| Script Full Name | $SensorFullName |"
    # Add-Content -Path ./index.md -Value "| Query Type | $query_type |"
    # Add-Content -Path ./index.md -Value "| Operating System | $os |"
    # Add-Content -Path ./index.md -Value "| scriptPlatform | $scriptPlatform |"
    # Add-Content -Path ./index.md -Value "| Description | $Description |"
    # Add-Content -Path ./index.md -Value "| Context | $Context |"
    # Add-Content -Path ./index.md -Value "| Architecture | $Architecture |"
    # Add-Content -Path ./index.md -Value "| ResponseType | $ResponseType |"
    # Add-Content -Path ./index.md -Value "| Variables | $Variables |"
    # Add-Content -Path ./index.md -Value "| SensortobeAssigned | $SensortobeAssigned |"
    # Add-Content -Path ./index.md -Value "| SensorAssigned | $SensorAssigned |"

    $data=[uri]::EscapeUriString($relativeFileName)
    Add-Content -Path ./index.md -Value "| $SensorName  | $Description | [$relativeFileName](https://github.com/euc-dev/euc-samples/tree/main/UEM-Samples/Sensors/$data) |"

    $NumSensors--
} while ( $NumSensors -ge 0 )

Write-Host("`n`n*****************************************************************") -ForegroundColor Yellow 
Write-Host("`t`t`t`tProcess Complete") -ForegroundColor Yellow 
Write-Host("`t`t`tPlease review the status messages above") -ForegroundColor Yellow 
Write-Host("*****************************************************************") -ForegroundColor Yellow 
