# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/io
    REF boost-${VERSION}
    SHA512 1297ead38cde0c8859a43270dbb6d4e47050350fc22a3152b7f0b2f488ac3ed841f9ebb0f6c8ba40c56a93a700d5bb4656f9498dd9153040385509493e5dd9b9
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
