# Tijdelijk het uitvoeringsbeleid instellen op RemoteSigned
$oldExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope Process

# Pad naar het bureaublad van de huidige gebruiker
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Bestandsnaam voor de output
$outputFile = Join-Path -Path $desktopPath -ChildPath "SystemInfo.txt"

# Moederbord merk en type
$moederbord = Get-WmiObject Win32_BaseBoard
$moederbordInfo = "Moederbord: $($moederbord.Manufacturer) $($moederbord.Product)"

# BIOS versie
$bios = Get-WmiObject Win32_BIOS
$biosVersion = "BIOS versie: $($bios.SMBIOSBIOSVersion)"

# Windows versie
$windowsVersion = "Windows versie: $(Get-WmiObject Win32_OperatingSystem).Caption"

# RAM informatie
$ram = Get-WmiObject Win32_PhysicalMemory
$ramCapacity = ($ram | Measure-Object Capacity -Sum).Sum
$ramGB = [math]::Round($ramCapacity / 1GB, 2)
$ramInfo = "RAM: $ramGB GB"

# CPU informatie
$cpu = Get-WmiObject Win32_Processor
$cpuInfo = "CPU: $($cpu.Name)"

# Videokaart informatie
$videokaart = Get-WmiObject Win32_VideoController
$videokaartInfo = "Videokaart: $($videokaart.Name)"

# HDD/SSD informatie
$hdd = Get-WmiObject Win32_DiskDrive
$hddInfo = "HDD/SSD: $($hdd.Model)"

# USB-schijven informatie
$usbSchijven = Get-WmiObject Win32_DiskDrive | Where-Object { $_.InterfaceType -eq "USB" }
$usbSchijvenInfo = foreach ($usbSchijf in $usbSchijven) {
    "USB-schijf: $($usbSchijf.Model)"
}

# Alle informatie samenstellen
$systemInfo = @"
$moederbordInfo
$biosVersion
$windowsVersion
$ramInfo
$cpuInfo
$videokaartInfo
$hddInfo

Aangesloten USB-schijven:
$usbSchijvenInfo
"@

# Output naar bestand schrijven
$systemInfo | Out-File -FilePath $outputFile

# Melding aan de gebruiker
Write-Host "Systeeminformatie is opgeslagen in: $outputFile"

# Herstel het oorspronkelijke uitvoeringsbeleid
Set-ExecutionPolicy $oldExecutionPolicy -Scope Process
