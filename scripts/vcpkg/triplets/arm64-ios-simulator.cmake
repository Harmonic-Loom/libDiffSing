set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
# CMake appends its default -g after VCPKG_*_FLAGS_DEBUG. Pass the reduced
# debug-info kind directly to Clang cc1 so the trailing driver flag cannot
# restore full standalone DWARF.
set(VCPKG_C_FLAGS_DEBUG "-Xclang -debug-info-kind=line-tables-only")
set(VCPKG_CXX_FLAGS_DEBUG "-Xclang -debug-info-kind=line-tables-only")
set(VCPKG_CMAKE_SYSTEM_NAME iOS)
set(VCPKG_OSX_SYSROOT iphonesimulator)
set(VCPKG_OSX_DEPLOYMENT_TARGET "${CMAKE_OSX_DEPLOYMENT_TARGET}")
set(VCPKG_ENV_PASSTHROUGH CMAKE_OSX_DEPLOYMENT_TARGET)
