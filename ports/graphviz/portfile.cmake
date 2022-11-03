vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graphviz/graphviz
    REF 2.49.1
    SHA512 ac14303f67d0840b260c5f2f99c53049a1e444a963d31387ae7a44ffc24757bd44f1c40ddd3fdb6a8d0e0bb1dde0e15d320f613729fb631efd4f078fcb3a4f62
    HEAD_REF main
    PATCHES
        0001-Fix-build.patch
        ltdl-dlopen.patch
)

if(VCPKG_TARGET_IS_OSX)
    message("${PORT} currently requires the following libraries from the system package manager:\n    libtool\n\nThey can be installed with brew install libtool")
elseif(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following libraries from the system package manager:\n    libtool\n\nThey can be installed with apt-get install libtool")
endif()

vcpkg_list(SET OPTIONS)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_LTDL=ON") # unsupported
else()
    vcpkg_list(APPEND OPTIONS "-DCMAKE_INSTALL_RPATH=${CURRENT_INSTALLED_DIR}/lib")
endif()

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES gawk)
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(GIT)
vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DGIT_EXECUTABLE=${GIT}"
        "-DPython3_EXECUTABLE=${PYTHON3}"
        "-DPKG_CONFIG_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf"
        ${OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tools(
    TOOL_NAMES acyclic bcomps ccomps circo dijkstra dot fdp gc gml2gv graphml2gv gv2gml gvcolor gvgen gvpack gvpr gxl2gv mm2gv neato nop osage patchwork sccmap sfdp tred twopi unflatten
    AUTO_CLEAN
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB PLUGINS "${CURRENT_PACKAGES_DIR}/bin/gvplugin_*")
    file(COPY ${PLUGINS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/dot" -c
        WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
        LOGNAME configure-plugins
    )
    file(COPY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/config6" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
