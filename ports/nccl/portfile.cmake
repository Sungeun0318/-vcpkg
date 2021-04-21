vcpkg_fail_port_install(ON_TARGET "Windows" "OSX" ON_ARCH "x86" "arm")

include(${CURRENT_INSTALLED_DIR}/share/cuda/vcpkg_find_cuda.cmake)
vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT OUT_CUDA_VERSION CUDA_VERSION)

# Version of NCCL available on Conda for download if NCCL isn't found
set(MINIMUM_NCCL_VERSION "2.4.6.1")
set(NCCL_FULL_VERSION "${MINIMUM_NCCL_VERSION}-cuda10.1_0")
string(REPLACE "." ";" VERSION_LIST ${MINIMUM_NCCL_VERSION})
list(GET VERSION_LIST 0 MINIMUM_NCCL_VERSION_MAJOR)
list(GET VERSION_LIST 1 MINIMUM_NCCL_VERSION_MINOR)
list(GET VERSION_LIST 2 MINIMUM_NCCL_VERSION_PATCH)

# Try to find NCCL if it exists; only download if it doesn't exist
set(NCCL_PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
find_package(NCCL ${MINIMUM_NCCL_VERSION})
set(CMAKE_MODULE_PATH ${NCCL_PREV_MODULE_PATH})


# Download or return
if(NCCL_FOUND)
  message(STATUS "Using NCCL ${_NCCL_VERSION} located on system.")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

elseif (CUDA_VERSION VERSION_EQUAL "10.1")

  message(STATUS "NCCL not found on system, but system contains a CUDA"
    " version (10.1) compatible with NCCL available on conda. Downloading...")

  vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

  set(NCCL_DOWNLOAD_LINK "https://anaconda.org/nvidia/nccl/${MINIMUM_NCCL_VERSION}/download/linux-64/nccl-${NCCL_FULL_VERSION}.tar.bz2")
  set(SHA512_NCCL "0fe69ad559f70aab97c78906296e2b909b4a9c042a228a2770252b3d03016c7c39acce3c0e0bd0ba651abd63471743dcffdfec307c486989c6e5745634aabde1")
  set(NCCL_OS "linux")

  vcpkg_download_distfile(ARCHIVE
      URLS ${NCCL_DOWNLOAD_LINK}
      FILENAME "nccl-${NCCL_FULL_VERSION}-${NCCL_OS}.tar.bz2"
      SHA512 ${SHA512_NCCL}
  )

  vcpkg_extract_source_archive_ex(
      OUT_SOURCE_PATH SOURCE_PATH
      ARCHIVE ${ARCHIVE}
      NO_REMOVE_ONE_LEVEL
  )

  file(INSTALL "${SOURCE_PATH}/include/nccl.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
  file(INSTALL "${SOURCE_PATH}/include/nccl_net.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)

  file(INSTALL "${SOURCE_PATH}/lib/libnccl.so" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libnccl.so.${MINIMUM_NCCL_VERSION_MAJOR}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libnccl.so.${MINIMUM_NCCL_VERSION_MAJOR}.${MINIMUM_NCCL_VERSION_MINOR}.${MINIMUM_NCCL_VERSION_PATCH}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

  file(INSTALL "${SOURCE_PATH}/info/licenses/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindNCCL.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

else()
  # NCCL NOT FOUND AND IS NOT AUTO-DOWNLOADABLE
  message(FATAL_ERROR "Can't download NCCL for your CUDA version. Please manually install NCCL for CUDA v${CUDA_VERSION}. Download: https://developer.nvidia.com/nccl")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
