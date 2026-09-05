# FetchDoxygenAwesome.cmake
# 自动下载 doxygen-awesome-css 主题
#
# 用法:
#   include(scripts/cmake/FetchDoxygenAwesome.cmake)
#   # 使用 ${DOXYGEN_AWESOME_CSS_DIR} 指向主题目录

include(FetchContent)

set(DOXYGEN_AWESOME_VERSION "v2.3.4" CACHE STRING "doxygen-awesome-css version to download")

FetchContent_Declare(
	doxygen_awesome_css
	GIT_REPOSITORY https://github.com/jothepro/doxygen-awesome-css.git
	GIT_TAG        ${DOXYGEN_AWESOME_VERSION}
	GIT_SHALLOW    TRUE
	EXCLUDE_FROM_ALL
)

FetchContent_MakeAvailable(doxygen_awesome_css)

set(DOXYGEN_AWESOME_CSS_DIR "${doxygen_awesome_css_SOURCE_DIR}")
message(STATUS "doxygen-awesome-css: ${DOXYGEN_AWESOME_CSS_DIR}")
