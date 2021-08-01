vcpkg_fail_port_install(ON_TARGET "osx" "linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/snoretoast
    REF v0.8.0
    SHA512 233751b6cc3f8099c742e4412a3c9ba8707a2f3c69b57bab93dd83b028aa0c0656cade8de1ece563843ace576fd0d8e5f3a29c254a07ed939d0a69cd2d4f6c2a
    HEAD_REF master
    PATCHES
        install_location.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC_RUNTIME=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libsnoretoast)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL "${SOURCE_PATH}/COPYING.LGPL-3" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
