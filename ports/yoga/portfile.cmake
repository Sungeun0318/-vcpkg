include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/yoga
    REF 1.16.0
    SHA512 ad53c3008f9d934b53350927c68fb91391bf2e973f05a446e4819fe424a9334f6d9f06bc14c50d5c310c83d3ba8482a920d640c9bce21a8483d7195c798bbe34
    HEAD_REF master
    PATCHES add-project-declaration.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_build_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/yoga DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")

set(YOGA_LIB_PREFFIX )
if (NOT VCPKG_TARGET_IS_WINDOWS)
    set(YOGA_LIB_PREFFIX lib)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(YOGA_BINARY_PATH )
    if (VCPKG_TARGET_IS_WINDOWS)
        set(YOGA_BINARY_PATH Release/)
    endif()
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${YOGA_BINARY_PATH}${YOGA_LIB_PREFFIX}yogacore${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(YOGA_BINARY_PATH )
    if (VCPKG_TARGET_IS_WINDOWS)
        set(YOGA_BINARY_PATH Debug/)
    endif()
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${YOGA_BINARY_PATH}${YOGA_LIB_PREFFIX}yogacore${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)