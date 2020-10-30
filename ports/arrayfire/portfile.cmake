vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/arrayfire
    REF v3.7.1
    SHA512 0a4d03ade95c6e587715865e039ba03beb5194040545c4c20f1729f0a3c953112624259e6068a6ce93d41838001fc9ffa1fbf122eabf1b08526cb9e0ba51c77e
    HEAD_REF master
    PATCHES submodules.patch
)

# arrayfire cpu thread lib needed as a submodule for the CPU backend
vcpkg_from_github(
  OUT_SOURCE_PATH CPU_THREADS_PATH
  REPO arrayfire/threads
  REF 6a967802fc161f08c5fa1c433601e233fda3eef6
  SHA512 397d787cbaa2fc628e3b82279fa5dd14a2ea8ee9c1d64c418674f53ba52a36dc120feadf9e00e2a55178cc3c9a989cf082a0f10e68782eb174ef0dc2c4b35e12
  HEAD_REF master
  )

################################### Build ###################################

# Default flags
set(AF_DEFAULT_VCPKG_CMAKE_FLAGS
  -DBUILD_TESTING=OFF
  -DAF_BUILD_DOCS=OFF
  -DAF_BUILD_EXAMPLES=OFF
  -DAF_CPU_THREAD_PATH=${CPU_THREADS_PATH} # for building the arrayfire cpu threads lib
  )

# bin/dll directory for Windows non-static builds for the unified backend dll
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(AF_BIN_DIR ${CURRENT_PACKAGES_DIR}/bin)
  endif()
  if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(AF_BIN_DIR ${CURRENT_PACKAGES_DIR}/debug/bin)
  endif()
  
  file(MAKE_DIRECTORY ${AF_BIN_DIR})
  set(AF_DEFAULT_VCPKG_CMAKE_FLAGS ${AF_DEFAULT_VCPKG_CMAKE_FLAGS} -DAF_INSTALL_BIN_DIR=${AF_BIN_DIR})
endif()

if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  message(WARNING "NOTE: Windows support with static linkeage is still experimental.")
endif()

# Determine which backend to build via specified feature
vcpkg_check_features(
  OUT_FEATURE_OPTIONS AF_BACKEND_FEATURE_OPTIONS
  FEATURES
    unified AF_BUILD_UNIFIED
    cpu AF_BUILD_CPU
    cuda AF_BUILD_CUDA
    opencl AF_BUILD_OPENCL
)

# Build and install
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${AF_DEFAULT_VCPKG_CMAKE_FLAGS} ${AF_BACKEND_FEATURE_OPTIONS}
)  
vcpkg_install_cmake()

if (VCPKG_TARGET_IS_WINDOWS)
  vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
  vcpkg_fixup_cmake_targets(CONFIG_PATH share/ArrayFire/cmake)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Copyright and license
file(INSTALL ${SOURCE_PATH}/COPYRIGHT.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME license)
