vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bloomberg/quantum
    REF f4b872f99480bc7f2ab60620d99823e8f2d3b0d6
    SHA512 c41930c8bb0a1b70fdd4123ef349a0e8e892e0ecd52b412a171b1ce05386323a9ed2376a792ac12cd69f7d5a97a257bc08c2b85ce8a5f16b6f4e75740823b53b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DQUANTUM_EXPORT_PKGCONFIG=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/Quantum")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
