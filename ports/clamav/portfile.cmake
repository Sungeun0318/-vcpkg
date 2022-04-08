vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Cisco-Talos/clamav
  REF clamav-1.0.0
  SHA512 a1be526516e622fd3359461db7dd8eb0734f7ba8ecb0b63c1574e216885cd7bcdc69ffdbc5e507a0060d23769e3caa8423aa273ec57bb86e40049679a818152a
  FILE_DISAMBIGUATOR 1
  HEAD_REF main
  PATCHES
      "cmakefiles.patch"
)

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
      -DENABLE_LIBCLAMAV_ONLY=ON
      -DENABLE_SHARED_LIB=ON
      -DENABLE_STATIC_LIB=OFF
      -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/NEWS.md" "${CURRENT_PACKAGES_DIR}/debug/NEWS.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/README.md" "${CURRENT_PACKAGES_DIR}/debug/README.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/COPYING.txt" "${CURRENT_PACKAGES_DIR}/debug/COPYING.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# On Linux, clamav will still build and install clamav-config
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()
