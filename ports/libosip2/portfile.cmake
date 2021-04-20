set(LIBOSIP2_VER "5.2.0")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/osip/libosip2-${LIBOSIP2_VER}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/osip/libosip2-${LIBOSIP2_VER}.tar.gz"
    FILENAME "libosip2-${LIBOSIP2_VER}.tar.gz"
    SHA512 cc714ab5669c466ee8f0de78cf74a8b7633f3089bf104c9c1474326840db3d791270159456f9deb877af2df346b04493e8f796b2bb7d2be134f6c08b25a29f83
)

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND PATCHES fix-path-in-project.patch)
endif()

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES ${PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS)   
    if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
        set(BUILD_ARCH "Win32")
    elseif(TRIPLET_SYSTEM_ARCH MATCHES "x64")
        set(BUILD_ARCH "x64")
    elseif(TRIPLET_SYSTEM_ARCH MATCHES "arm")
        message(FATAL_ERROR " ARM is currently not supported.")
    endif()    
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "platform/vsnet/osip2.vcxproj"
        PLATFORM ${BUILD_ARCH}
        INCLUDES_SUBPATH include
        USE_VCPKG_INTEGRATION
        ALLOW_ROOT_INCLUDES
        REMOVE_ROOT_INCLUDES      
    )    
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PLATFORM ${BUILD_ARCH}
        PROJECT_SUBPATH "platform/vsnet/osipparser2.vcxproj"
        USE_VCPKG_INTEGRATION
    )
elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS ${OPTIONS}
    )
    
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)