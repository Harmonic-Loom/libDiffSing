# ConfigureOnnxRuntimeFeatures.cmake
# Generates ONNX Runtime features based on platform

if(NOT VCPKG_TARGET_TRIPLET)
	message(FATAL_ERROR "VCPKG_TARGET_TRIPLET not set")
endif()

# triplet to features mapping (based on CMakePresets.json)
set(ONNXRUNTIME_FEATURES "")
set(ONNXRUNTIME_FEATURES_JSON "")

if(VCPKG_TARGET_TRIPLET MATCHES "^x64-windows")
	set(ONNXRUNTIME_FEATURES "cuda" "openvino")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-windows")
	set(ONNXRUNTIME_FEATURES "openvino")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^x64-linux")
	set(ONNXRUNTIME_FEATURES "cuda" "openvino")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-linux")
	set(ONNXRUNTIME_FEATURES "kleidiai")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-osx")
	set(ONNXRUNTIME_FEATURES "kleidiai")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^x64-osx")
	set(ONNXRUNTIME_FEATURES "kleidiai")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-ios")
	set(ONNXRUNTIME_FEATURES "kleidiai")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-ios-simulator")
	set(ONNXRUNTIME_FEATURES "kleidiai")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^arm64-android-api29")
	set(ONNXRUNTIME_FEATURES "kleidiai")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^x64-android-api29")
	set(ONNXRUNTIME_FEATURES "")

elseif(VCPKG_TARGET_TRIPLET MATCHES "^wasm32-emscripten")
	set(ONNXRUNTIME_FEATURES "")

else()
	message(WARNING "Unknown triplet '${VCPKG_TARGET_TRIPLET}', skipping ONNX Runtime features")
	set(ONNXRUNTIME_FEATURES "")
endif()

message(STATUS "  Features: ${ONNXRUNTIME_FEATURES}")

# Generate features JSON array
if(ONNXRUNTIME_FEATURES)
	set(ONNXRUNTIME_FEATURES_JSON "")
	foreach(FEATURE ${ONNXRUNTIME_FEATURES})
		if(ONNXRUNTIME_FEATURES_JSON STREQUAL "")
			set(ONNXRUNTIME_FEATURES_JSON "\"${FEATURE}\"")
		else()
			string(APPEND ONNXRUNTIME_FEATURES_JSON ", \"${FEATURE}\"")
		endif()
	endforeach()
else()
	set(ONNXRUNTIME_FEATURES_JSON "")
endif()

# Export variables to parent scope
set(ONNXRUNTIME_FEATURES_JSON "${ONNXRUNTIME_FEATURES_JSON}" PARENT_SCOPE)

message(STATUS "Configured ONNX Runtime features")
message(STATUS "  Features JSON: [${ONNXRUNTIME_FEATURES_JSON}]")

