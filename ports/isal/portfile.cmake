if(EXISTS "${CURRENT_INSTALLED_DIR}/share/spdk-isal/copyright")
    message(FATAL_ERROR "'${PORT}' conflicts with 'spdk-isal'. Please remove spdk-isal:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/isa-l
    REF v2.30.0
    SHA512 d3ecfb7326097534b06a74b584100336509525ae7cadc6112d0c27e3d8704f3810e18f583d3cc33fa266bfec96db023607622b22ddbf17988ec4bf1bb3b3b9b2
    HEAD_REF master
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_PATH "${NASM}" DIRECTORY)
    vcpkg_add_to_path("${NASM_PATH}")
endif()

if (VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(NMAKE_TARGET dll)
    else()
        set(NMAKE_TARGET static)
    endif()

    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_NAME Makefile.nmake
        TARGET ${NMAKE_TARGET}
        OPTIONS
            CFLAGS_REL=
    )

    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(NMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
        if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(INSTALL "${NMAKE_BINARY_DIR}/isa-l.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(INSTALL "${NMAKE_BINARY_DIR}/isa-l.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        else()
            file(INSTALL "${NMAKE_BINARY_DIR}/isa-l_static.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    endif()

    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(NMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
        if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(INSTALL "${NMAKE_BINARY_DIR}/isa-l.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
            file(INSTALL "${NMAKE_BINARY_DIR}/isa-l.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        else()
            file(INSTALL "${NMAKE_BINARY_DIR}/isa-l_static.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        endif()
    endif()

    file(GLOB ISAL_HDRS "${SOURCE_PATH}/include/*")
    file(INSTALL ${ISAL_HDRS} DESTINATION "${CURRENT_PACKAGES_DIR}/include/isal")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/isa-l.def" DESTINATION "${CURRENT_PACKAGES_DIR}/include/isal")
else()
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        vcpkg_find_acquire_program(YASM)
        get_filename_component(YASM_PATH "${NASM}" DIRECTORY)
        vcpkg_add_to_path("${YASM_PATH}")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
    )

    vcpkg_install_make()
    
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/isalConfig.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/isalConfig.cmake" @ONLY)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
