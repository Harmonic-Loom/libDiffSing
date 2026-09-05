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

# build matrix: one entry per enabled platform/arch x Debug/Release
$buildAll = @(
    @{ 'target-os'='Android';       arch='arm64'; os='ubuntu-latest';     'build-type'='Debug';   'cmake-preset'='android-arm64-debug';    'lib-path'='debug/lib'; key='android-arm64' }
    @{ 'target-os'='Android';       arch='arm64'; os='ubuntu-latest';     'build-type'='Release'; 'cmake-preset'='android-arm64-release';  'lib-path'='lib';       key='android-arm64' }
    @{ 'target-os'='Android';       arch='x64';   os='ubuntu-latest';     'build-type'='Debug';   'cmake-preset'='android-x64-debug';      'lib-path'='debug/lib'; key='android-x64' }
    @{ 'target-os'='Android';       arch='x64';   os='ubuntu-latest';     'build-type'='Release'; 'cmake-preset'='android-x64-release';    'lib-path'='lib';       key='android-x64' }
    @{ 'target-os'='iOS';           arch='arm64'; os='macos-latest';      'build-type'='Debug';   'cmake-preset'='ios-arm64-debug';         'lib-path'='debug/lib'; key='ios-arm64' }
    @{ 'target-os'='iOS';           arch='arm64'; os='macos-latest';      'build-type'='Release'; 'cmake-preset'='ios-arm64-release';       'lib-path'='lib';       key='ios-arm64' }
    @{ 'target-os'='iOS-Simulator'; arch='arm64'; os='macos-latest';      'build-type'='Debug';   'cmake-preset'='iossimu-arm64-debug';     'lib-path'='debug/lib'; key='iossimu-arm64' }
    @{ 'target-os'='iOS-Simulator'; arch='arm64'; os='macos-latest';      'build-type'='Release'; 'cmake-preset'='iossimu-arm64-release';   'lib-path'='lib';       key='iossimu-arm64' }
    @{ 'target-os'='Windows';       arch='x64';   os='windows-latest';   'build-type'='Debug';   'cmake-preset'='windows-x64-debug';      'lib-path'='debug/bin'; key='windows-x64' }
    @{ 'target-os'='Windows';       arch='x64';   os='windows-latest';   'build-type'='Release'; 'cmake-preset'='windows-x64-release';    'lib-path'='bin';       key='windows-x64' }
    @{ 'target-os'='Windows';       arch='arm64'; os='windows-11-arm';   'build-type'='Debug';   'cmake-preset'='windows-arm64-debug';    'lib-path'='debug/bin'; key='windows-arm64' }
    @{ 'target-os'='Windows';       arch='arm64'; os='windows-11-arm';   'build-type'='Release'; 'cmake-preset'='windows-arm64-release';  'lib-path'='bin';       key='windows-arm64' }
    @{ 'target-os'='MacOS';         arch='arm64'; os='macos-latest';      'build-type'='Debug';   'cmake-preset'='osx-arm64-debug';        'lib-path'='debug/lib'; key='macos-arm64' }
    @{ 'target-os'='MacOS';         arch='arm64'; os='macos-latest';      'build-type'='Release'; 'cmake-preset'='osx-arm64-release';      'lib-path'='lib';       key='macos-arm64' }
    @{ 'target-os'='MacOS';         arch='x64';   os='macos-26-intel';   'build-type'='Debug';   'cmake-preset'='osx-x64-debug';          'lib-path'='debug/lib'; key='macos-x64' }
    @{ 'target-os'='MacOS';         arch='x64';   os='macos-26-intel';   'build-type'='Release'; 'cmake-preset'='osx-x64-release';        'lib-path'='lib';       key='macos-x64' }
    @{ 'target-os'='Linux';         arch='x64';   os='ubuntu-latest';    'build-type'='Debug';   'cmake-preset'='linux-x64-debug';        'lib-path'='debug/lib'; key='linux-x64' }
    @{ 'target-os'='Linux';         arch='x64';   os='ubuntu-latest';    'build-type'='Release'; 'cmake-preset'='linux-x64-release';      'lib-path'='lib';       key='linux-x64' }
    @{ 'target-os'='Linux';         arch='arm64'; os='ubuntu-24.04-arm'; 'build-type'='Debug';   'cmake-preset'='linux-arm64-debug';      'lib-path'='debug/lib'; key='linux-arm64'; 'vcpkg-force-system-binaries'=$true }
    @{ 'target-os'='Linux';         arch='arm64'; os='ubuntu-24.04-arm'; 'build-type'='Release'; 'cmake-preset'='linux-arm64-release';    'lib-path'='lib';       key='linux-arm64'; 'vcpkg-force-system-binaries'=$true }
)
$build = $buildAll | Where-Object { $enabled[$_.key] } | ForEach-Object { $_.Remove('key'); $_ }

$json = ($build | ConvertTo-Json -Compress -Depth 5)
if ($build.Count -eq 1) { $json = "[$json]" }

Write-Output $json
