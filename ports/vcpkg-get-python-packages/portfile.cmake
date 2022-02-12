if(NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    # make FATAL_ERROR in CI when issue #16773 fixed
    message(WARNING "${PORT} is a host-only port; please mark it as a host port in your dependencies.")
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/copyright"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/x_vcpkg_get_python_packages.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/x_vcpkg_get_python_packages.cmake" @ONLY)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
