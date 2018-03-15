include(vcpkg_common_functions)

set(LIB_NAME nghttp2)
set(LIB_VERSION 1.31.0)

set(LIB_FILENAME ${LIB_NAME}-${LIB_VERSION}.tar.gz)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${LIB_NAME}-${LIB_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nghttp2/nghttp2/releases/download/v${LIB_VERSION}/${LIB_FILENAME}"
    FILENAME "${LIB_FILENAME}"
    SHA512 077632a87033271c61e06fef2a5b6a2628d2961dd0f0b2ae419468165eb071e24facffb97564cec248a2c96ff6de662174c1d733afb8ebe3fb2bda367fb84675
)
vcpkg_extract_source_archive(${ARCHIVE})

# Details: https://github.com/nghttp2/nghttp2/pull/1146
# vcpkg_apply_patches(
#     SOURCE_PATH ${SOURCE_PATH}
#     PATCHES
#         "${CMAKE_CURRENT_LIST_DIR}/enable-static.patch"
# )
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_STATIC_LIB=${BUILD_STATIC}
        -DENABLE_LIB_ONLY=ON
        -DENABLE_ASIO_LIB=OFF
)

vcpkg_install_cmake()

# Remove unwanted files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)

# Move dll files from /lib to /bin where vcpkg expects them
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${LIB_NAME}.dll ${CURRENT_PACKAGES_DIR}/bin/${LIB_NAME}.dll)

    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_NAME}.dll ${CURRENT_PACKAGES_DIR}/debug/bin/${LIB_NAME}.dll)
endif()

# License and man
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${LIB_NAME} RENAME copyright)

vcpkg_copy_pdbs()
