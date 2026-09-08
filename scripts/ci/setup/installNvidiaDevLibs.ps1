<#
.SYNOPSIS
	在 Windows/Linux x64 上下载并安装 CUDA 12.8、cuDNN 9.x 与 TensorRT 10.9 开发库（基于 micromamba + conda 包）。

.DESCRIPTION
	- Windows: win-64
	- Linux: linux-64
	- 仅支持 x64 架构。
	- 安装到指定前缀目录，不会修改系统级 CUDA。
	- 如在 GitHub Actions 中运行，会把关键环境变量写入 GITHUB_ENV。

.PARAMETER InstallPrefix
	安装前缀目录。

.PARAMETER CudaSpec
	CUDA 包版本约束，默认 12.8.*。

.PARAMETER CudnnSpec
	cuDNN 包版本约束，默认 >=9,<10。

.PARAMETER TensorRtSpec
	TensorRT 包版本约束，默认 10.9.*。

.PARAMETER Force
	强制重建环境（先删除安装目录）。

.EXAMPLE
	./scripts/ci/setup/installNvidiaDevLibs.ps1

.EXAMPLE
	./scripts/ci/setup/installNvidiaDevLibs.ps1 -InstallPrefix "C:/nvidia/dev" -Force
#>
param(
	[string]$InstallPrefix = $(if ($IsWindows) { 'C:/nvidia/dev' } else { '/opt/nvidia/dev' }),
	[string]$CudaSpec = 'cuda-toolkit=12.8.*',
	[string]$CudnnSpec = 'cudnn>=9,<10',
	[string]$TensorRtSpec = 'tensorrt=10.9.*',
	[switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-SupportedPlatform {
	if (-not ($IsWindows -or $IsLinux)) {
		throw "仅支持 Windows 或 Linux，当前平台不受支持。"
	}

	if ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -ne [System.Runtime.InteropServices.Architecture]::X64) {
		throw "仅支持 x64，当前架构: $([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture)"
	}
}

function Invoke-DownloadFile {
	param(
		[Parameter(Mandatory)][string]$Url,
		[Parameter(Mandatory)][string]$OutputPath
	)

	Write-Host ":: Downloading $Url"
	$parent = Split-Path -Parent $OutputPath
	if (-not (Test-Path $parent)) {
		New-Item -ItemType Directory -Path $parent | Out-Null
	}

	Invoke-WebRequest -Uri $Url -OutFile $OutputPath
	if (-not (Test-Path $OutputPath)) {
		throw "下载失败: $Url"
	}
}

function Get-MicromambaExe {
	param([Parameter(Mandatory)][string]$WorkDir)

	$platform = if ($IsWindows) { 'win-64' } else { 'linux-64' }
	$archive = Join-Path $WorkDir "micromamba-$platform.tar.bz2"
	$extract = Join-Path $WorkDir 'micromamba'
	$url = "https://micro.mamba.pm/api/micromamba/$platform/latest"

	Invoke-DownloadFile -Url $url -OutputPath $archive

	if (Test-Path $extract) {
		Remove-Item -Recurse -Force $extract
	}
	New-Item -ItemType Directory -Path $extract | Out-Null

	& tar -xjf $archive -C $extract
	if ($LASTEXITCODE -ne 0) {
		throw "解压 micromamba 失败。"
	}

	$exe = if ($IsWindows) {
		Join-Path $extract 'Library/bin/micromamba.exe'
	} else {
		Join-Path $extract 'bin/micromamba'
	}

	if (-not (Test-Path $exe)) {
		throw "未找到 micromamba 可执行文件: $exe"
	}

	return $exe
}

function Export-EnvForCurrentSession {
	param([Parameter(Mandatory)][string]$Prefix)

	if ($IsWindows) {
		$bin = Join-Path $Prefix 'Library/bin'
		$lib = Join-Path $Prefix 'Library/lib'
		$include = Join-Path $Prefix 'Library/include'
	} else {
		$bin = Join-Path $Prefix 'bin'
		$lib = Join-Path $Prefix 'lib'
		$include = Join-Path $Prefix 'include'
	}

	if (-not (Test-Path $bin)) { throw "未找到 bin 目录: $bin" }
	if (-not (Test-Path $lib)) { throw "未找到 lib 目录: $lib" }
	if (-not (Test-Path $include)) { throw "未找到 include 目录: $include" }

	if ($IsWindows) {
		$env:PATH = "$bin;$($env:PATH)"
	} else {
		$env:PATH = "${bin}:$($env:PATH)"
		$env:LD_LIBRARY_PATH = "${lib}:$($env:LD_LIBRARY_PATH)"
	}

	$env:CUDA_PATH = $Prefix
	$env:CUDNN_ROOT = $Prefix
	$env:TENSORRT_ROOT = $Prefix

	if ($env:GITHUB_ENV) {
		"CUDA_PATH=$Prefix" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
		"CUDNN_ROOT=$Prefix" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
		"TENSORRT_ROOT=$Prefix" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

		if ($IsWindows) {
			"PATH=$bin;$env:PATH" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
		} else {
			"PATH=${bin}:$env:PATH" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
			"LD_LIBRARY_PATH=${lib}:$env:LD_LIBRARY_PATH" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
		}

		Write-Host ':: 环境变量已写入 GITHUB_ENV'
	}
}

Assert-SupportedPlatform

$prefix = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InstallPrefix)
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'nvidia-devlibs-install'

if ($Force -and (Test-Path $prefix)) {
	Write-Host ":: Removing existing prefix: $prefix"
	Remove-Item -Recurse -Force $prefix
}

if (-not (Test-Path $tempRoot)) {
	New-Item -ItemType Directory -Path $tempRoot | Out-Null
}

$micromamba = Get-MicromambaExe -WorkDir $tempRoot

Write-Host ":: Installing packages to $prefix"
& $micromamba create --yes --prefix $prefix -c nvidia -c conda-forge $CudaSpec $CudnnSpec $TensorRtSpec
if ($LASTEXITCODE -ne 0) {
	throw "micromamba create 失败，退出码: $LASTEXITCODE"
}

Export-EnvForCurrentSession -Prefix $prefix

Write-Host ':: CUDA/cuDNN/TensorRT 开发库安装完成。'
& $micromamba list --prefix $prefix | Select-String -Pattern 'cuda-toolkit|cudnn|tensorrt' | ForEach-Object { Write-Host $_ }
