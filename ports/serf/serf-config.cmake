if(NOT TARGET SERF:serf)
    add_library(SERF:serf UNKNOWN IMPORTED)

    find_path(SERF_INCLUDE_DIR          NAMES serf.h  PATHS  "${CURRENT_PACKAGES_DIR}/include" NO_DEFAULT_PATH)
    find_library(SERF_LIBRARY_RELEASE   NAMES serf-1  PATHS  "${CURRENT_PACKAGES_DIR}/lib" NO_DEFAULT_PATH)
    find_library(SERF_LIBRARY_DEBUG     NAMES serf-1  PATHS  "${CURRENT_PACKAGES_DIR}/debug/lib" NO_DEFAULT_PATH)

    set_target_properties(SERF:serf PROPERTIES
        IMPORTED_LOCATION_RELEASE "${SERF_LIBRARY_RELEASE}"
        IMPORTED_LOCATION_DEBUG "${SERF_LIBRARY_DEBUG}"
        IMPORTED_CONFIGURATIONS "Release;Debug"
    )
endif()
