# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/type_index
    REF boost-1.72.0
    SHA512 f7c3a78d5114fb4f8752a11b798f6826fda79345fad679b945240a0552358659cd83fb2182d5fbb6892bf971c2125bb4b7f527d05e3f6a17cb5521b1bfb280b7
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
