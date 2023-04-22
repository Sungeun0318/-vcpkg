vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PointCloudLibrary/pcl
    REF 371a8e1373f7b2f66bbb92291be2f3e50dc19856 # pcl-1.13.0
    SHA512 5c023e46386882d51a5d9a3c8ac594c17585e3d14c011964109ad0ae432c660ebb7fc1fe56f1130b6eafa75d1d9ca48f05e22e1d7cbb4a0794e32982da168563
    HEAD_REF master
    PATCHES
        add-gcc-version-check.patch
        fix-check-sse.patch
        fix-numeric-literals-flag.patch
        pcl_config.patch
        pcl_utils.patch
        install-examples.patch
        no-absolute.patch
        add_bigobj_option.patch
        outofcore_viewer_remove_include.patch
        fix_opennurbs_win32.patch
        disable_kinfu_for_cuda12.patch
        devendor-zlib.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PCL_SHARED_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        apps            BUILD_apps
        cuda            WITH_CUDA
        cuda            BUILD_CUDA
        cuda            BUILD_GPU
        examples        BUILD_examples
        libusb          WITH_LIBUSB
        opengl          WITH_OPENGL
        openni2         WITH_OPENNI2
        pcap            WITH_PCAP
        qt              WITH_QT
        simulation      BUILD_simulation
        surface-on-nurbs BUILD_surface_on_nurbs
        tools           BUILD_tools
        visualization   WITH_VTK
        visualization   BUILD_visualization
        # These 2 apps need openni1
        #apps            BUILD_apps_in_hand_scanner
        #apps            BUILD_apps_3d_rec_framework
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVCPKG_TRACE_FIND_PACKAGE=ON
        # PCL
        -DPCL_ALLOW_BOTH_SHARED_AND_STATIC_DEPENDENCIES=ON
        -DPCL_BUILD_WITH_BOOST_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_BUILD_WITH_FLANN_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_BUILD_WITH_QHULL_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_SHARED_LIBS=${PCL_SHARED_LIBS}
        # WITH
        -DWITH_DAVIDSDK=OFF
        -DWITH_DOCS=OFF
        -DWITH_DSSDK=OFF
        -DWITH_ENSENSO=OFF
        -DWITH_OPENMP=OFF
        -DWITH_OPENNI=OFF
        -DWITH_PNG=ON
        -DWITH_QHULL=ON
        -DWITH_RSSDK=OFF
        -DWITH_RSSDK2=OFF
        # FEATURES
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DBUILD_apps=OFF
        -DBUILD_examples=OFF
        -DBUILD_tools=OFF
    MAYBE_UNUSED_VARIABLES
        PCL_BUILD_WITH_FLANN_DYNAMIC_LINKING_WIN32
        PCL_BUILD_WITH_QHULL_DYNAMIC_LINKING_WIN32
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

if (WITH_OPENNI2)
    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB PCL_PKGCONFIG_DBGS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc")
        foreach (PCL_PKGCONFIG IN LISTS PCL_PKGCONFIG_DBGS)
            file(READ "${PCL_PKGCONFIG}" PCL_PC_DBG)
            if (PCL_PC_DBG MATCHES "libopenni2")
                string(REPLACE "libopenni2" "" PCL_PC_DBG "${PCL_PC_DBG}")
                string(REPLACE "Libs: " "Libs: -lKinect10 -lOpenNI2 " PCL_PC_DBG "${PCL_PC_DBG}")
                file(WRITE "${PCL_PKGCONFIG}" "${PCL_PC_DBG}")
            endif()
        endforeach()
    endif()
    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB PCL_PKGCONFIG_RELS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
        foreach (PCL_PKGCONFIG IN LISTS PCL_PKGCONFIG_RELS)
            file(READ "${PCL_PKGCONFIG}" PCL_PC_REL)
            if (PCL_PC_REL MATCHES "libopenni2")
                string(REPLACE "libopenni2" "" PCL_PC_REL "${PCL_PC_REL}")
                string(REPLACE "Libs: " "Libs: -lKinect10 -lOpenNI2 " PCL_PC_REL "${PCL_PC_REL}")
                file(WRITE "${PCL_PKGCONFIG}" "${PCL_PC_REL}")
            endif()
        endforeach()
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(BUILD_tools OR BUILD_apps OR BUILD_examples)
    file(GLOB tool_names
        LIST_DIRECTORIES false
        RELATIVE "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    )
    string(REPLACE "." "[.]" suffix "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    list(TRANSFORM tool_names REPLACE "${suffix}\$" "")
    vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
