# Screenfetch

A powershell Module to get Windows system informations.

My fork of Julian Chow's [Windows screenfetch](https://github.com/JulianChow94/Windows-screenFetch), adapted to be used with the new `Get-CimInstance`, a slight speed up with some global variables on fixed informations of the system, and a documentation upgrade with powershell [Module Manifest](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/new-modulemanifest?view=powershell-7.1).

## ✨ Informations

Using the command `Screenfetch` you can obtain the following system information along side an ASCII's Art Logo:

* User: User@Computer-Name
* OS: Type of OS and Version
* Kernel: Kernel Version
* Uptime: Current computer uptime
* Motherboard: Motherboard specifications
* Shell: Shell version
* Displays: Current attached displays resolutions, the first is the primary monitor
* Windows Manager: Default Windows Manager
* Font: Used font, must be set in the script currently
* CPU: CPU Specifications
* GPU: GPU Specifications
* RAM: Used Memory / Total Memory (Percentage of used memory)
* Disks: Current Disks attached names, and their space informations
* Colors: A color demo of the terminal.
