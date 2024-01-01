# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/unordered
    REF boost-1.83.0
    SHA512 52a36f1d279c6fd9e6b480267aa3cb6cab64e3c996230b0bf585973067bf845711f30a8f79402263236420ebbb6e856bbc9e1c6c2dd72e416f571bff150f858a
    HEAD_REF master
    PATCHES 0001-unordered-fix-copy-assign.patch
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
