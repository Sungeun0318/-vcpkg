vcpkg_download_distfile(
    ARCHIVE_PATH
    URLS
        "https://invisible-mirror.net/archives/ncurses/ncurses-${VERSION}.tar.gz"
        "ftp://ftp.invisible-island.net/ncurses/ncurses-${VERSION}.tar.gz"
        "https://ftp.gnu.org/gnu/ncurses/ncurses-${VERSION}.tar.gz"
    FILENAME "ncurses-${VERSION}.tgz"
    SHA512 1c2efff87a82a57e57b0c60023c87bae93f6718114c8f9dc010d4c21119a2f7576d0225dab5f0a227c2cfc6fb6bdbd62728e407f35fce5bf351bb50cf9e0fd34
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE_PATH}"
)

vcpkg_list(SET OPTIONS)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS
        --with-cxx-shared
        --with-shared    # "lib model"
        --without-normal # "lib model"
    )
endif()

if(NOT VCPKG_TARGET_IS_MINGW)
    list(APPEND OPTIONS
        --enable-mixed-case
    )
endif()

if(VCPKG_TARGET_IS_MINGW)
    list(APPEND OPTIONS
        --disable-home-terminfo
        --enable-term-driver
        --disable-termcap
    )
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    DETERMINE_BUILD_TRIPLET
    NO_ADDITIONAL_PATHS
    OPTIONS
        ${OPTIONS}
        --disable-db-install
        --enable-pc-files
        --enable-overwrite
        --enable-widec
        --without-ada
        --without-debug # "lib model"
        --without-manpages
        --without-progs
        --without-tack
        --without-tests
        --with-pkg-config-libdir=libdir
)
vcpkg_install_make()

vcpkg_fixup_pkgconfig()

set(suffix "a")
if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "shared")
	set(suffix "so")
endif()

# Install non-wide pkgconfig files to fool packages that need them.
foreach(file "ncurses" "ncurses++" "form" "panel" "menu")
    file(WRITE "${CURRENT_PACKAGES_DIR}/lib/lib${file}.${suffix}" "INPUT(-l${file}w)\n")
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/lib${file}.${suffix}" "INPUT(-l${file}w)\n")
    file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${file}w.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${file}.pc")
endforeach()
foreach(file "tic" "tinfo")
    file(WRITE "${CURRENT_PACKAGES_DIR}/lib/lib${file}.${suffix}" "INPUT(-lncursesw)\n")
    file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/lib${file}.${suffix}" "INPUT(-lncursesw)\n")
    file(COPY_FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ncursesw.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${file}.pc")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
