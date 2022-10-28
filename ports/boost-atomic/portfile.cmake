# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/atomic
    REF boost-1.80.0
    SHA512 c4fc4262deca9fbfbed4202c8965cbd7f569cbdbc4808abb8db102bbc2a742704757a2dd2f3cb750da3ac37774a590a1a7336f18f5f713ce6dfcf3f331b35a9c
    HEAD_REF master
)

vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile.v2"
    "project.load [ path.join [ path.make $(here:D) ] ../../config/checks/architecture ]"
    "project.load [ path.join [ path.make $(here:D) ] ../config/checks/architecture ]"
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/config")
include("${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake")
boost_modular_build(SOURCE_PATH "${SOURCE_PATH"
include("${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake")
boost_modular_headers(SOURCE_PATH "${SOURCE_PATH}")

file(INSTALL "${SOURCE_PATH}/config/has_synchronization_lib.cpp" DESTINATION "${CURRENT_PACKAGES_DIR}/share/boost-build")
