param(
    [Parameter(Mandatory = $true)] [string] $EnableAndroidArm64,
    [Parameter(Mandatory = $true)] [string] $EnableAndroidX64,
    [Parameter(Mandatory = $true)] [string] $EnableIosArm64,
    [Parameter(Mandatory = $true)] [string] $EnableIossimuArm64,
    [Parameter(Mandatory = $true)] [string] $EnableWindowsX64,
    [Parameter(Mandatory = $true)] [string] $EnableWindowsArm64,
    [Parameter(Mandatory = $true)] [string] $EnableMacosArm64,
    [Parameter(Mandatory = $true)] [string] $EnableMacosX64,
    [Parameter(Mandatory = $true)] [string] $EnableLinuxX64,
    [Parameter(Mandatory = $true)] [string] $EnableLinuxArm64
)

$enabled = @{
    'android-arm64'  = $EnableAndroidArm64  -eq 'true'
    'android-x64'    = $EnableAndroidX64    -eq 'true'
    'ios-arm64'      = $EnableIosArm64      -eq 'true'
    'iossimu-arm64'  = $EnableIossimuArm64  -eq 'true'
    'windows-x64'    = $EnableWindowsX64    -eq 'true'
    'windows-arm64'  = $EnableWindowsArm64  -eq 'true'
    'macos-arm64'    = $EnableMacosArm64    -eq 'true'
    'macos-x64'      = $EnableMacosX64      -eq 'true'
    'linux-x64'      = $EnableLinuxX64      -eq 'true'
    'linux-arm64'    = $EnableLinuxArm64    -eq 'true'
}
$androidEnabled = $enabled['android-arm64'] -or $enabled['android-x64']
$iosEnabled     = $enabled['ios-arm64']     -or $enabled['iossimu-arm64']

# package matrix: includes artifact-match for the package job
$packageAll = @(
    @{ target='Android'; arch='multi'; os='ubuntu-latest';     'build-type'='debug';   'artifact-match'='android-*64';   key='android' }
    @{ target='Android'; arch='multi'; os='ubuntu-latest';     'build-type'='release'; 'artifact-match'='android-*64';   key='android' }
    @{ target='iOS';     arch='arm64'; os='macos-latest';      'build-type'='debug';   'artifact-match'='ios*-arm64';    key='ios-arm64' }
    @{ target='iOS';     arch='arm64'; os='macos-latest';      'build-type'='release'; 'artifact-match'='ios*-arm64';    key='ios-arm64' }
    @{ target='Windows'; arch='x64';   os='windows-latest';   'build-type'='debug';   'artifact-match'='windows-x64';   key='windows-x64' }
    @{ target='Windows'; arch='x64';   os='windows-latest';   'build-type'='release'; 'artifact-match'='windows-x64';   key='windows-x64' }
    @{ target='Windows'; arch='arm64'; os='windows-11-arm';   'build-type'='debug';   'artifact-match'='windows-arm64'; key='windows-arm64' }
    @{ target='Windows'; arch='arm64'; os='windows-11-arm';   'build-type'='release'; 'artifact-match'='windows-arm64'; key='windows-arm64' }
    @{ target='MacOS';   arch='arm64'; os='macos-latest';      'build-type'='debug';   'artifact-match'='osx-arm64';     key='macos-arm64' }
    @{ target='MacOS';   arch='arm64'; os='macos-latest';      'build-type'='release'; 'artifact-match'='osx-arm64';     key='macos-arm64' }
    @{ target='MacOS';   arch='x64';   os='macos-26-intel';   'build-type'='debug';   'artifact-match'='osx-x64';       key='macos-x64' }
    @{ target='MacOS';   arch='x64';   os='macos-26-intel';   'build-type'='release'; 'artifact-match'='osx-x64';       key='macos-x64' }
    @{ target='Linux';   arch='x64';   os='ubuntu-latest';    'build-type'='debug';   'artifact-match'='linux-x64';     key='linux-x64' }
    @{ target='Linux';   arch='x64';   os='ubuntu-latest';    'build-type'='release'; 'artifact-match'='linux-x64';     key='linux-x64' }
    @{ target='Linux';   arch='arm64'; os='ubuntu-24.04-arm'; 'build-type'='debug';   'artifact-match'='linux-arm64';   key='linux-arm64' }
    @{ target='Linux';   arch='arm64'; os='ubuntu-24.04-arm'; 'build-type'='release'; 'artifact-match'='linux-arm64';   key='linux-arm64' }
)
$package = $packageAll | Where-Object {
    ($_.key -ne 'android'      -or $androidEnabled) -and
    ($_.key -ne 'ios-arm64'    -or $iosEnabled) -and
    ($_.key -ne 'windows-x64'  -or $enabled['windows-x64']) -and
    ($_.key -ne 'windows-arm64'-or $enabled['windows-arm64']) -and
    ($_.key -ne 'macos-arm64'  -or $enabled['macos-arm64']) -and
    ($_.key -ne 'macos-x64'    -or $enabled['macos-x64']) -and
    ($_.key -ne 'linux-x64'    -or $enabled['linux-x64']) -and
    ($_.key -ne 'linux-arm64'  -or $enabled['linux-arm64'])
} | ForEach-Object { $_.Remove('key'); $_ }

$json = ($package | ConvertTo-Json -Compress -Depth 5)
if ($package.Count -eq 1) { $json = "[$json]" }

Write-Output $json
