# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/tokenizer
    REF boost-${VERSION}
    SHA512 dc6fa4cc24eb6c2ecd92032a1b004a826408e2800b285a164e78663c9f78570b50fbde919ab1d3e0b818690f0352b63194df2511f78e7c14996293be416df154
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
