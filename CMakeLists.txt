cmake_minimum_required(VERSION 3.25)

string(REPLACE "\\" "/" CMAKE_ANDROID_NDK "${CMAKE_ANDROID_NDK}")

project(LibDiffSing VERSION 0.0.0 LANGUAGES CXX C)
set(PROJECT_ID org.harmonicloom.libdiffsing)
set(DIFFSING_FRAMEWORK_MODULE_NAME "${PROJECT_NAME}")

if(NOT DEFINED CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE "Release"  CACHE STRING "Choose the type of build." FORCE)
endif(NOT DEFINED CMAKE_BUILD_TYPE)

set(CMAKE_CXX_STANDARD 20)# Using C++20
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 17)# Using C17
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)# For Clang-Tidy

set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")# Using /MD and /MDd on MSVC
if (MSVC)
	add_compile_definitions ("_CRT_SECURE_NO_WARNINGS")
endif (MSVC)

# MSVC新版cpp宏
if (MSVC)
	add_compile_options ("/Zc:__cplusplus")
endif (MSVC)

# MSVC热重载
if (MSVC AND CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<CONFIG:Debug>:EditAndContinue>")
	add_link_options ("/INCREMENTAL")
endif (MSVC AND CMAKE_BUILD_TYPE STREQUAL "Debug")


# 查找最新的 Git 标签
execute_process(
    COMMAND git describe --tags --abbrev=0
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_TAG
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# 如果没有 Git 标签，设置默认版本号
if(NOT GIT_TAG)
    set(PROJECT_VERSION_MAJOR 0)
    set(PROJECT_VERSION_MINOR 0)
    set(PROJECT_VERSION_PATCH 0)
    set(PRE_RELEASE_SUFFIX "")
else()
    # 提取标签中的版本部分（例如 v0.0.0 或 v0.0.0-xxx）
    string(REGEX MATCH "v([0-9]+)\\.([0-9]+)\\.([0-9]+)(-.*)?" GIT_VERSION ${GIT_TAG})
    
    if(GIT_VERSION)
        set(PROJECT_VERSION_MAJOR ${CMAKE_MATCH_1})  # 提取主版本号
        set(PROJECT_VERSION_MINOR ${CMAKE_MATCH_2})  # 提取次版本号
        set(PROJECT_VERSION_PATCH ${CMAKE_MATCH_3})  # 提取补丁版本号
        
        # 提取后缀部分（如果存在）
        if(CMAKE_MATCH_4)
            set(PRE_RELEASE_SUFFIX ${CMAKE_MATCH_4})  # 提取后缀部分（例如 -xxx）
        else()
            set(PRE_RELEASE_SUFFIX "")  # 如果没有后缀，设置为空
        endif()
    else()
        set(PROJECT_VERSION_MAJOR 0)
        set(PROJECT_VERSION_MINOR 0)
        set(PROJECT_VERSION_PATCH 0)
        set(PRE_RELEASE_SUFFIX "")
    endif()
    
    # 设置版本号，包括后缀（如有）
    set(PROJECT_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}${PRE_RELEASE_SUFFIX}")
endif()

message(STATUS "Project version: ${PROJECT_VERSION}")

# 输出目录
set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/bin")
set(TEST_DIR "${CMAKE_BINARY_DIR}/bin")
set(GUI_DIR "${CMAKE_BINARY_DIR}/bin")
set(DATA_DIR "${CMAKE_BINARY_DIR}/bin/data")
set(COPYRIGHT_DIR "${CMAKE_BINARY_DIR}/bin/licenses")

# 使可执行文件能在同目录找到动态库
if(LINUX OR ANDROID)
	# Linux 与 Android 使用 $ORIGIN 表示可执行文件/库所在目录
	set(CMAKE_INSTALL_RPATH "$ORIGIN")
	set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
	set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
	# macOS 使用 @loader_path（库加载库）和 @executable_path（可执行文件加载库）
	set(CMAKE_INSTALL_RPATH "@executable_path/../Frameworks;@loader_path/../Frameworks")
	set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
	set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
endif()

# JNI 构建
#set(JNI_HEADER_DIR ${CMAKE_BINARY_DIR}/include/jni)
#set(JAVA_SOURCE ${CMAKE_SOURCE_DIR}/include/jni/org/harmonicloom/libdiffsing/LibDiffSing.java)
#
#if(ANDROID)
#	# 查找Android库
#	file(GLOB ANDROID_PLATFORMS LIST_DIRECTORIES true "${ANDROID_SDK}/platforms/android-*")
#
#	set(ANDROID_JAR "")
#	set(MAX_API_LEVEL 0)
#
#	foreach(PLATFORM_PATH ${ANDROID_PLATFORMS})
#		get_filename_component(PLATFORM_NAME ${PLATFORM_PATH} NAME)
#		string(REGEX MATCH "[0-9]+" API_LEVEL ${PLATFORM_NAME})
#		if(API_LEVEL GREATER MAX_API_LEVEL)
#			set(MAX_API_LEVEL ${API_LEVEL})
#			set(ANDROID_JAR "${PLATFORM_PATH}/android.jar")
#		endif()
#	endforeach()
#
#	if(NOT EXISTS ${ANDROID_JAR})
#		message(FATAL_ERROR "No valid android.jar found in ${ANDROID_SDK}/platforms/")
#	else()
#		message(STATUS "Using android.jar: ${ANDROID_JAR}")
#	endif()
#
#	# Javac构建JNI接口
#	find_package(Java REQUIRED)
#
#	set(JNI_INC_HEADER "${JNI_HEADER_DIR}/org_harmonicloom_libdiffsing_LibDiffSing.h")
#
#	add_custom_command(
#		OUTPUT ${JNI_INC_HEADER}
#		COMMAND ${Java_JAVAC_EXECUTABLE}
#				-encoding UTF-8
#				-cp ${ANDROID_JAR}
#				-h ${JNI_HEADER_DIR}
#				${JAVA_SOURCE}
#		DEPENDS ${JAVA_SOURCE}
#		COMMENT "Generating JNI header from ${JAVA_SOURCE}"
#	)
#
#	add_custom_target(generate_jni_headers
#		DEPENDS ${JNI_INC_HEADER}
#	)
#endif(ANDROID)

# 主构建目标
#find_package(onnxruntime CONFIG REQUIRED)

if(NOT IOS)
	set(MAIN_BUILD_TYPE SHARED)
	set(MAIN_DEFINE_PUBLIC "DS_DLL=1")
	set(MAIN_DEFINE_PRIVATE "DS_DLL_BUILD=1")
else(NOT IOS)
	set(MAIN_BUILD_TYPE STATIC)
	set(MAIN_DEFINE_PUBLIC "")
	set(MAIN_DEFINE_PRIVATE "")
endif(NOT IOS)

file(GLOB_RECURSE MAIN_SRC CONFIGURE_DEPENDS
	"./src/*.cpp" "./src/*.c" "./src/*.rc" "./src/*.hpp" "./src/*.h"
	"./include/*.cpp" "./include/*.c" "./include/*.rc")
file(GLOB_RECURSE MAIN_INC CONFIGURE_DEPENDS "./include/*.hpp" "./include/*.h")
add_library(libDiffSing ${MAIN_BUILD_TYPE} ${MAIN_SRC} ${MAIN_INC} ${JNI_INC_HEADER})
target_include_directories(libDiffSing PUBLIC "./include")
target_include_directories(libDiffSing PRIVATE "./src" "${JNI_HEADER_DIR}")
#target_link_libraries(libDiffSing PRIVATE
#	onnxruntine
#)
if(ANDROID)
	target_link_libraries(libDiffSing PRIVATE log)
endif(ANDROID)

set_target_properties(libDiffSing PROPERTIES
	RUNTIME_OUTPUT_DIRECTORY "${OUTPUT_DIR}"
	ARCHIVE_OUTPUT_DIRECTORY "${OUTPUT_DIR}"
	LIBRARY_OUTPUT_DIRECTORY "${OUTPUT_DIR}")

target_compile_definitions(libDiffSing PRIVATE
	"PROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}"
	"PROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}"
	"PROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH}"
	"PRE_RELEASE_SUFFIX=\"${PRE_RELEASE_SUFFIX}\""
	"PROJECT_VERSION_STRING=\"${PROJECT_VERSION}\""
)

target_compile_definitions(libDiffSing PUBLIC ${MAIN_DEFINE_PUBLIC})
target_compile_definitions(libDiffSing PRIVATE ${MAIN_DEFINE_PRIVATE})

#if(ANDROID)
#	add_dependencies(libDiffSing generate_jni_headers)
#endif(ANDROID)

#message(STATUS "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
#if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
#	find_package(CpuFeatures CONFIG REQUIRED)
#	target_link_libraries(libDiffSing PRIVATE CpuFeatures::cpu_features)
#	message(STATUS "Using google cpu_features")
#endif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")

# Apple Framework 构建（仅 iOS 需要 Framework 格式，macOS 使用普通 dylib）
if(IOS)
	target_compile_options(libDiffSing PRIVATE
		"$<$<CONFIG:Debug>:-gline-tables-only>"
	)

	set_target_properties(libDiffSing PROPERTIES
		OUTPUT_NAME "${DIFFSING_FRAMEWORK_MODULE_NAME}"
		FRAMEWORK TRUE
		FRAMEWORK_VERSION A
		MACOSX_FRAMEWORK_IDENTIFIER ${PROJECT_ID}
		MACOSX_FRAMEWORK_BUNDLE_NAME "${DIFFSING_FRAMEWORK_MODULE_NAME}"
		MACOSX_FRAMEWORK_SHORT_VERSION_STRING "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
		MACOSX_FRAMEWORK_BUNDLE_VERSION "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}"
		PUBLIC_HEADER "${MAIN_INC}")

	# 生成 framework modulemap（使用固定模块名）
	configure_file(
		"${CMAKE_CURRENT_SOURCE_DIR}/scripts/cmake/DiffSingFramework.modulemap.in"
		"${CMAKE_CURRENT_BINARY_DIR}/DiffSingFramework.modulemap"
		@ONLY
	)
	add_custom_command(
		TARGET libDiffSing
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:libDiffSing>/Modules"
		COMMAND ${CMAKE_COMMAND} -E copy_if_different
			"${CMAKE_CURRENT_BINARY_DIR}/DiffSingFramework.modulemap"
			"$<TARGET_FILE_DIR:libDiffSing>/Modules/module.modulemap"
		COMMENT "Generating module.modulemap for iOS framework"
	)
endif(IOS)

# Apple 封装静态库
if(IOS)
	include("${CMAKE_CURRENT_SOURCE_DIR}/scripts/cmake/CollectStaticDeps.cmake")
	ds_collect_static_deps(TARGET libDiffSing OUTPUT IOS_LIB_PATHS)
	set(ENGINE_PATH "$<TARGET_FILE:libDiffSing>")
	set(MERGED_ENGINE_PATH "$<TARGET_FILE:libDiffSing>.merged")

	add_custom_command(
		TARGET libDiffSing
		POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E rm -f "${MERGED_ENGINE_PATH}"
		COMMAND xcrun libtool -static -o "${MERGED_ENGINE_PATH}"
			"${ENGINE_PATH}" ${IOS_LIB_PATHS}
		COMMAND ${CMAKE_COMMAND} -E rename
			"${MERGED_ENGINE_PATH}" "${ENGINE_PATH}"
		COMMENT "Merging static libraries into ${ENGINE_PATH}"
		COMMAND_EXPAND_LISTS
		VERBATIM
	)
endif(IOS)

# 数据拷贝
if (CMAKE_HOST_WIN32)
	set (COMPILE_SYS_DEF "WIN32=1")
	set (COPY_COMMAND "copy")
elseif (CMAKE_HOST_LINUX)
	set (COMPILE_SYS_DEF "LINUX=1")
	set (COPY_COMMAND "cp")
elseif (CMAKE_HOST_APPLE)
	set (COMPILE_SYS_DEF "DARWIN=1")
	set (COPY_COMMAND "cp")
endif ()

file (GLOB_RECURSE DATA_SRC CONFIGURE_DEPENDS
	"${CMAKE_SOURCE_DIR}/data/assets/*"
	"${CMAKE_SOURCE_DIR}/data/test/*")
set (DATA_OUTPUT "")
foreach (ITEM ${DATA_SRC})
	string (REPLACE "${CMAKE_SOURCE_DIR}/data" "${DATA_DIR}" ITEM_TARGET ${ITEM})
	string(REPLACE "#" "_" SAFE_ITEM_TARGET "${ITEM_TARGET}")# CMake 不支持路径中有 #
	list (APPEND DATA_OUTPUT ${SAFE_ITEM_TARGET})

	cmake_path (CONVERT ${ITEM} TO_NATIVE_PATH_LIST ITEM_INPUT)
	cmake_path (CONVERT ${SAFE_ITEM_TARGET} TO_NATIVE_PATH_LIST ITEM_OUTPUT)

	add_custom_command (
		OUTPUT "${SAFE_ITEM_TARGET}"
		COMMAND ${COPY_COMMAND} ${ITEM_INPUT} ${ITEM_OUTPUT}
		DEPENDS ${ITEM}
		COMMENT "Copying data file: ${ITEM}"
		VERBATIM)
endforeach (ITEM ${DATA_SRC})
add_custom_target (copy_data
	DEPENDS ${DATA_OUTPUT} ${DATA_SRC}
	COMMENT "Copy data files to output directory"
	VERBATIM)

# 版权信息拷贝
file (GLOB_RECURSE COPYRIGHT_SRC CONFIGURE_DEPENDS
	"${CMAKE_SOURCE_DIR}/copyright/*")
set (COPYRIGHT_OUTPUT "")
foreach (ITEM ${COPYRIGHT_SRC})
	string (REPLACE "${CMAKE_SOURCE_DIR}/copyright" "${COPYRIGHT_DIR}" ITEM_TARGET ${ITEM})
	string(REPLACE "#" "_" SAFE_ITEM_TARGET "${ITEM_TARGET}")# CMake 不支持路径中有 #
	list (APPEND COPYRIGHT_OUTPUT ${SAFE_ITEM_TARGET})

	cmake_path (CONVERT ${ITEM} TO_NATIVE_PATH_LIST ITEM_INPUT)
	cmake_path (CONVERT ${SAFE_ITEM_TARGET} TO_NATIVE_PATH_LIST ITEM_OUTPUT)

	add_custom_command (
		OUTPUT "${SAFE_ITEM_TARGET}"
		COMMAND ${COPY_COMMAND} ${ITEM_INPUT} ${ITEM_OUTPUT}
		DEPENDS ${ITEM}
		COMMENT "Copying copyright file: ${ITEM}"
		VERBATIM)
endforeach (ITEM ${COPYRIGHT_SRC})
add_custom_target (copy_copyright
	DEPENDS ${COPYRIGHT_OUTPUT} ${COPYRIGHT_SRC}
	COMMENT "Copy copyright files to output directory"
	VERBATIM)
add_dependencies (libDiffSing copy_copyright)

# 测试程序（iOS 不支持命令行程序，跳过）
if(NOT IOS)
enable_testing ()
file(GLOB_RECURSE TEST_SRC CONFIGURE_DEPENDS
	"./test/*.cpp" "./test/*.c")

foreach(TEST_ITEM ${TEST_SRC})
	get_filename_component(TEST_NAME ${TEST_ITEM} NAME_WE)

	add_executable(${TEST_NAME} ${TEST_ITEM})
	target_link_libraries(${TEST_NAME} PRIVATE libDiffSing)
	target_include_directories(${TEST_NAME} PRIVATE "./src")
#	if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")
#		target_link_libraries(${TEST_NAME} PRIVATE CpuFeatures::cpu_features)
#	endif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64|ARM64)$")

	add_dependencies(${TEST_NAME} copy_data)
	set_target_properties(${TEST_NAME} PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY "${TEST_DIR}"
		ARCHIVE_OUTPUT_DIRECTORY "${TEST_DIR}"
		LIBRARY_OUTPUT_DIRECTORY "${TEST_DIR}")
	set_target_properties(${TEST_NAME} PROPERTIES
		MACOSX_BUNDLE FALSE)

	add_test(NAME ${TEST_NAME} COMMAND $<TARGET_FILE:${TEST_NAME}>)
	set_tests_properties(${TEST_NAME} PROPERTIES TIMEOUT 3600)
endforeach(TEST_ITEM ${TEST_SRC})
endif(NOT IOS)

# Doxygen 文档生成
include(scripts/cmake/FetchDoxygen.cmake)
if(DOXYGEN_FOUND)
	include(scripts/cmake/FetchDoxygenAwesome.cmake)
	include(scripts/cmake/FetchGraphviz.cmake)
	if(GRAPHVIZ_FOUND)
		set(DOXYGEN_HAVE_DOT "YES")
	else()
		set(DOXYGEN_HAVE_DOT "NO")
		set(DOT_PATH "")
	endif()
	set(DOXYGEN_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/docs")
	configure_file(
		"${CMAKE_SOURCE_DIR}/docs/Doxyfile-api.in"
		"${CMAKE_CURRENT_BINARY_DIR}/Doxyfile-api"
		@ONLY)
	configure_file(
		"${CMAKE_SOURCE_DIR}/docs/Doxyfile-internal.in"
		"${CMAKE_CURRENT_BINARY_DIR}/Doxyfile-internal"
		@ONLY)
	add_custom_target(docs
		COMMAND ${DOXYGEN_EXECUTABLE} "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile-api"
		COMMAND ${DOXYGEN_EXECUTABLE} "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile-internal"
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		COMMENT "Generating API and internal documentation with Doxygen"
		VERBATIM)
else()
	message(STATUS "Doxygen not available, 'docs' target will not be created")
endif()
