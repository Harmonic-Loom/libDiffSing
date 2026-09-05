# CollectStaticDeps.cmake
# Walks a CMake target's link graph and returns the static archive paths needed
# to fold its dependencies into another archive.
#
# Usage:
#   ds_collect_static_deps(TARGET <target> OUTPUT <output_var>)

function(ds_collect_static_deps)
	cmake_parse_arguments(ARG "" "TARGET;OUTPUT" "" ${ARGN})

	if(NOT ARG_TARGET)
		message(FATAL_ERROR "ds_collect_static_deps: TARGET is required")
	endif()
	if(NOT ARG_OUTPUT)
		message(FATAL_ERROR "ds_collect_static_deps: OUTPUT is required")
	endif()
	if(NOT TARGET ${ARG_TARGET})
		message(FATAL_ERROR "ds_collect_static_deps: unknown target ${ARG_TARGET}")
	endif()

	set(_queue "${ARG_TARGET}")
	set(_visited "")
	set(_archives "")

	while(_queue)
		list(POP_FRONT _queue _dep)
		if(NOT TARGET ${_dep} OR _dep IN_LIST _visited)
			continue()
		endif()
		list(APPEND _visited "${_dep}")

		get_target_property(_type ${_dep} TYPE)
		if(NOT _dep STREQUAL "${ARG_TARGET}" AND
			(_type STREQUAL "STATIC_LIBRARY" OR _type STREQUAL "UNKNOWN_LIBRARY"))
			list(APPEND _archives "$<TARGET_FILE:${_dep}>")
		endif()

		foreach(_property LINK_LIBRARIES INTERFACE_LINK_LIBRARIES)
			get_target_property(_links ${_dep} ${_property})
			if(NOT _links)
				continue()
			endif()

			foreach(_link IN LISTS _links)
				set(_candidate "${_link}")
				if(_candidate MATCHES "^\\$<LINK_ONLY:([^>]+)>$")
					set(_candidate "${CMAKE_MATCH_1}")
				elseif(_candidate MATCHES "^\\$<TARGET_NAME_IF_EXISTS:([^>]+)>$")
					set(_candidate "${CMAKE_MATCH_1}")
				endif()

				if(TARGET ${_candidate})
					list(APPEND _queue "${_candidate}")
				elseif(_link MATCHES "\\.(a|lib)(>|$)")
					# Some package configs expose configuration-specific archive paths
					# directly instead of representing them as imported targets.
					list(APPEND _archives "${_link}")
				endif()
			endforeach()
		endforeach()
	endwhile()

	list(REMOVE_DUPLICATES _archives)
	set(${ARG_OUTPUT} "${_archives}" PARENT_SCOPE)
endfunction()
