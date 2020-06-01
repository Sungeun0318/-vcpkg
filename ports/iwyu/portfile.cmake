vcpkg_fail_port_install(ON_TARGET "uwp")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO include-what-you-use/include-what-you-use
    REF 0.14
    SHA512 e54a7c7e3a6d3e0de7c263d1f26b373d95b8fab5f1f7e76f52d80341bda2bad0fb12238a325dc1e2f6d3ab5e6d8e0b4ed60b5a19dc82e06d480bcb461f9aefba
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# cleanup
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)

# license
file(INSTALL  ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# copy tools
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*")
list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
file(INSTALL ${BINARY_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(REMOVE ${BINARY_TOOLS})
file(GLOB BINARY_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*")
list(FILTER BINARY_TOOLS EXCLUDE REGEX "\\.dll\$")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
vcpkg_copy_tools(${CURRENT_PACKAGES_DIR}/tools/${PORT})