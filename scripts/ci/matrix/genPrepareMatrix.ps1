param(
    [Parameter(Mandatory = $false)] [string] $EnableAndroidArm64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableAndroidX64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableIosArm64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableIossimuArm64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableWindowsX64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableWindowsArm64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableMacosArm64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableMacosX64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableLinuxX64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableLinuxArm64 = 'false',
    [Parameter(Mandatory = $false)] [string] $EnableWasm = 'false'
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
    'wasm'           = $EnableWasm          -eq 'true'
}

# prepare-package matrix: one entry per enabled platform/arch (debug preset only)
$prepareAll = @(
    @{ 'target-os'='Android';       arch='arm64'; os='ubuntu-latest';     'cmake-preset'='android-arm64-debug';  key='android-arm64' }
    @{ 'target-os'='Android';       arch='x64';   os='ubuntu-latest';     'cmake-preset'='android-x64-debug';    key='android-x64' }
    @{ 'target-os'='iOS';           arch='arm64'; os='macos-latest';      'cmake-preset'='ios-arm64-debug';      key='ios-arm64' }
    @{ 'target-os'='iOS-Simulator'; arch='arm64'; os='macos-latest';      'cmake-preset'='iossimu-arm64-debug';  key='iossimu-arm64' }
    @{ 'target-os'='Windows';       arch='x64';   os='windows-latest';   'cmake-preset'='windows-x64-debug';    key='windows-x64' }
    @{ 'target-os'='Windows';       arch='arm64'; os='windows-11-arm';   'cmake-preset'='windows-arm64-debug';  key='windows-arm64' }
    @{ 'target-os'='MacOS';         arch='arm64'; os='macos-latest';      'cmake-preset'='osx-arm64-debug';      key='macos-arm64' }
    @{ 'target-os'='MacOS';         arch='x64';   os='macos-26-intel';   'cmake-preset'='osx-x64-debug';        key='macos-x64' }
    @{ 'target-os'='Linux';         arch='x64';   os='ubuntu-latest';    'cmake-preset'='linux-x64-debug';      key='linux-x64' }
    @{ 'target-os'='Linux';         arch='arm64'; os='ubuntu-24.04-arm'; 'cmake-preset'='linux-arm64-debug';    key='linux-arm64'; 'vcpkg-force-system-binaries'=$true }
    @{ 'target-os'='WASM';          arch='wasm32'; os='windows-latest';   'cmake-preset'='wasm-debug';           key='wasm' }
)
$prepare = @($prepareAll | Where-Object { $enabled[$_.key] } | ForEach-Object { $_.Remove('key'); $_ })

# Ensure ConvertTo-Json receives the whole array (use -InputObject)
$json = ConvertTo-Json -InputObject $prepare -Compress -Depth 5

Write-Output $json
