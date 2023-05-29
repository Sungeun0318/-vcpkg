string(REGEX REPLACE "^([0-9]+)[.]([0-9]+)[.]([0-9]+)[.]([0-9]+)" "\\1,0\\2,0\\3,0\\4," SQLITE_VERSION "${VERSION}.0")
string(REGEX REPLACE "^([0-9]+),0*([0-9][0-9]),0*([0-9][0-9]),0*([0-9][0-9])," "\\1\\2\\3\\4" SQLITE_VERSION "${SQLITE_VERSION}")

vcpkg_download_distfile(ARCHIVE
    URLS "https://sqlite.org/2023/sqlite-amalgamation-${SQLITE_VERSION}.zip"
    FILENAME "sqlite-amalgamation-${SQLITE_VERSION}.zip"
    SHA512 76416dc40dd15611f59d7209087a08c6cf1b7584dee34da4ce11b75acd7f608d794747a7ed87c3ffe16b237699279c2da8f85b009a379e108d39f33bd727e1e1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-arm-uwp.patch
        add-config-include.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if(VCPKG_TARGET_IS_WINDOWS)
        set(SQLITE_API "__declspec(dllimport)")
    else()
        set(SQLITE_API "__attribute__((visibility(\"default\")))")
    endif()
else()
    set(SQLITE_API "")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS Unused
    FEATURES
        dbstat              SQLITE_ENABLE_DBSTAT_VTAB
        fts3                SQLITE_ENABLE_FTS3
        fts4                SQLITE_ENABLE_FTS4
        fts5                SQLITE_ENABLE_FTS5
        memsys3             SQLITE_ENABLE_MEMSYS3
        memsys5             SQLITE_ENABLE_MEMSYS5
        math                SQLITE_ENABLE_MATH_FUNCTIONS
        limit               SQLITE_ENABLE_UPDATE_DELETE_LIMIT
        rtree               SQLITE_ENABLE_RTREE
        session             SQLITE_ENABLE_SESSION
        session             SQLITE_ENABLE_PREUPDATE_HOOK
        omit-load-extension SQLITE_OMIT_LOAD_EXTENSION
        geopoly             SQLITE_ENABLE_GEOPOLY
        json1               SQLITE_ENABLE_JSON1
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(SQLITE_OS_WIN "1")
    if(VCPKG_TARGET_IS_UWP)
        set(SQLITE_OS_WINRT "1")
    endif()
else()
    set(SQLITE_OS_UNIX "1")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/sqlite3.pc.in" DESTINATION "${SOURCE_PATH}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/sqlite3-vcpkg-config.h.in" "${SOURCE_PATH}/sqlite3-vcpkg-config.h" @ONLY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zlib                WITH_ZLIB
    INVERTED_FEATURES
        tool                SQLITE3_SKIP_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPKGCONFIG_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DSQLITE3_SKIP_TOOLS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT} CONFIG_PATH share/unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES sqlite3 DESTINATION "${CURRENT_PACKAGES_DIR}/tools" AUTO_CLEAN)
endif()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/sqlite3-config.in.cmake"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-sqlite3-config.cmake"
    @ONLY
)

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "SQLite is in the Public Domain.\nhttp://www.sqlite.org/copyright.html\n")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
