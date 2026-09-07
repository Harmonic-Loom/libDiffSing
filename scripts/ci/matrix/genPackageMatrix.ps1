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
    @{ target='WASM';    arch='wasm32'; os='windows-latest';   'build-type'='debug';   'artifact-match'='wasm';         key='wasm' }
    @{ target='WASM';    arch='wasm32'; os='windows-latest';   'build-type'='release'; 'artifact-match'='wasm';         key='wasm' }
)
$package = @($packageAll | Where-Object {
    ($_.key -ne 'android'      -or $androidEnabled) -and
    ($_.key -ne 'ios-arm64'    -or $iosEnabled) -and
    ($_.key -ne 'windows-x64'  -or $enabled['windows-x64']) -and
    ($_.key -ne 'windows-arm64'-or $enabled['windows-arm64']) -and
    ($_.key -ne 'macos-arm64'  -or $enabled['macos-arm64']) -and
    ($_.key -ne 'macos-x64'    -or $enabled['macos-x64']) -and
    ($_.key -ne 'linux-x64'    -or $enabled['linux-x64']) -and
    ($_.key -ne 'linux-arm64'  -or $enabled['linux-arm64']) -and
    ($_.key -ne 'wasm'         -or $enabled['wasm'])
} | ForEach-Object { $_.Remove('key'); $_ })

# Ensure ConvertTo-Json receives the array as a whole
$json = ConvertTo-Json -InputObject $package -Compress -Depth 5

Write-Output $json
