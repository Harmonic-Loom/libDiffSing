if(NOT DEFINED ENV{DIFFSING_IOS_DEPLOYMENT_TARGET} OR "$ENV{DIFFSING_IOS_DEPLOYMENT_TARGET}" STREQUAL "")
    message(FATAL_ERROR "DIFFSING_IOS_DEPLOYMENT_TARGET is required")
endif()

set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
# CMake appends its default -g after VCPKG_*_FLAGS_DEBUG. Pass the reduced
# debug-info kind directly to Clang cc1 so the trailing driver flag cannot
# restore full standalone DWARF.
set(VCPKG_C_FLAGS_DEBUG "-Xclang -debug-info-kind=line-tables-only")
set(VCPKG_CXX_FLAGS_DEBUG "-Xclang -debug-info-kind=line-tables-only")
set(VCPKG_CMAKE_SYSTEM_NAME iOS)
set(VCPKG_OSX_SYSROOT iphoneos)
set(VCPKG_OSX_DEPLOYMENT_TARGET "$ENV{DIFFSING_IOS_DEPLOYMENT_TARGET}")
set(VCPKG_ENV_PASSTHROUGH DIFFSING_IOS_DEPLOYMENT_TARGET)
