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
    [Parameter(Mandatory = $false)] [string] $EnableEmscripten = 'false'
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
    'emscripten'     = $EnableEmscripten    -eq 'true'
}
$androidEnabled = $enabled['android-arm64'] -or $enabled['android-x64']
$iosEnabled     = $enabled['ios-arm64']     -or $enabled['iossimu-arm64']

# release matrix: same combos as package but without artifact-match
$releaseAll = @(
    @{ target='Android'; arch='multi'; os='ubuntu-latest';     'build-type'='debug';   key='android' }
    @{ target='Android'; arch='multi'; os='ubuntu-latest';     'build-type'='release'; key='android' }
    @{ target='iOS';     arch='arm64'; os='macos-latest';      'build-type'='debug';   key='ios-arm64' }
    @{ target='iOS';     arch='arm64'; os='macos-latest';      'build-type'='release'; key='ios-arm64' }
    @{ target='Windows'; arch='x64';   os='windows-latest';   'build-type'='debug';   key='windows-x64' }
    @{ target='Windows'; arch='x64';   os='windows-latest';   'build-type'='release'; key='windows-x64' }
    @{ target='Windows'; arch='arm64'; os='windows-11-arm';   'build-type'='debug';   key='windows-arm64' }
    @{ target='Windows'; arch='arm64'; os='windows-11-arm';   'build-type'='release'; key='windows-arm64' }
    @{ target='MacOS';   arch='arm64'; os='macos-latest';      'build-type'='debug';   key='macos-arm64' }
    @{ target='MacOS';   arch='arm64'; os='macos-latest';      'build-type'='release'; key='macos-arm64' }
    @{ target='MacOS';   arch='x64';   os='macos-26-intel';   'build-type'='debug';   key='macos-x64' }
    @{ target='MacOS';   arch='x64';   os='macos-26-intel';   'build-type'='release'; key='macos-x64' }
    @{ target='Linux';   arch='x64';   os='ubuntu-latest';    'build-type'='debug';   key='linux-x64' }
    @{ target='Linux';   arch='x64';   os='ubuntu-latest';    'build-type'='release'; key='linux-x64' }
    @{ target='Linux';   arch='arm64'; os='ubuntu-24.04-arm'; 'build-type'='debug';   key='linux-arm64' }
    @{ target='Linux';   arch='arm64'; os='ubuntu-24.04-arm'; 'build-type'='release'; key='linux-arm64' }
    @{ target='Emscripten'; arch='wasm32'; os='windows-latest';   'build-type'='debug';   key='emscripten' }
    @{ target='Emscripten'; arch='wasm32'; os='windows-latest';   'build-type'='release'; key='emscripten' }
)
$release = @($releaseAll | Where-Object {
    ($_.key -ne 'android'      -or $androidEnabled) -and
    ($_.key -ne 'ios-arm64'    -or $iosEnabled) -and
    ($_.key -ne 'windows-x64'  -or $enabled['windows-x64']) -and
    ($_.key -ne 'windows-arm64'-or $enabled['windows-arm64']) -and
    ($_.key -ne 'macos-arm64'  -or $enabled['macos-arm64']) -and
    ($_.key -ne 'macos-x64'    -or $enabled['macos-x64']) -and
    ($_.key -ne 'linux-x64'    -or $enabled['linux-x64']) -and
    ($_.key -ne 'linux-arm64'  -or $enabled['linux-arm64']) -and
    ($_.key -ne 'emscripten'   -or $enabled['emscripten'])
} | ForEach-Object { $_.Remove('key'); $_ })

# Ensure ConvertTo-Json receives the array as a whole
$json = ConvertTo-Json -InputObject $release -Compress -Depth 5

Write-Output $json
