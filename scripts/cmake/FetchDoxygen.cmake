# FetchDoxygen.cmake
# 自动查找或下载 Doxygen 预构建二进制文件
#
# 用法:
#   include(scripts/cmake/FetchDoxygen.cmake)
#   if(DOXYGEN_FOUND)
#       # 使用 ${DOXYGEN_EXECUTABLE}
#   endif()

set(DOXYGEN_DOWNLOAD_VERSION "1.13.2" CACHE STRING "Doxygen version to download if not found")

# 优先使用系统已安装的 Doxygen
find_package(Doxygen QUIET)
if(DOXYGEN_FOUND)
	message(STATUS "Found system Doxygen: ${DOXYGEN_EXECUTABLE} (${DOXYGEN_VERSION})")
	return()
endif()

message(STATUS "System Doxygen not found, downloading v${DOXYGEN_DOWNLOAD_VERSION}...")

set(_DOXYGEN_BASE_DIR "${CMAKE_BINARY_DIR}/_deps/doxygen-${DOXYGEN_DOWNLOAD_VERSION}")

# 平台检测与 URL 设置
if(CMAKE_HOST_WIN32)
	set(_DOXYGEN_ARCHIVE_NAME "doxygen-${DOXYGEN_DOWNLOAD_VERSION}.windows.x64.bin.zip")
	set(_DOXYGEN_EXE_PATH "${_DOXYGEN_BASE_DIR}/doxygen.exe")
elseif(CMAKE_HOST_UNIX AND NOT CMAKE_HOST_APPLE)
	set(_DOXYGEN_ARCHIVE_NAME "doxygen-${DOXYGEN_DOWNLOAD_VERSION}.linux.bin.tar.gz")
	set(_DOXYGEN_EXE_PATH "${_DOXYGEN_BASE_DIR}/bin/doxygen")
else()
	message(STATUS "Auto-download not supported on this platform, please install Doxygen manually")
	return()
endif()

set(_DOXYGEN_URL "https://www.doxygen.nl/files/${_DOXYGEN_ARCHIVE_NAME}")
set(_DOXYGEN_ARCHIVE_PATH "${_DOXYGEN_BASE_DIR}/${_DOXYGEN_ARCHIVE_NAME}")

if(NOT EXISTS "${_DOXYGEN_EXE_PATH}")
	# 下载
	if(NOT EXISTS "${_DOXYGEN_ARCHIVE_PATH}")
		message(STATUS "Downloading ${_DOXYGEN_URL}")
		file(MAKE_DIRECTORY "${_DOXYGEN_BASE_DIR}")
		file(DOWNLOAD
			"${_DOXYGEN_URL}"
			"${_DOXYGEN_ARCHIVE_PATH}"
			STATUS _DOWNLOAD_STATUS
			SHOW_PROGRESS
		)
		list(GET _DOWNLOAD_STATUS 0 _STATUS_CODE)
		list(GET _DOWNLOAD_STATUS 1 _STATUS_MSG)
		if(NOT _STATUS_CODE EQUAL 0)
			message(WARNING "Doxygen download failed (${_STATUS_CODE}): ${_STATUS_MSG}")
			file(REMOVE "${_DOXYGEN_ARCHIVE_PATH}")
			return()
		endif()
	endif()

	# 解压
	message(STATUS "Extracting Doxygen to ${_DOXYGEN_BASE_DIR}")
	file(ARCHIVE_EXTRACT
		INPUT "${_DOXYGEN_ARCHIVE_PATH}"
		DESTINATION "${_DOXYGEN_BASE_DIR}"
	)

	# 删除归档文件节省空间
	file(REMOVE "${_DOXYGEN_ARCHIVE_PATH}")
endif()

# 验证
if(EXISTS "${_DOXYGEN_EXE_PATH}")
	set(DOXYGEN_FOUND TRUE)
	set(DOXYGEN_EXECUTABLE "${_DOXYGEN_EXE_PATH}" CACHE FILEPATH "Doxygen executable" FORCE)
	message(STATUS "Using downloaded Doxygen: ${DOXYGEN_EXECUTABLE}")
else()
	message(WARNING "Doxygen extraction failed, executable not found at: ${_DOXYGEN_EXE_PATH}")
endif()
