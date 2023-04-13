vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-api-headers
  REF 4b2f44fcd456338e4fd18d5d8c0eb7c4663e8080
  SHA512 0
  HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
  vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
  vcpkg_cmake_install()
endif()

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME "node")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-${PORT}-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)
