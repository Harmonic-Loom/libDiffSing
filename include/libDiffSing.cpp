#include "libDiffSing.h"
#include <cstdlib>

extern "C" {

DS_API const char* DSGetLibraryVersion() {
	return "";
}

DS_API void DSInitLibrary() {
	/** TODO */
}

DS_API void DSShutdownLibrary() {
	/** TODO */
}

DS_API bool DSIsLibraryInitialized() {
	/** TODO */
	return false;
}

DS_API void* DSMalloc(size_t size) {
	return malloc(size);
}

DS_API void DSFree(void* ptr) {
	free(ptr);
}

DS_API void DSFreeArray(void** ptrArray) {
	for (void** ptr = ptrArray; *ptr != nullptr; ptr++) {
		DSFree(*ptr);
	}
	DSFree(ptrArray);
}
}