# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/tti
    REF boost-${VERSION}
    SHA512 4908501e9e4abb1c935fd6faece37790a7487c88c8bff92848b964cb367bd3e4b499514436856a22d9d1f4cc704dc1c7e69ac1aea51c690cdd1047003573ffe3
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
