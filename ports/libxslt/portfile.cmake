vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxslt
    REF v1.1.35
    SHA512 1ab264a8d3996d74a89a22e4062950ef968b9252736e0b5f975e6f45d63a6484993fe383b85831cef0e4b9c9c90f9b2b3d5432c15ee9381dbaeb2fa681ab9b46
    HEAD_REF master
    PATCHES
        python3.patch
        msvc-no-suffix.patch
        libexslt-pkgconfig.patch
        fix-gcrypt-deps.patch
        fix-libxml2-deps.patch
        skip-install-docs.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "python"          LIBXSLT_WITH_PYTHON
        "crypto"          LIBXSLT_WITH_CRYPTO
)
if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND FEATURE_OPTIONS "-DPYTHON_EXECUTABLE=${PYTHON3}")
    list(APPEND FEATURE_OPTIONS_RELEASE "-DLIBXSLT_PYTHON_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/lib/site-packages")
    list(APPEND FEATURE_OPTIONS_DEBUG "-DLIBXSLT_PYTHON_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/lib/site-packages")
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBXSLT_WITH_TESTS:BOOL=OFF
        -DLIBXSLT_WITH_THREADS:BOOL=ON
    OPTIONS_RELEASE
        ${FEATURE_OPTIONS_RELEASE}
        -DLIBXSLT_WITH_XSLT_DEBUG:BOOL=OFF
        -DLIBXSLT_WITH_MEM_DEBUG:BOOL=OFF
        -DLIBXSLT_WITH_DEBUGGER:BOOL=OFF
    OPTIONS_DEBUG
        ${FEATURE_OPTIONS_DEBUG}
        -DLIBXSLT_WITH_XSLT_DEBUG:BOOL=ON
        -DLIBXSLT_WITH_MEM_DEBUG:BOOL=ON
        -DLIBXSLT_WITH_DEBUGGER:BOOL=ON
    )
vcpkg_cmake_install()
file(GLOB config_path RELATIVE "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/lib/cmake/libxslt-*")
vcpkg_cmake_config_fixup(CONFIG_PATH "${config_path}")

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/xsltConf.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/xsltConf.sh")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/libxslt/bin")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/xslt-config" "${CURRENT_PACKAGES_DIR}/tools/libxslt/bin/xslt-config")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libxslt/bin/xslt-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../")
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/libxslt/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/xslt-config" "${CURRENT_PACKAGES_DIR}/tools/libxslt/debug/bin/xslt-config")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libxslt/debug/bin/xslt-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../../")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libxslt/xsltconfig.h" "#define LIBXSLT_DEFAULT_PLUGINS_PATH() \"${CURRENT_INSTALLED_DIR}/lib/libxslt-plugins\"" "")
vcpkg_copy_tools(TOOL_NAMES xsltproc AUTO_CLEAN)

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

set(not_static 1)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(not_static 0)
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libxslt/xsltexports.h" "!defined(LIBXSLT_STATIC)" "${not_static}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libexslt/exsltexports.h" "!defined(LIBEXSLT_STATIC)" "${not_static}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libxslt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
