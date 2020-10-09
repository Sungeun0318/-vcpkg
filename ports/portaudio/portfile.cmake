vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.assembla.com/portaudio.git
    REF c5d2c51bd6fe354d0ee1119ba932bfebd3ebfacc
    SHA512 1aed7401e0b0965647865b08459c862fb79f3d57a0c3675a8f9809b0c5234462c32c6b43888ef4f0dfbef3b7690fd1d06db8e2442333bc0d0af44335557e8ac3
    PATCHES
        fix-library-can-not-be-found.patch
        fix-include.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PA_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PA_BUILD_SHARED)

# NOTE: the ASIO backend will be built automatically if the ASIO-SDK is provided
# in a sibling folder of the portaudio source in vcpkg/buildtrees/portaudio/src
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPA_USE_DS=ON
        -DPA_USE_WASAPI=ON
        -DPA_USE_WDMKS=ON
        -DPA_USE_WMME=ON
        -DPA_LIBNAME_ADD_SUFFIX=OFF
        -DPA_DLL_LINK_WITH_STATIC_RUNTIME=OFF
        -DPA_BUILD_STATIC=${PA_BUILD_STATIC}
        -DPA_BUILD_SHARED=${PA_BUILD_SHARED}
    OPTIONS_DEBUG
        -DPA_ENABLE_DEBUG_OUTPUT:BOOL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/portaudio RENAME copyright)