<#
.SYNOPSIS
	验证 CUDA、cuDNN 与 TensorRT 开发库是否完整可用。

.PARAMETER InstallPrefix
	NVIDIA 开发库安装前缀。

.EXAMPLE
	./scripts/ci/setup/verifyNvidiaDevLibs.ps1 -InstallPrefix "$env:RUNNER_TEMP/nvidia-dev"
#>
param(
	[Parameter(Mandatory)][string]$InstallPrefix
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$platformIsWindows = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
$prefix = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InstallPrefix)

if ($platformIsWindows) {
	$bin = Join-Path $prefix 'Library/bin'
	$lib = Join-Path $prefix 'Library/lib'
	$include = Join-Path $prefix 'Library/include'
	$nvccCandidates = @(
		(Join-Path $prefix 'Library/bin/nvcc.exe'),
		(Join-Path $prefix 'bin/nvcc.exe')
	)
	$libraryPatterns = @('cudnn.lib', 'nvinfer.lib')
} else {
	$bin = Join-Path $prefix 'bin'
	$lib = Join-Path $prefix 'lib'
	$include = Join-Path $prefix 'include'
	$nvccCandidates = @(
		(Join-Path $prefix 'bin/nvcc'),
		(Join-Path $prefix 'Library/bin/nvcc')
	)
	$libraryPatterns = @('libcudnn.so*', 'libnvinfer.so*')
}

foreach ($directory in @($bin, $lib, $include)) {
	if (-not (Test-Path $directory -PathType Container)) {
		throw "未找到 NVIDIA 开发库目录: $directory"
	}
}

$nvcc = if ($env:CUDACXX -and (Test-Path $env:CUDACXX -PathType Leaf)) {
	$env:CUDACXX
} else {
	$nvccCandidates |
		Where-Object { Test-Path $_ -PathType Leaf } |
		Select-Object -First 1
}
if (-not $nvcc) {
	throw "未找到 nvcc。已检查: $($nvccCandidates -join ', ')"
}

foreach ($headerName in @('cuda.h', 'cudnn.h', 'NvInfer.h')) {
	$header = Join-Path $include $headerName
	if (-not (Test-Path $header -PathType Leaf)) {
		throw "未找到 NVIDIA 开发头文件: $header"
	}
	Write-Host ":: Found header: $header"
}

foreach ($pattern in $libraryPatterns) {
	$library = Get-ChildItem -Path $lib -File -Filter $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
	if (-not $library) {
		throw "未找到 NVIDIA 运行库 ${pattern}: $lib"
	}
	Write-Host ":: Found library: $($library.FullName)"
}

Write-Host ":: CUDA_PATH=$env:CUDA_PATH"
Write-Host ":: CUDACXX=$nvcc"
Write-Host ":: CUDNN_ROOT=$env:CUDNN_ROOT"
Write-Host ":: TENSORRT_ROOT=$env:TENSORRT_ROOT"
Get-Command nvcc -ErrorAction Stop | Format-List Name,Source
& $nvcc --version
if ($LASTEXITCODE -ne 0) {
	throw "nvcc 无法执行: $nvcc"
}

Write-Host ':: CUDA/cuDNN/TensorRT 验证成功'
