# GenerateManifest.cmake
# Unified entry point for generating vcpkg.json and other manifest files
# Centralizes manifest generation logic for easy extension

if(NOT VCPKG_TARGET_TRIPLET)
	message(FATAL_ERROR "VCPKG_TARGET_TRIPLET not set")
endif()

# Map triplet to platform description (based on CMakePresets.json)
if(VCPKG_TARGET_TRIPLET MATCHES "^x64-windows")
	set(TRIPLET_DESC "Windows x64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-windows")
	set(TRIPLET_DESC "Windows ARM64")
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
elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-ios-simulator")
	set(TRIPLET_DESC "iOS Simulator")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-android-api29")
	set(TRIPLET_DESC "Android ARM64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^x64-android-api29")
	set(TRIPLET_DESC "Android x64")
elseif(VCPKG_TARGET_TRIPLET MATCHES "^wasm32-emscripten")
	set(TRIPLET_DESC "Emscripten WASM")
else()
	set(TRIPLET_DESC "Unknown (${VCPKG_TARGET_TRIPLET})")
endif()

message(STATUS "Generating manifest for ${TRIPLET_DESC}")

if(NOT DEFINED REPO_ROOT_DIR OR REPO_ROOT_DIR STREQUAL "")
	get_filename_component(REPO_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
else()
	get_filename_component(REPO_ROOT_DIR "${REPO_ROOT_DIR}" ABSOLUTE)
endif()

set(SCRIPTS_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Configure ONNX Runtime features based on platform (generates ONNXRUNTIME_FEATURES_JSON variable)
include("${SCRIPTS_DIR}/ConfigureOnnxRuntimeFeatures.cmake")

# Configure additional dependencies here in the future
# e.g., include(ConfigureOtherDependencies.cmake)

# Generate vcpkg.json from template
configure_file(
	"${REPO_ROOT_DIR}/vcpkg.json.in"
	"${REPO_ROOT_DIR}/vcpkg.json"
	@ONLY
)

message(STATUS "✓ Generated vcpkg.json for ${TRIPLET_DESC}")
message(STATUS "  Repo root: ${REPO_ROOT_DIR}")
