vcpkg_fail_port_install(ON_TARGET "uwp")

set(SIMAGE_VERSION 1.8.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/simage
    REF 72bdc2fddb171ab08325ced9c4e04b27bbd2da6c #v1.8.1
    SHA512 8e0d4b246318e9a08d9a17e0550fae4e3902e5d14ff9d7e43569624d1ceb9308c1cbc2401cedc4bff4da8b136fc57fc6b11c6800f1db15914b13186b0d5dc8f1
    HEAD_REF master
    PATCHES requies-all-dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SIMAGE_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMAGE_USE_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" SIMAGE_USE_MSVC_STATIC_RUNTIME)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        oggvorbis   SIMAGE_OGGVORBIS_SUPPORT
        sndfile     SIMAGE_LIBSNDFILE_SUPPORT
)

# Depends on the platform
if(VCPKG_TARGET_IS_WINDOWS)
    set(SIMAGE_ON_WIN ON)
    set(SIMAGE_ON_NON_WIN OFF)
else()
    set(SIMAGE_ON_WIN OFF)
    set(SIMAGE_ON_NON_WIN ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DSIMAGE_BUILD_SHARED_LIBS:BOOL=${SIMAGE_BUILD_SHARED_LIBS}
        -DSIMAGE_USE_STATIC_LIBS:BOOL=${SIMAGE_USE_STATIC_LIBS}
        -DSIMAGE_USE_MSVC_STATIC_RUNTIME:BOOL=${SIMAGE_USE_MSVC_STATIC_RUNTIME}
        -DSIMAGE_USE_AVIENC=${SIMAGE_ON_WIN}
        -DSIMAGE_USE_GDIPLUS=${SIMAGE_ON_WIN}
        # Available on Linux, OSX and Windows without gdiplus
        -DSIMAGE_ZLIB_SUPPORT=${SIMAGE_ON_NON_WIN}
        -DSIMAGE_GIF_SUPPORT=${SIMAGE_ON_NON_WIN}
        -DSIMAGE_JPEG_SUPPORT=${SIMAGE_ON_NON_WIN}
        -DSIMAGE_PNG_SUPPORT=${SIMAGE_ON_NON_WIN}
        -DSIMAGE_TIFF_SUPPORT=${SIMAGE_ON_NON_WIN}
        #
        -DSIMAGE_USE_CGIMAGE=OFF
        -DSIMAGE_USE_QIMAGE=OFF
        -DSIMAGE_USE_QT6=OFF
        -DSIMAGE_USE_QT5=OFF
        -DSIMAGE_USE_CPACK=OFF
        -DSIMAGE_LIBJASPER_SUPPORT=OFF
        -DSIMAGE_EPS_SUPPORT=OFF
        -DSIMAGE_MPEG2ENC_SUPPORT=OFF
        -DSIMAGE_PIC_SUPPORT=OFF
        -DSIMAGE_RGB_SUPPORT=OFF
        -DSIMAGE_XWD_SUPPORT=OFF
        -DSIMAGE_TGA_SUPPORT=OFF
        -DSIMAGE_BUILD_MSVC_MP=OFF
        -DSIMAGE_BUILD_EXAMPLES=OFF
        -DSIMAGE_BUILD_TESTS=OFF
        -DSIMAGE_BUILD_DOCUMENTATION=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/simage-${SIMAGE_VERSION})

if (NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    vcpkg_copy_tools(TOOL_NAMES simage-config AUTO_CLEAN)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
