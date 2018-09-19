# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/convert
    REF boost-1.68.0
    SHA512 8493a2dcba56c6d7fe9cfb1cea1c4225be5112903071c450a2044462adc46e81bc4c98e3a1a5096b146069686250895dae00d0bdb7e1fbc2627325666e9b744d
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
