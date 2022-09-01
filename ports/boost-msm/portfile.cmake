# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/msm
    REF boost-1.80.0
    SHA512 52e7e59d54d108a260c059f5e668b802fb0535fdeab9e0d7901eae626ab4a3b785b4e0b87694e0732993f9813f5af6f7566d20da1f503df207a1b98820cd9e8f
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
