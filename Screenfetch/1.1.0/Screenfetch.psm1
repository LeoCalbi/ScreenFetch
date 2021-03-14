<#
        .SYNOPSIS
        Display detailed information about your system in the terminal, it also comes with a ASCII logo.
#>
# -----------------------------------------------------------------------------
#                              Screenfetch
# -----------------------------------------------------------------------------

#                              Notes
# -----------------------------------------------------------------------------
# Ispired from Julian Chow edited by Leonardo Calbi
# https://github.com/JulianChow94/Windows-screenFetch

#                               Aliases
# -----------------------------------------------------------------------------

#                              Functions
# -----------------------------------------------------------------------------
Add-Type -AssemblyName System.Windows.Forms
$global:firstTime = $true
Function Screenfetch {
    <#
    .SYNOPSIS
        Get screenfetch with system's informations.
    .INPUTS
        None
    .OUTPUTS
        System.String
    .LINK
        Get-SystemSpecifications
    #>
    [CmdletBinding()]
    param()

    if ($global:firstTime) {
        $global:asciiArt = Get-WindowsArt;
        $global:lineToTitleMappings = Get-LineToTitleMappings;

    }

    $global:systemInfoCollection = Get-SystemSpecifications;
    $global:firstTime = $false;
    if ($global:systemInfoCollection.Count -gt $global:asciiArt.Count) {
        Write-Error "System Specs occupies more lines than the Ascii Art resource selected"
    }
    for ($line = 0; $line -lt $global:asciiArt.Count; $line++) {
        Write-Host $global:asciiArt[$line] -f Cyan -NoNewline;
        Write-Host $global:lineToTitleMappings[$line] -f Red -NoNewline;
        if ($global:systemInfoCollection[$line] -like '*:*') {
            $splitted = $global:systemInfoCollection[$line].Split(":");
            Write-Host ($splitted[0] + ":") -f Red -NoNewline;
            Write-Host $splitted[1];
        }
        else {
            Write-Host $global:systemInfoCollection[$line];
        }
    }
}

Function Get-WindowsArt() {
    [string[]] $ArtArray =
    "                         ....::::       ",
    "                 ....::::::::::::       ",
    "        ....:::: ::::::::::::::::       ",
    "....:::::::::::: ::::::::::::::::       ",
    ":::::::::::::::: ::::::::::::::::       ",
    ":::::::::::::::: ::::::::::::::::       ",
    ":::::::::::::::: ::::::::::::::::       ",
    ":::::::::::::::: ::::::::::::::::       ",
    "................ ................       ",
    ":::::::::::::::: ::::::::::::::::       ",
    ":::::::::::::::: ::::::::::::::::       ",
    ":::::::::::::::: ::::::::::::::::       ",
    "'''':::::::::::: ::::::::::::::::       ",
    "        '''':::: ::::::::::::::::       ",
    "                 ''''::::::::::::       ",
    "                         ''''::::       ",
    "                                        ",
    "                                        ",
    "                                        ";

    return $ArtArray;
}
Function Get-git () {
    $global:dictionary = [ordered]@{
        "User" = Get-UserInformation;
        "OS" = Get-OS;
        "Kernel" = Get-Kernel;
        "Motherboard" = Get-MotherBoardInfo;
        "Shell" = $null;
        "Resolution" = $null;
        "Windows Manager" = Get-WM;
        "Font" = Get-Font;
        "CPU" = Get-CPU;
        "RAM" = $null;
        "Disk" = $null;
    };
    $TitleMappings = @{
        0  = "User: ";
        1  = "OS: ";
        2  = "Kernel: ";
        3  = "Uptime: ";
        4  = "Motherboard: ";
        5  = "Shell: ";
        6  = "Resolution: ";
        7  = "Window Manager: ";
        8  = "Font: ";
        9  = "CPU: ";
        10 = "GPU ";
        11 = "RAM: ";
    };
    return $TitleMappings;
}

Function Get-SystemSpecifications {
    <#
    .SYNOPSIS
        Get system's informations.
    .INPUTS
        None
    .OUTPUTS
        System.Collections.ArrayList
    .LINK
        Get-CimInstance
    #>
    [CmdletBinding()]
    param()
    $global:operatingSystem = Get-CimInstance Win32_OperatingSystem;
    $global:disks = Get-Disks;
    if ($global:firstTime){
        $global:userInfo = Get-UserInformation;
        $global:os = Get-OS;
        $global:kernel = Get-Kernel;
        $global:motherboard = Get-MotherBoardInfo;
        $global:wm = Get-WM;
        $global:font = Get-Font;
        $global:cpu = Get-CPU;
        $global:gpu = Get-GPU;
        $global:firstTime = $false;
    }
    [System.Collections.ArrayList] $global:systemInfoCollection = $global:userInfo,$global:os,$global:kernel,(Get-FormattedUptime),$global:motherboard,(Get-Shell),(Get-DisplaysResolution),$global:wm,$global:font,$global:cpu,$global:gpu,(Get-RAM);

    foreach ($disk in $disks) {
        $global:systemInfoCollection.Add($disk);
    }

    return $global:systemInfoCollection;
}

Function Get-UserInformation() {
    return $ENV:USERNAME + "@" + $global:operatingSystem.CSName;
}
Function Get-OS() {
    return $global:operatingSystem.Caption + " " + $global:operatingSystem.OSArchitecture;
}
Function Get-Kernel() {
    return $global:operatingSystem.Version;
}
Function Get-FormattedUptime() {
    return (Get-Uptime).ToString("dd' d 'hh' h 'mm' m 'ss' s'");
}
Function Get-MotherBoardInfo() {
    $baseboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product
    return $baseboard.Manufacturer + " " + $baseboard.Product;

}
Function Get-Shell() {
    return "PowerShell $($PSVersionTable.PSVersion.ToString())";
}
Function Get-DisplaysResolution() {
    $Displays = New-Object System.Collections.Generic.List[System.Object];
    # This gives the available resolutions
    $Monitors = Get-CimInstance -N "root\wmi" -Class WmiMonitorListedSupportedSourceModes
    foreach ($monitor in $Monitors) {
        # Sort the available modes by display area (width*height)
        $sortedResolutions = $monitor.MonitorSourceModes | Sort-Object -Property { $_.HorizontalActivePixels * $_.VerticalActivePixels }
        $maxResolutions = $sortedResolutions | Select-Object @{N = "MaxRes"; E = { "$($_.HorizontalActivePixels) x $($_.VerticalActivePixels) " } }
        $Displays.Add(($maxResolutions | Select-Object -last 1).MaxRes);
    }
    return $Displays;
}
Function Get-WM() {
    return "DWM";
}
Function Get-Font() {
    return "Delugia Nerd Font";
}
Function Get-CPU() {
    return (((Get-CimInstance Win32_Processor).Name) -replace '\s+', ' ');
}
Function Get-GPU() {
    return (Get-CimInstance Win32_DisplayConfiguration).DeviceName;
}
Function Get-RAM() {
    # Free Physical Memory returns a Kilobyte value while TotalPhysicalMemory a Byte one.
    $FreeRam = $global:operatingSystem.FreePhysicalMemory * 1KB;
    $TotalRam = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory;
    $UsedRam = $TotalRam - $FreeRam;
    $UsedRamPercent = $UsedRam / $TotalRam;

    return Format-Bytes($UsedRam) + "/" + Format-Bytes($TotalRam) + "(" + $UsedRamPercent.ToString('P') + ")";
}
Function Get-Disks() {
    $FormattedDisks = New-Object System.Collections.Generic.List[System.String];
    foreach ($disk in Get-CimInstance Win32_LogicalDisk) {
        $DiskID = $disk.DeviceId;
        $DiskSize = $disk.Size;
        $FreeDiskSize = 0.00;
        $UsedDiskSize = 0.00;
        $UsedDiskPercent = 1.00;
        if ($DiskSize -gt 0) {
            $FreeDiskSize =$disk.FreeSpace;
            $UsedDiskSize = $DiskSize - $FreeDiskSize;
            $UsedDiskPercent = $UsedDiskSize / $DiskSize;
        }
        $FormattedDisk = "Disk " + $DiskID + " " + (Format-Bytes($UsedDiskSize)) + "/" + (Format-Bytes($DiskSizeGB)) + "(" + $UsedDiskPercent.ToString('P') + ")";
        $FormattedDisks.Add($FormattedDisk);
    }
    return $FormattedDisks;
}

Function Format-Bytes {
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [float]$Value
    )
    Begin{
        $sizes = 'KB','MB','GB','TB','PB'
    }
    Process {
        for($x = 0;$x -lt $sizes.count; $x++){
            if ($Value -lt [int64]"1$($sizes[$x])"){
                if ($x -eq 0){
                    return "$Value B"
                } else {
                    $num = $Value / [int64]"1${$sizes[$x-1]}"
                    return $num.ToString('N') + " " + ${$sizes[$x-1]}
                }
            }
        }
    }
}
