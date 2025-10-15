Add-Type -AssemblyName System.IO.Compression.FileSystem

$stream = [System.IO.MemoryStream]::new((New-Object System.Net.WebClient).DownloadData(
        'https://github.com/OpenCageData/address-formatting/archive/refs/heads/master.zip'
    ))

$zip = New-Object System.IO.Compression.ZipArchive($stream)

foreach ($dir in @(
        , @('conf', '..\conf')
        , @('testcases', '..\Tests\testcases')
    )
) {
    $target = Join-Path $PSScriptRoot $dir[1]

    if (Test-Path $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
    }

    New-Item -ItemType Directory -Path $target | Out-Null

    $prefix = "address-formatting-master/$($dir[0])/"

    $zip.Entries | Where-Object { $_.FullName -like "$prefix*" -and $_.Name } | ForEach-Object {
        $dest = Join-Path $target $_.FullName.Substring($prefix.Length)
        if (-not(Test-Path ($p = Split-Path $dest -Parent))) { New-Item -ItemType Directory -Path $p | Out-Null }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $dest, $true)
    }
}