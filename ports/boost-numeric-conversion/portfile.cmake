# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/numeric_conversion
    REF boost-1.73.0
    SHA512 1486a47eeef33e9db44215e0d6bde6ce409bffdaa7d5384b223bb30c2d6f8902bbe08a1b0f4a619527846875637c6fb0c80a57c2988cb8df63c54d5a3adf4a3c
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
