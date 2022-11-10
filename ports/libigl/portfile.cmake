# Header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  66b3ef2253e765d0ce0db74cec91bd706e5ba176 #2.4.0
    SHA512 7014ffdaa160bfa2509fc283cb7176d7994a37f51509c7374659292efad076c8fb594f9f6990bab1aa5562d1f66e93403ea35a5bf2a924436560a2d4669ffcfd
    HEAD_REF master
    PATCHES
        install-extra-headers.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        embree LIBIGL_EMBREE
        opengl LIBIGL_OPENGL
        glfw   LIBIGL_GLFW
        imgui  LIBIGL_IMGUI
        png LIBIGL_PNG # Disable this feature due to issue https://github.com/libigl/libigl/issues/1199
        xml    LIBIGL_XML
        cgal   LIBIGL_WITH_CGAL
        predicates   LIBIGL_PREDICATES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        # Build options
        -DLIBIGL_BUILD_TESTS=OFF
        -DLIBIGL_BUILD_TUTORIALS=OFF
        -DLIBIGL_INSTALL=ON
        -DLIBIGL_USE_STATIC_LIBRARY=OFF
        -DHUNTER_ENABLED=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_copy_pdbs()

# libigl is a header-only library.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/LICENSE.GPL" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
