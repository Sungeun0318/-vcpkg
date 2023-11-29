vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO saadshams/nanojsonc
        REF "${VERSION}"
        SHA512 a434c0090926e6dd6d78f5b6d839539ed517f1d133d7078bfbdc118c43edd3e354a4a045632cb64d53af06bca34041aff972700541d4131bb45d70601311af4c
        HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -DBUILD_TESTS=OFF)
#vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" OPTIONS -DBUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

#file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
#file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
#configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

#message("Current List Dir: ${CMAKE_CURRENT_LIST_DIR}") # /Users/saad/Documents/vcpkg/ports/nanojsonc
#message("Source file path: ${CMAKE_CURRENT_LIST_DIR}/usage") # /Users/saad/Documents/vcpkg/ports/nanojsonc/usage
#message("Destination file path: ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage") # /Users/saad/Documents/vcpkg/packages/nanojsonc_x64-osx/share/nanojsonc/usage
