param (
    $version = "latest",
    $system = "windows"
)

# References:
# https://gist.github.com/MarkTiedemann/c0adc1701f3f5c215fc2c2d5b1d5efd3
function Get-Latest-Release {
    param (
        [Parameter(Position=0)]
        [string]$repo
    )
    return (Invoke-WebRequest "https://api.github.com/repos/$repo/releases/latest" | ConvertFrom-Json)[0].tag_name
}

$repo = "ffizer/ffizer"

# Get latest version
if ( $version -ieq "latest") {
    $version = Get-Latest-Release $repo
}

# Get file name
if ( $system -ieq "darwin" ) {
  $zip_filename = "ffizer_${version}-x86_64-apple-darwin.tgz"
} elseif ( $system -ieq "linux" ) {
  $zip_filename = "ffizer_${version}-x86_64-unknown-linux-musl.tgz"
} elseif ( $system -ieq "windows" ) {
  $zip_filename = "ffizer_${version}-x86_64-pc-windows-msvc.zip"
}

# Download
$download_url = "https://github.com/${repo}/releases/download/${version}/${zip_filename}"
if ( $system -ieq "windows" ) {
    $temp_file = "temp.zip"
} else {
    $temp_file = "temp.tar.gz"
}
Invoke-WebRequest $download_url -Out $temp_file

# Extract archives
if ( $system -ieq "windows" ) {
  Expand-Archive $temp_file -DestinationPath . -Force
} else {
  tar -zxf $temp_file
}

# Clean up
Remove-Item $temp_file -Force
