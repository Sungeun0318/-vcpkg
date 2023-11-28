vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eyalroz/cuda-api-wrappers
    REF v0.6.6
    SHA512 4bc095513ed1a40f7239810abf7f6edcfde5471a89de8cf27a76038f6a54f6234542693bb606cc5e389403f3d12cb186b5a9cfb31c2bf3e437c112d215fb872d
    HEAD_REF master
)

vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT)
message(STATUS "CUDA_TOOLKIT_ROOT ${CUDA_TOOLKIT_ROOT}")

# windows nvcc compiler path
if (WIN32)
    set(CMAKE_CUDA_COMPILER "${CUDA_TOOLKIT_ROOT}/bin/nvcc.exe")
endif()

# linux nvcc compiler path
if (UNIX)
    set(CMAKE_CUDA_COMPILER "${CUDA_TOOLKIT_ROOT}/bin/nvcc")
endif()

set(CUDA_ARCHITECTURES "native")

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
	-DCAW_BUILD_EXAMPLES=OFF
	-DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
    -DCMAKE_CUDA_COMPILER=${CMAKE_CUDA_COMPILER}
	)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
PACKAGE_NAME cuda-api-wrappers
CONFIG_PATH lib/cmake
)

set(CAW_CMAKE_PACKAGE_FILES_DIR ${CURRENT_PACKAGES_DIR}/share/cuda-api-wrappers)

file(GLOB packageFiles ${CAW_CMAKE_PACKAGE_FILES_DIR}/cuda-api-wrappers/*)
foreach(pkgFile ${packageFiles})
	get_filename_component(fileName ${pkgFile} NAME)
    file(RENAME ${pkgFile} ${CAW_CMAKE_PACKAGE_FILES_DIR}/${fileName})
endforeach()

file(REMOVE_RECURSE "${CAW_CMAKE_PACKAGE_FILES_DIR}/cuda-api-wrappers")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
