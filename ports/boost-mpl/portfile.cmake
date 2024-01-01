# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/mpl
    REF boost-1.83.0
    SHA512 2c14736be6639110774b944218b5bbe77efabe92f74574c631cfd83c9df6df0fccecf8b11e6977a0438af4ba31677a05b6fcbaf6662c97877a4b2bab4a702c45
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
