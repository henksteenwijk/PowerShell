# Functie om recursief te zoeken voor video bestanden op de geselecteerde schijf.
function Search-MovieFiles {
    param (
        [string]$Drive
    )

    $movieFormats = "*.mov","*.mpeg","*.mpg","*.divx","*.mkv","*.avi","*.mp4"
    $movieFiles = @()

    foreach ($format in $movieFormats) {
        $movieFiles += Get-ChildItem -Path $Drive -Recurse -Filter $format -ErrorAction SilentlyContinue | Select-Object FullName, Length, @{Name="Format";Expression={$format.TrimStart("*.")}}
    }

    return $movieFiles
}

# Functie om een export txt file aan te maken
function Create-TextReport {
    param (
        [array]$MovieFiles,
        [string]$Drive
    )

    $reportContent = @()
    $reportContent += "Movie files found on drive " + $Drive + "`r`n"

    foreach ($movie in $MovieFiles) {
        $fileSizeMB = [math]::Round(($movie.Length / 1MB), 2)
        $fileInfo = "Location: $($movie.FullName | Split-Path -Parent), Name: $($movie.FullName | Split-Path -Leaf), Size: $fileSizeMB MB, File type: $($movie.Format)"
        $reportContent += $fileInfo
    }

    $reportContent += "`r`nTotal number of movie files found: $($MovieFiles.Count)"

    $reportFileName = "movie_scan_$Drive_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $reportPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), $reportFileName)

    $reportContent | Out-File -FilePath $reportPath

    Write-Output "Text report saved on the desktop."
}

# Hoofd script
$drives = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object -ExpandProperty DeviceID
$selectedDrive = $drives | Out-GridView -Title "Select a drive" -OutputMode Single

if ($selectedDrive) {
    $movieFiles = Search-MovieFiles -Drive $selectedDrive
    if ($movieFiles) {
        Create-TextReport -MovieFiles $movieFiles -Drive $selectedDrive
    } else {
        Write-Output "No movie files found on drive $selectedDrive."
    }
} else {
    Write-Output "No drive selected."
}
