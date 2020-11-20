# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/locale
    REF boost-1.74.0
    SHA512 32bd61ee7e9565bf4b67615d02e38981c2e5fa4156a8c35697b9aec04990ed2e88663b63578f4a28bad3c52ef544cbeb5ec2667b31f2a1645313442cd5552f91
    HEAD_REF master
    PATCHES
        0001-Fix-boost-ICU-support.patch
        allow-force-finding-iconv.patch
)

if("icu" IN_LIST FEATURES)
    set(BOOST_LOCALE_ICU_FEATURE on)
else()
    set(BOOST_LOCALE_ICU_FEATURE off)
endif()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/b2-options.cmake.in"
    "${CURRENT_BUILDTREES_DIR}/vcpkg-b2-options.cmake"
    @ONLY)

include(${CURRENT_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(
    SOURCE_PATH ${SOURCE_PATH}
    BOOST_CMAKE_FRAGMENT "${CURRENT_BUILDTREES_DIR}/vcpkg-b2-options.cmake"
)
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
