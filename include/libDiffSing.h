#pragma once

/**
 * @file libDiffSing.h
 * @brief libDiffSing 公共 C API 头文件.
 */

#include "Platforms.h"

#if defined __cplusplus

extern "C" {

#endif

/** @name 库生命周期 */
/** @{ */

/**
 * @brief 获取 libDiffSing 的版本号.
 * @return 库版本号字符串.
 * @warning 返回值无需释放内存.
 */
DS_API const char* DSGetLibraryVersion();

/**
 * @brief 初始化库，设置一些内部静态变量。
 * @see DSShutdownLibrary()
 */
DS_API void DSInitLibrary();

/**
 * @brief 关闭库，清理内部变量。
 * @warning 应用正常退出前必须将库关闭。
 * @see DSInitLibrary()
 */
DS_API void DSShutdownLibrary();
/**
 * @brief 查询库是否已经初始化。
 * @return 库已初始化返回true，否则返回false.
 */
DS_API bool DSIsLibraryInitialized();

/** @} */

/** @name 内存管理 */
/** @{ */

/**
 * @brief 通过库的堆分配内存，用于回调等场景.
 * @param size 分配的字节数.
 * @return 分配的内存指针.
 * @warning 所有分配的内存必须由 DSFree() 释放，且释放后指针不可再使用。
 * @see DSFree(), DSFreeArray()
 */
DS_API void* DSMalloc(size_t size);

/**
 * @brief 释放由库分配的内存.
 * @param ptr 由 DSMalloc() 分配的内存指针.
 * @warning 只能释放由 DSMalloc() 分配的内存，且释放后指针不可再使用。
 * @warning 所有由 DSMalloc() 分配的内存必须由 DSFree() 释放。
 * @see DSMalloc()
 */
DS_API void DSFree(void* ptr);

/**
 * @brief 释放以NULL结尾的二级指针数组及其元素内存.
 * @param ptrArray 由库分配并以NULL结尾的二级指针数组。
 * @warning 仅用于释放由库返回且要求使用 DSFreeArray() 释放的二级指针。
 * @see DSMalloc()
 */
DS_API void DSFreeArray(void** ptrArray);

/** @} */

#if defined __cplusplus

}// extern "C"

#endif