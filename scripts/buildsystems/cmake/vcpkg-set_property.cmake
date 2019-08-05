option(VCPKG_ENABLE_SET_PROPERTY "Enables override of the cmake function set_property." ON)
mark_as_advanced(VCPKG_ENABLE_SET_PROPERTY)
CMAKE_DEPENDENT_OPTION(VCPKG_ENABLE_SET_PROPERTY_EXTERNAL_OVERRIDE "Tells VCPKG to use _set_property instead of set_property." OFF "NOT VCPKG_ENABLE_SET_TARGET_PROPERTIES" OFF)
mark_as_advanced(VCPKG_ENABLE_SET_PROPERTY_EXTERNAL_OVERRIDE)

function(vcpkg_set_property _vcpkg_set_property_mode_impl)
    cmake_policy(PUSH)
    cmake_policy(SET CMP0054 NEW)
    if(VCPKG_ENABLE_SET_PROPERTY OR VCPKG_ENABLE_SET_PROPERTY_EXTERNAL_OVERRIDE)
        vcpkg_msg(STATUS "set_property" "Forwarding to _set_property: ${ARGV}")
        _set_property(${ARGV})
    else()
        vcpkg_msg(STATUS "set_property" "Forwarding to set_property: ${ARGV}")
        set_property(${ARGV})
    endif()
    if("${_vcpkg_set_property_mode_impl}" MATCHES "TARGET" AND "${ARGV}" MATCHES "IMPORTED_LOCATION|IMPORTED_IMPLIB")
        cmake_parse_arguments(PARSE_ARGV 0 _vcpkg_set_property "APPEND;APPEND_STRING" "" "TARGET;PROPERTY")
        
        foreach(_vcpkg_target_name ${_vcpkg_set_property_TARGET})
            get_target_property(_vcpkg_target_imported ${_vcpkg_target_name} IMPORTED)
            if(_vcpkg_target_imported)
                # Just debugging
                vcpkg_msg(STATUS "set_properties" "${_vcpkg_target_name} is an IMPORTED target. Checking import location (if available)!")
                get_target_property(_vcpkg_target_imp_loc ${_vcpkg_target_name} IMPORTED_LOCATION)
                vcpkg_msg(STATUS "set_properties" "IMPORTED_LOCATION: ${_vcpkg_target_imp_loc}")
                get_target_property(_vcpkg_target_imp_loc_rel ${_vcpkg_target_name} IMPORTED_LOCATION_RELEASE)
                vcpkg_msg(STATUS "set_properties" "IMPORTED_LOCATION_RELEASE: ${_vcpkg_target_imp_loc_rel}")
                get_target_property(_vcpkg_target_imp_loc_dbg ${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG)
                vcpkg_msg(STATUS "set_properties" "IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_dbg}")
                get_target_property(_vcpkg_target_implib_loc ${_vcpkg_target_name} IMPORTED_IMPLIB)
                vcpkg_msg(STATUS "set_properties" "IMPORTED_IMPLIB: ${_vcpkg_target_implib_loc}")
                get_target_property(_vcpkg_target_implib_loc_rel ${_vcpkg_target_name} IMPORTED_IMPLIB_RELEASE)
                vcpkg_msg(STATUS "set_properties" "IMPORTED_IMPLIB_RELEASE: ${_vcpkg_target_implib_loc_rel}")
                get_target_property(_vcpkg_target_implib_loc_dbg ${_vcpkg_target_name} IMPORTED_IMPLIB_DEBUG)
                vcpkg_msg(STATUS "set_properties" "IMPORTED_IMPLIB_DEBUG: ${_vcpkg_target_implib_loc_dbg}")

                # Release location (just checking)
                if(_vcpkg_target_imp_loc_rel AND "${_vcpkg_target_imp_loc_rel}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
                    vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} has property IMPORTED_LOCATION_RELEASE: ${_vcpkg_target_imp_loc_rel}. Checking for correct vcpkg path!")
                    if("${_vcpkg_target_imp_loc_rel}" MATCHES "/debug/")
                        #This is the death case. If we reach this line the linkage of the target will be wrong!
                        #Side effect: This also fails for executables within the debug directory which is a nice feature and makes sure only release tools are used by vcpkg
                        cmake_policy(POP)
                        vcpkg_msg(FATAL_ERROR "set_property" "Property IMPORTED_LOCATION_RELEASE: ${_vcpkg_target_imp_loc_rel}. Not set to vcpkg release library dir!" ALWAYS)
                    else()
                        vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} IMPORTED_LOCATION_RELEASE is correct: ${_vcpkg_target_imp_loc_rel}.")
                    endif()
                endif()
                # same for IMPLIB
                if(_vcpkg_target_implib_loc_rel AND "${_vcpkg_target_implib_loc_rel}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
                    vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} has property IMPORTED_IMPLIB_RELEASE: ${_vcpkg_target_implib_loc_rel}. Checking for correct vcpkg path!")
                    if("${_vcpkg_target_implib_loc_rel}" MATCHES "/debug/")
                        #This is the death case. If we reach this line the linkage of the target will be wrong!
                        cmake_policy(POP)
                        vcpkg_msg(FATAL_ERROR "set_property" "Property IMPORTED_IMPLIB_RELEASE: ${_vcpkg_target_implib_loc_rel}. Not set to vcpkg release library dir!" ALWAYS)
                    else()
                        vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} IMPORTED_IMPLIB_RELEASE is correct: ${_vcpkg_target_implib_loc_rel}.")
                    endif()
                endif()
                
                # Debug location (just checking)
                if(_vcpkg_target_imp_loc_dbg AND "${_vcpkg_target_imp_loc_dbg}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
                    vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} has property IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_dbg}. Checking for correct vcpkg path!")
                    if(NOT "${_vcpkg_target_imp_loc_dbg}" MATCHES "/debug/")
                        if("${_vcpkg_target_imp_loc_dbg}" MATCHES "/tools/")
                            vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG is an execuable: ${_vcpkg_target_imp_loc_dbg}. VCPKG will use release tools for performance reasons.")
                        else()
                            #This is the death case. If we reach this line the linkage of the target will be wrong!
                            cmake_policy(POP)
                            vcpkg_msg(FATAL_ERROR "set_property" "Property IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_dbg}. Not set to vcpkg debug library dir!" ALWAYS)
                        endif()
                    else()
                        vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG is correct: ${_vcpkg_target_imp_loc_dbg}.")
                    endif()
                endif()
                # same for IMPLIB
                if(_vcpkg_target_implib_loc_dbg AND "${_vcpkg_target_implib_loc_dbg}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
                    vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} has property IMPORTED_IMPLIB_DEBUG: ${_vcpkg_target_implib_loc_dbg}. Checking for correct vcpkg path!")
                    if(NOT "${_vcpkg_target_implib_loc_dbg}" MATCHES "/debug/")
                        #This is the death case. If we reach this line the linkage of the target will be wrong!
                        cmake_policy(POP)
                        vcpkg_msg(FATAL_ERROR "set_property" "Property IMPORTED_IMPLIB_DEBUG: ${_vcpkg_target_implib_loc_dbg}. Not set to vcpkg release library dir!" ALWAYS)
                    else()
                        vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} IMPORTED_IMPLIB_DEBUG is correct: ${_vcpkg_target_implib_loc_rel}.")
                    endif()
                endif()
                
                # General import location. Here we assume changes made by find_library to the library name 
                # We probably need to correct this one using VPCKG_LIBTRACK
                if(_vcpkg_target_imp_loc AND "${_vcpkg_target_imp_loc}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}(/lib|/debug/lib)")
                    vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} has property IMPORTED_LOCATION: ${_vcpkg_target_imp_loc}. Checking for configuration dependent locations!")
                    #Need VCPKG_LIBTRACK here
                    vcpkg_extract_library_name_from_path(_vcpkg_libtrack_name ${_vcpkg_target_imp_loc})
                    if(NOT ${_vcpkg_target_imp_loc_rel})
                        if(NOT DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE OR "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE}" MATCHES "NOTFOUND")
                            cmake_policy(POP)
                            vcpkg_msg(FATAL_ERROR "set_property" "Unable to find VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE!" ALWAYS)
                        endif()
                        _set_property(TARGET ${_vcpkg_target_name} PROPERTY IMPORTED_LOCATION_RELEASE "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE}")
                    else()
                        vcpkg_msg(WARNING "set_property" "Unable to setup IMPORTED_LOCATION_RELEASE for target ${_vcpkg_target_name}!" ALWAYS)
                    endif()
                    if(NOT ${_vcpkg_target_imp_loc_dbg} AND VCPKG_DEBUG_AVAILABLE)
                        if(NOT DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG OR "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG}" MATCHES "NOTFOUND")
                            cmake_policy(POP)
                            vcpkg_msg(FATAL_ERROR "set_property" "Unable to find VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG!" ALWAYS)
                        endif()
                        _set_property(TARGET ${_vcpkg_target_name} PROPERTY IMPORTED_LOCATION_DEBUG "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG}")
                    else()
                        vcpkg_msg(WARNING "set_property" "Unable to setup IMPORTED_LOCATION_DEBUG for target ${_vcpkg_target_name}!" ALWAYS)
                    endif()
                endif()
                
                #IMPLIB
                if(_vcpkg_target_implib_loc AND "${_vcpkg_target_implib_loc}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}(/lib|/debug/lib)")
                    vcpkg_msg(STATUS "set_property" "${_vcpkg_target_name} has property IMPLIB_LOCATION: ${_vcpkg_target_implib_loc}. Checking for configuration dependent locations!")                  
                    #Need VCPKG_LIBTRACK here
                    vcpkg_extract_library_name_from_path(_vcpkg_libtrack_name ${_vcpkg_target_implib_loc})
                    if(NOT ${_vcpkg_target_implib_loc_rel})
                        if(NOT DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE OR "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE}" MATCHES "NOTFOUND")
                            cmake_policy(POP)
                            vcpkg_msg(FATAL_ERROR "set_property" "Unable to find VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE!" ALWAYS)
                        endif()
                        _set_property(TARGET ${_vcpkg_target_name} PROPERTY IMPLIB_LOCATION_RELEASE "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_RELEASE}")
                    else()
                        vcpkg_msg(WARNING "set_property" "Unable to setup IMPLIB_LOCATION_RELEASE for target ${_vcpkg_target_name}!" ALWAYS)
                    endif()
                    if(NOT ${_vcpkg_target_implib_loc_dbg} AND VCPKG_DEBUG_AVAILABLE)
                        if(NOT DEFINED VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG OR "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG}" MATCHES "NOTFOUND")
                            cmake_policy(POP)
                            vcpkg_msg(FATAL_ERROR "set_property" "Unable to find VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG!" ALWAYS)
                        endif()
                        _set_property(TARGET ${_vcpkg_target_name} PROPERTY IMPLIB_LOCATION_DEBUG "${VCPKG_LIBTRACK_${_vcpkg_libtrack_name}_DEBUG}")
                    else()
                        vcpkg_msg(WARNING "set_property" "Unable to setup IMPLIB_LOCATION_DEBUG for target ${_vcpkg_target_name}!" ALWAYS)
                    endif()
                endif()
                
            endif()
        endforeach()
    endif()
    cmake_policy(POP)
endfunction()

if(VCPKG_ENABLE_SET_PROPERTY)
    function(set_property _vcpkg_set_property_mode)
        vcpkg_enable_function_overwrite_guard(set_property "")

        vcpkg_msg(STATUS "set_property" "Called with: ${ARGV}")
        
        vcpkg_set_property(${ARGV})
        
        vcpkg_disable_function_overwrite_guard(set_property "")
    endfunction()
endif()