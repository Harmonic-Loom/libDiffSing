# CollectSharedDeps.cmake
# 提供 ds_collect_shared_deps 函数，对指定 CMake target 的依赖图进行
# 广度优先搜索，收集所有传递依赖的 SHARED_LIBRARY 目标。
#
# 用法：
#   ds_collect_shared_deps(TARGET <target> OUTPUT <output_var>)
#
# 参数：
#   TARGET     - 起始目标名称
#   OUTPUT     - 存放收集到的 SHARED_LIBRARY 目标列表的变量名（在调用方作用域中设置）
#
# 示例：
#   ds_collect_shared_deps(TARGET MyApp OUTPUT MY_SHARED_LIBS)
#   foreach(LIB ${MY_SHARED_LIBS})
#       add_custom_command(TARGET MyApp POST_BUILD ...)
#   endforeach()

function(ds_collect_shared_deps)
    cmake_parse_arguments(ARG "" "TARGET;OUTPUT" "" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "ds_collect_shared_deps: TARGET 参数不能为空")
    endif()
    if(NOT ARG_OUTPUT)
        message(FATAL_ERROR "ds_collect_shared_deps: OUTPUT 参数不能为空")
    endif()

    set(_queue "${ARG_TARGET}")
    set(_visited "")
    set(_shared "")

    while(_queue)
        list(POP_FRONT _queue _dep)
        if(NOT TARGET ${_dep})
            continue()
        endif()
        if(_dep IN_LIST _visited)
            continue()
        endif()
        list(APPEND _visited ${_dep})

        get_target_property(_type ${_dep} TYPE)
        if(_type STREQUAL "SHARED_LIBRARY" AND NOT _dep STREQUAL "${ARG_TARGET}")
            list(APPEND _shared ${_dep})
        endif()

        foreach(_prop LINK_LIBRARIES INTERFACE_LINK_LIBRARIES)
            get_target_property(_next_deps ${_dep} ${_prop})
            if(_next_deps)
                foreach(_next ${_next_deps})
                    if(TARGET ${_next})
                        list(APPEND _queue ${_next})
                    endif()
                endforeach()
            endif()
        endforeach()
    endwhile()

    list(REMOVE_DUPLICATES _shared)
    set(${ARG_OUTPUT} "${_shared}" PARENT_SCOPE)
endfunction()
