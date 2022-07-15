if(NOT _VCPKG_WINDOWS_TOOLCHAIN)
set(_VCPKG_WINDOWS_TOOLCHAIN 1)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")

set(CMAKE_SYSTEM_NAME Windows CACHE STRING "")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(CMAKE_SYSTEM_PROCESSOR x86 CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CMAKE_SYSTEM_PROCESSOR AMD64 CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(CMAKE_SYSTEM_PROCESSOR ARM CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(CMAKE_SYSTEM_PROCESSOR ARM64 CACHE STRING "")
endif()

if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
    set(CMAKE_SYSTEM_VERSION "${VCPKG_CMAKE_SYSTEM_VERSION}" CACHE STRING "" FORCE)
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL CMAKE_HOST_SYSTEM_PROCESSOR)
        set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
    elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86")
        # any of the four platforms can run x86 binaries
        set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
    elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "ARM64")
        # arm64 can run binaries of any of the four platforms after Windows 11
        set(CMAKE_CROSSCOMPILING OFF CACHE STRING "")
    endif()

    if(NOT DEFINED CMAKE_SYSTEM_VERSION)
        set(CMAKE_SYSTEM_VERSION "${CMAKE_HOST_SYSTEM_VERSION}" CACHE STRING "")
    endif()
endif()

get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if(NOT _CMAKE_IN_TRY_COMPILE)

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
    elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
    else()
        message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
    endif()

    set(CHARSET_FLAG "/utf-8")
    if (NOT VCPKG_SET_CHARSET_FLAG OR VCPKG_PLATFORM_TOOLSET MATCHES "v120")
        # VS 2013 does not support /utf-8
        set(CHARSET_FLAG)
    endif()

    set(CMAKE_CXX_FLAGS " /nologo /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /GR /EHsc /MP ${VCPKG_CXX_FLAGS}" CACHE STRING "")
    set(CMAKE_C_FLAGS " /nologo /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /MP ${VCPKG_C_FLAGS}" CACHE STRING "")
    set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "")

    unset(CHARSET_FLAG)

    set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Zi /FS /Ob0 /Od /RTC1 ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Zi /FS /Ob0 /Od /RTC1 ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
    set(CMAKE_CXX_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Zi ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "")
    set(CMAKE_C_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Zi ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")

    get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
    if(NOT _CMAKE_IN_TRY_COMPILE)
        string(APPEND CMAKE_SHARED_LINKER_FLAGS " /PDBALTPATH:../pdb/%_PDB%")
        string(APPEND CMAKE_EXE_LINKER_FLAGS " /PDBALTPATH:../pdb/%_PDB%")

        function(z_vcpkg_install_pdbs)
            # from https://stackoverflow.com/questions/37434946/how-do-i-iterate-over-all-cmake-targets-programmatically/62311397#62311397
            # changed to not add an empty element add the end of the list and adjusted to vcpkg policies. 
            function(get_all_targets var)
                set(targets "")
                get_all_targets_recursive(targets "${CMAKE_CURRENT_SOURCE_DIR}")
                set("${var}" "${targets}" PARENT_SCOPE)
            endfunction()

            macro(get_all_targets_recursive targets dir)
                get_property(subdirectories DIRECTORY "${dir}" PROPERTY SUBDIRECTORIES)
                foreach(subdir IN LISTS subdirectories)
                    get_all_targets_recursive("${targets}" "${subdir}")
                endforeach()
                get_property(current_targets DIRECTORY "${dir}" PROPERTY BUILDSYSTEM_TARGETS)
                if(current_targets)
                    list(APPEND "${targets}" "${current_targets}")
                endif()
            endmacro()

            get_all_targets(build_targets)
            #get_directory_property(build_targets DIRECTORY "${CMAKE_SOURCE_DIR}" BUILDSYSTEM_TARGETS)
            message(STATUS "BUILDSYSTEM_TARGETS: ${build_targets}")
            foreach(target IN LISTS build_targets)
                get_target_property(type "${target}" TYPE)
                if(type MATCHES "(SHARED_LIBRARY|EXECUTABLE|MODULE_LIBRARY)")
                    message(STATUS "Toolchain shared pdb install: ${target}")
                    install(FILES "$<TARGET_PDB_FILE:${target}>" DESTINATION "pdb" OPTIONAL)
                elseif(type MATCHES "(STATIC_LIBRARY)")
                   # message(STATUS "Toolchain static pdb install: ${target}")
                   # set(pdb_filename "$<PATH:REPLACE_EXTENSION,LAST_ONLY,$<TARGET_FILE_NAME:${target}>,*.pdb>")
                    #get_target_property(pdb_name "${target}" PDB_NAME)
                   # install(FILES "$<TARGET_FILE_DIR:${target}>/${pdb_filename}" DESTINATION "pdb" OPTIONAL)
                elseif(type MATCHES "(OBJECT_LIBRARY)")
                    set(z_vcpkg_has_obj_libs ON)
                    message(STATUS "Toolchain object libraries pdb install: ${target}")
                    set_target_properties("${target}" PROPERTIES 
                                            COMPILE_PDB_NAME "${VCPKG_PORT_NAME}_${target}_obj.pdb"
                                            COMPILE_PDB_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
                                            )
                    install(FILES "${CMAKE_BINARY_DIR}/${VCPKG_PORT_NAME}_${target}_obj.pdb" DESTINATION "pdb" OPTIONAL)
                else()
                    message(STATUS "Toolchain no pdb installed: ${target}|${type}")
                endif()
                if(z_vcpkg_has_obj_libs)

                endif()
            endforeach()
        endfunction()
        cmake_language(DEFER CALL z_vcpkg_install_pdbs)
    endif()
    string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT " /nologo ")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")

    string(APPEND CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT " /nologo")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " /nologo ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " /nologo ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ")
endif()
endif()
