# FetchGraphviz.cmake
# 自动查找或下载 Graphviz 预构建二进制文件（提供 dot 工具供 Doxygen 生成图表）
#
# 用法:
#   include(scripts/cmake/FetchGraphviz.cmake)
#   if(GRAPHVIZ_FOUND)
#       # 使用 ${DOT_EXECUTABLE}
#   endif()

set(GRAPHVIZ_DOWNLOAD_VERSION "12.2.1" CACHE STRING "Graphviz version to download if not found")

set(GRAPHVIZ_FOUND FALSE)

# 优先使用系统已安装的 Graphviz
find_program(DOT_EXECUTABLE dot)
if(DOT_EXECUTABLE)
	message(STATUS "Found system Graphviz dot: ${DOT_EXECUTABLE}")
	set(GRAPHVIZ_FOUND TRUE)
	get_filename_component(DOT_DIR "${DOT_EXECUTABLE}" DIRECTORY)
	set(DOT_PATH "${DOT_DIR}" CACHE PATH "Graphviz dot directory" FORCE)
	return()
endif()

message(STATUS "System Graphviz not found, downloading v${GRAPHVIZ_DOWNLOAD_VERSION}...")

set(_GRAPHVIZ_BASE_DIR "${CMAKE_BINARY_DIR}/_deps/graphviz-${GRAPHVIZ_DOWNLOAD_VERSION}")

# 平台检测与 URL 设置
if(CMAKE_HOST_WIN32)
	set(_GRAPHVIZ_ARCHIVE_NAME "windows_10_cmake_Release_Graphviz-${GRAPHVIZ_DOWNLOAD_VERSION}-win64.zip")
	set(_GRAPHVIZ_URL "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${GRAPHVIZ_DOWNLOAD_VERSION}/${_GRAPHVIZ_ARCHIVE_NAME}")
	set(_GRAPHVIZ_DOT_PATH "${_GRAPHVIZ_BASE_DIR}/Graphviz-${GRAPHVIZ_DOWNLOAD_VERSION}-win64/bin/dot.exe")
elseif(CMAKE_HOST_UNIX AND NOT CMAKE_HOST_APPLE)
	set(_GRAPHVIZ_ARCHIVE_NAME "ubuntu_22.04_cmake_Release_Graphviz-${GRAPHVIZ_DOWNLOAD_VERSION}-Linux.tar.gz")
	set(_GRAPHVIZ_URL "https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${GRAPHVIZ_DOWNLOAD_VERSION}/${_GRAPHVIZ_ARCHIVE_NAME}")
	set(_GRAPHVIZ_DOT_PATH "${_GRAPHVIZ_BASE_DIR}/Graphviz-${GRAPHVIZ_DOWNLOAD_VERSION}-Linux/bin/dot")
else()
	message(STATUS "Graphviz auto-download not supported on this platform, please install Graphviz manually")
	return()
endif()

set(_GRAPHVIZ_ARCHIVE_PATH "${_GRAPHVIZ_BASE_DIR}/${_GRAPHVIZ_ARCHIVE_NAME}")

if(NOT EXISTS "${_GRAPHVIZ_DOT_PATH}")
	# 下载
	if(NOT EXISTS "${_GRAPHVIZ_ARCHIVE_PATH}")
		message(STATUS "Downloading ${_GRAPHVIZ_URL}")
		file(MAKE_DIRECTORY "${_GRAPHVIZ_BASE_DIR}")
		file(DOWNLOAD
			"${_GRAPHVIZ_URL}"
			"${_GRAPHVIZ_ARCHIVE_PATH}"
			STATUS _DOWNLOAD_STATUS
			SHOW_PROGRESS
		)
		list(GET _DOWNLOAD_STATUS 0 _STATUS_CODE)
		list(GET _DOWNLOAD_STATUS 1 _STATUS_MSG)
		if(NOT _STATUS_CODE EQUAL 0)
			message(WARNING "Graphviz download failed (${_STATUS_CODE}): ${_STATUS_MSG}")
			file(REMOVE "${_GRAPHVIZ_ARCHIVE_PATH}")
			return()
		endif()
	endif()

	# 解压
	message(STATUS "Extracting Graphviz to ${_GRAPHVIZ_BASE_DIR}")
	file(ARCHIVE_EXTRACT
		INPUT "${_GRAPHVIZ_ARCHIVE_PATH}"
		DESTINATION "${_GRAPHVIZ_BASE_DIR}"
	)

	# 删除归档文件节省空间
	file(REMOVE "${_GRAPHVIZ_ARCHIVE_PATH}")
endif()

# 验证
if(EXISTS "${_GRAPHVIZ_DOT_PATH}")
	set(GRAPHVIZ_FOUND TRUE)
	set(DOT_EXECUTABLE "${_GRAPHVIZ_DOT_PATH}" CACHE FILEPATH "Graphviz dot executable" FORCE)
	get_filename_component(DOT_DIR "${_GRAPHVIZ_DOT_PATH}" DIRECTORY)
	set(DOT_PATH "${DOT_DIR}" CACHE PATH "Graphviz dot directory" FORCE)
	message(STATUS "Using downloaded Graphviz dot: ${DOT_EXECUTABLE}")
else()
	message(WARNING "Graphviz extraction failed, dot not found at: ${_GRAPHVIZ_DOT_PATH}")
endif()
