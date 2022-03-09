vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ithewei/libhv
    REF v1.2.4
    SHA512 5732800970180294DCEB329F25D22B1A7178739A2A5A2CE32E030F4FD38055A6298797D26E7FF5525AC662059FF0AAEDB8ABC200E0BA9E4EEBEB5846FB53F4D0
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_UNITTEST=OFF
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/hv.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/hv.dll" "${CURRENT_PACKAGES_DIR}/bin/hv.dll")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/hv.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/hv.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/hv.dll")
endif()
