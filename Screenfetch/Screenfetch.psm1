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
$global:firstRun = $true

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
    Param()
    $colorsConfig = @{"Art" = "Cyan"; "Key" = "Red"; "Value" = "White" }
    if ($global:firstRun) {
        $global:asciiArt = Get-WindowsArt;
        $global:colors = [enum]::GetValues([System.ConsoleColor])
        $global:emptyline = "                                        ";
    }
    Get-Informations;
    $line = 0;
    foreach ($key in $global:dictionary.Keys) {
        foreach ($value in $global:dictionary[$key]) {
            if ($line -lt $global:asciiArt.Count) {
                Write-Host $global:asciiArt[$line] -f $colorsConfig.Art -NoNewline;
            }
            else {
                Write-Host $global:emptyline -NoNewline;
            }
            $line ++;
            if ($global:dictionary[$key].Count -eq 1) {
                Write-Host ($key + ": ") -f $colorsConfig.Key -NoNewline;
                Write-Host $value -f $colorsConfig.Value;
            }
            else {
                $splitted = $value.Split(":", 2);
                Write-Host ($splitted[0] + ":") -f $colorsConfig.Key -NoNewline;
                Write-Host $splitted[1] -f $colorsConfig.Value;
            }
        }
    }
    for ($l = $line; $l -lt $global:asciiArt.Count; $l++) {
        Write-Host $global:asciiArt[$l] -f $colorsConfig.Art;
    }
    Write-Host $global:emptyline -NoNewline;
    for ($c = 0; $c -lt $global:colors.Count; $c++) {
        Write-Host "  " -ForegroundColor $global:colors[$c] -BackgroundColor $global:colors[$c] -NoNewline;
    }
    Write-Host "";
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
    "                         ''''::::       ";

    return $ArtArray;
}
Function Get-Informations {
    <#
    .SYNOPSIS
        Get system's informations.
    .INPUTS
        None
    .OUTPUTS
        System.Dictionary
    #>
    param()
    $global:operatingSystem = Get-CimInstance Win32_OperatingSystem;
    if ($global:firstRun) {
        $global:dictionary = [ordered]@{
            "User"            = Get-UserInformation;
            "OS"              = Get-OS;
            "Kernel"          = Get-Kernel;
            "Uptime"          = $null;
            "Motherboard"     = Get-MotherBoardInfo;
            "Shell"           = Get-Shell;
            "Display"         = $null;
            "Windows Manager" = Get-WM;
            "Font"            = $null;
            "CPU"             = Get-CPU;
            "GPU"             = Get-GPU;
            "RAM"             = $null;
            "Disk"            = $null;
        };
        $global:firstRun = $false;
    }
    $global:dictionary["Uptime"] = Get-FormattedUptime;
    $global:dictionary["Display"] = Get-DisplaysResolution;
    $global:dictionary["Font"] = Get-Font;
    $global:dictionary["RAM"] = Get-RAM;
    $global:dictionary["Disk"] = Get-Disks;
}
Function Get-UserInformation {
    Param()
    return $ENV:USERNAME + "@" + $global:operatingSystem.CSName;
}
Function Get-OS {
    Param()
    return $global:operatingSystem.Caption + " " + $global:operatingSystem.OSArchitecture;
}
Function Get-Kernel {
    Param()
    return $global:operatingSystem.Version;
}
Function Get-FormattedUptime {
    Param()
    return (Get-Uptime).ToString("dd' d 'hh' h 'mm' m 'ss' s'");
}
Function Get-MotherBoardInfo {
    Param()
    $baseboard = Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product;
    return $baseboard.Manufacturer + " " + $baseboard.Product;
}
Function Get-Shell {
    Param()
    return "PowerShell " + $PSVersionTable.PSVersion.ToString();
}
Function Get-DisplaysResolution {
    Param()
    $Displays = New-Object System.Collections.Generic.List[System.String];
    $Monitors = [System.Windows.Forms.Screen]::AllScreens | Sort-Object Primary -Descending
    for ($i = 0; $i -lt $Monitors.Count; $i++) {
        $monitor = $Monitors.Get($i);
        $formattedMon = "Display " + ($i + 1) + ": " + $monitor.Bounds.Size.Width + " x " + $monitor.Bounds.Size.Height;
        $Displays.Add($formattedMon);
    }
    return $Displays;
}
Function Get-WM {
    Param()
    return "DWM";
}
Function Get-Font {
    Param()
    return Get-ItemPropertyValue "HKCU:\Console" -Name FaceName;
}
Function Get-CPU {
    Param()
    return (((Get-CimInstance Win32_Processor).Name) -replace '\s+', ' ');
}
Function Get-GPU {
    Param()
    return (Get-CimInstance Win32_DisplayConfiguration).DeviceName;
}
Function Get-RAM {
    Param()
    # Free Physical Memory returns a Kilobyte value while TotalPhysicalMemory a Byte one.
    $TotalRam = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory;
    $UsedRam = $TotalRam - ($global:operatingSystem.FreePhysicalMemory * 1KB);
    $UsedRamPercent = $UsedRam / $TotalRam;
    return (Format-Bytes($UsedRam)) + "/" + (Format-Bytes($TotalRam)) + " (" + $UsedRamPercent.ToString('P') + ")";
}
Function Get-Disks {
    Param()
    $FormattedDisks = New-Object System.Collections.Generic.List[System.String];
    foreach ($disk in (Get-CimInstance Win32_LogicalDisk)) {
        $DiskID = $disk.DeviceId;
        $DiskSize = $disk.Size;
        $FreeDiskSize = 0.00;
        $UsedDiskSize = 0.00;
        $UsedDiskPercent = 1.00;
        if ($DiskSize -gt 0) {
            $FreeDiskSize = $disk.FreeSpace;
            $UsedDiskSize = $DiskSize - $FreeDiskSize;
            $UsedDiskPercent = $UsedDiskSize / $DiskSize;
        }
        $FormattedDisk = "Disk " + $DiskID + " " + (Format-Bytes($UsedDiskSize)) + "/" + (Format-Bytes($DiskSize)) + " (" + $UsedDiskPercent.ToString('P') + ")";
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
    Begin {
        $sizes = 'KB', 'MB', 'GB', 'TB', 'PB'
    }
    Process {
        for ($x = 0; $x -lt $sizes.count; $x++) {
            $biggerSize = [int64]("1" + $sizes[$x])
            if ($Value -lt $biggerSize) {
                if ($x -eq 0) {
                    return $Value.Tostring() + " B"
                }
                else {
                    $size = [int64]("1" + $sizes[$x - 1])
                    $num = $Value / $size
                    return $num.ToString('N') + " " + $sizes[$x - 1]
                }
            }
        }
    }
}
