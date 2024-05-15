# Overwrite builtin scripts
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_configure_meson.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_install_meson.cmake")

set(meson_path_hash @MESON_PATH_HASH@)
string(SUBSTRING "${meson_path_hash}" 0 7 meson_short_hash)

# Setup meson:
set(program MESON)
set(program_version @VERSION@)
set(program_name meson)
set(search_names meson meson.py)
set(ref 14de8ac5a9e04490a67e3ddcbd44b31915aed1b9)
set(path_to_search "${DOWNLOADS}/tools/meson-${program_version}-${meson_short_hash}")
set(download_urls "https://github.com/mesonbuild/meson/archive/${ref}.tar.gz")
set(download_filename "meson-${ref}.tar.gz")
set(download_sha512 489928a7e7171c6b4286edfc9ea20082960ca5584c269e926ee767eec3482c60c0efbbaef1b76d8b636ccfb522bda20537986b36879e8afc0fc85eb59d7bbe2f)

find_program(SCRIPT_MESON NAMES ${search_names} PATHS "${path_to_search}" NO_DEFAULT_PATH) # NO_DEFAULT_PATH due top patching

if(NOT SCRIPT_MESON)
    vcpkg_download_distfile(archive_path
        URLS ${download_urls}
        SHA512 "${download_sha512}"
        FILENAME "${download_filename}"
    )
    file(REMOVE_RECURSE "${path_to_search}")
    file(REMOVE_RECURSE "${path_to_search}-tmp")
    file(MAKE_DIRECTORY "${path_to_search}-tmp")
    file(ARCHIVE_EXTRACT INPUT "${archive_path}"
        DESTINATION "${path_to_search}-tmp"
        #PATTERNS "**/mesonbuild/*" "**/*.py"
        )
    z_vcpkg_apply_patches(
        SOURCE_PATH "${path_to_search}-tmp/meson-${ref}"
        PATCHES
            "${CMAKE_CURRENT_LIST_DIR}/adjust-args.patch"
            "${CMAKE_CURRENT_LIST_DIR}/meson-intl.patch"
            "${CMAKE_CURRENT_LIST_DIR}/adjust-python-dep.patch"
            "${CMAKE_CURRENT_LIST_DIR}/remove-freebsd-pcfile-specialization.patch"
    )
    file(MAKE_DIRECTORY "${path_to_search}")
    file(RENAME "${path_to_search}-tmp/meson-${ref}/meson.py" "${path_to_search}/meson.py")
    file(RENAME "${path_to_search}-tmp/meson-${ref}/mesonbuild" "${path_to_search}/mesonbuild")
    file(REMOVE_RECURSE "${path_to_search}-tmp")
    set(SCRIPT_MESON "${path_to_search}/meson.py")
endif()

# Check required python version
vcpkg_find_acquire_program(PYTHON3)
vcpkg_execute_required_process(COMMAND "${PYTHON3}" --version
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "python3-version-${TARGET_TRIPLET}")

file(READ "${CURRENT_BUILDTREES_DIR}/python3-version-${TARGET_TRIPLET}-out.log" version_contents)
string(REGEX MATCH [[[0-9]+\.[0-9]+\.[0-9]+]] python_ver "${version_contents}")

set(min_required 3.7)
if(python_ver VERSION_LESS "${min_required}")
    message(FATAL_ERROR "Found Python version '${python_ver} at ${PYTHON3}' is insufficient for meson. meson requires at least version '${min_required}'")
else()
    message(STATUS "Found Python version '${python_ver} at ${PYTHON3}'")
endif()

message(STATUS "Using meson: ${SCRIPT_MESON}")
