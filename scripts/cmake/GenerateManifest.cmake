# GenerateManifest.cmake
# Unified entry point for generating vcpkg.json and other manifest files
# Centralizes manifest generation logic for easy extension

if(NOT VCPKG_TARGET_TRIPLET)
	message(FATAL_ERROR "VCPKG_TARGET_TRIPLET not set")
endif()

# Map triplet to platform description
if(VCPKG_TARGET_TRIPLET MATCHES "^x64-windows")
	set(TRIPLET_DESC "Windows x64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^x64-linux")
	set(TRIPLET_DESC "Linux x64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-linux")
	set(TRIPLET_DESC "Linux ARM64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^x64-osx")
	set(TRIPLET_DESC "macOS x64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-osx")
	set(TRIPLET_DESC "macOS ARM64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-ios")
	set(TRIPLET_DESC "iOS ARM64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-android")
	set(TRIPLET_DESC "Android ARM64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^x64-android")
	set(TRIPLET_DESC "Android x64")
else()
	set(TRIPLET_DESC "Unknown (${VCPKG_TARGET_TRIPLET})")
endif()

message(STATUS "Generating manifest for ${TRIPLET_DESC}")

# Configure ONNX Runtime features based on platform (generates ONNXRUNTIME_FEATURES_JSON variable)
include("${CMAKE_CURRENT_SOURCE_DIR}/scripts/cmake/ConfigureOnnxRuntimeFeatures.cmake")

# Configure additional dependencies here in the future
# e.g., include(ConfigureOtherDependencies.cmake)

# Generate vcpkg.json from template
configure_file(
	"${CMAKE_SOURCE_DIR}/vcpkg.json.in"
	"${CMAKE_SOURCE_DIR}/vcpkg.json"
	@ONLY
)

message(STATUS "✓ Generated vcpkg.json for ${TRIPLET_DESC}")
