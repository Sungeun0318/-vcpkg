vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.bz2"
    FILENAME "postgresql-${VERSION}.tar.bz2"
    SHA512 115a8a4234791bba4e6dcc4617e9dd77abedcf767894ce9472c59cce9d5d4ef2d4e1746f3a0c7a99de4fc4385fb716652b70dce9f48be45a9db5a682517db7e8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        patches/fix-configure.patch
        patches/single-linkage.patch
        patches/no-server-tools.patch
        patches/mingw-install.patch
        patches/python.patch
        patches/windows/install.patch
        patches/windows/macro-def.patch
        patches/windows/python_lib.patch
        patches/windows/win_bison_flex.patch
        patches/windows/msbuild.patch
        patches/windows/spin_delay.patch
)

if("client" IN_LIST FEATURES)
    set(HAS_TOOLS TRUE)
else()
    set(HAS_TOOLS FALSE)
endif()

set(required_programs PERL)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND required_programs BISON FLEX)
endif()
foreach(program_name IN LISTS required_programs)
    # Need to rename win_bison and win_flex to just bison and flex
    vcpkg_find_acquire_program(${program_name})
    get_filename_component(program_dir ${${program_name}} DIRECTORY)
    vcpkg_add_to_path(PREPEND "${program_dir}")
endforeach()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

if(VCPKG_DETECTED_MSVC)
    if("nls" IN_LIST FEATURES)
        vcpkg_acquire_msys(MSYS_ROOT PACKAGES gettext)
        vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    endif()
    if("xml" IN_LIST FEATURES)
        x_vcpkg_pkgconfig_get_modules(
            PREFIX PC_LIBXML2
            MODULES --msvc-syntax libxml-2.0
            LIBS
        )
        separate_arguments(LIBXML2_LIBS_DEBUG NATIVE_COMMAND "${PC_LIBXML2_LIBS_DEBUG}")
        separate_arguments(LIBXML2_LIBS_RELEASE NATIVE_COMMAND "${PC_LIBXML2_LIBS_RELEASE}")
        message((STATUS "LIBXML2_LIBS_RELEASE: ${LIBXML2_LIBS_RELEASE}"))
    endif()
    if("xslt" IN_LIST FEATURES)
        x_vcpkg_pkgconfig_get_modules(
            PREFIX PC_LIBXSLT
            MODULES --msvc-syntax libxslt
            LIBS
        )
        separate_arguments(LIBXSLT_LIBS_DEBUG NATIVE_COMMAND "${PC_LIBXSLT_LIBS_DEBUG}")
        separate_arguments(LIBXSLT_LIBS_RELEASE NATIVE_COMMAND "${PC_LIBXSLT_LIBS_RELEASE}")
        message((STATUS "LIBXSLT_LIBS_RELEASE: ${LIBXSLT_LIBS_RELEASE}"))
    endif()

    include("${CMAKE_CURRENT_LIST_DIR}/build-msvc.cmake")
    if(NOT VCPKG_BUILD_TYPE)
        build_msvc(DEBUG "${SOURCE_PATH}")
    endif()
    build_msvc(RELEASE "${SOURCE_PATH}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()

    if(HAS_TOOLS)
        vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    else()
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")
    endif()
else()
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/Makefile" DESTINATION "${SOURCE_PATH}")

    vcpkg_list(SET BUILD_OPTS)
    foreach(option IN ITEMS icu lz4 nls openssl python readline xml xslt zlib zstd)
        if(option IN_LIST FEATURES)
            list(APPEND BUILD_OPTS --with-${option})
        else()
            list(APPEND BUILD_OPTS --without-${option})
        endif()
    endforeach()
    if("nls" IN_LIST FEATURES)
        set(ENV{MSGFMT} "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin/msgfmt${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        if(VCPKG_TARGET_IS_ANDROID)
            list(APPEND BUILD_OPTS [[LIBS=$LIBS -liconv]])
        endif()
    endif()
    if("python" IN_LIST FEATURES)
        vcpkg_find_acquire_program(PYTHON3)
        list(APPEND BUILD_OPTS "PYTHON=${PYTHON3}")
    endif()
    if(VCPKG_TARGET_IS_ANDROID) # AND CMAKE_SYSTEM_VERSION LESS 26)
        list(APPEND BUILD_OPTS ac_cv_header_langinfo_h=no)
    endif()
    if(VCPKG_DETECTED_CMAKE_OSX_SYSROOT)
        list(APPEND BUILD_OPTS "PG_SYSROOT=${VCPKG_DETECTED_CMAKE_OSX_SYSROOT}")
    endif()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
        AUTOCONFIG
        ADDITIONAL_MSYS_PACKAGES autoconf-archive
            DIRECT_PACKAGES
                "https://mirror.msys2.org/msys/x86_64/tzcode-2023c-1-x86_64.pkg.tar.zst"
                7550b843964744607f736a7138f10c6cd92489406a1b84ac71d9a9d8aa16bc69048aa1b24e1f49291b010347047008194c334ca9c632e17fa8245e85549e3c7a
        OPTIONS
            ${BUILD_OPTS}
        OPTIONS_DEBUG
            --enable-debug
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(ENV{LIBPQ_LIBRARY_TYPE} shared)
    else()
        set(ENV{LIBPQ_LIBRARY_TYPE} static)
    endif()
    if(VCPKG_TARGET_IS_MINGW)
        set(ENV{LIBPQ_USING_MINGW} yes)
    endif()
    if(HAS_TOOLS)
        set(ENV{LIBPQ_ENABLE_TOOLS} yes)
    endif()
    vcpkg_install_make()

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/postgresql/server/pg_config.h" "#define CONFIGURE_ARGS" "// #define CONFIGURE_ARGS")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pg_config.h" "#define CONFIGURE_ARGS" "// #define CONFIGURE_ARGS")
endif()

vcpkg_fixup_pkgconfig()
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/postgresql/vcpkg-cmake-wrapper.cmake" @ONLY)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/doc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/symbols"
    "${CURRENT_PACKAGES_DIR}/debug/tools"
    "${CURRENT_PACKAGES_DIR}/symbols"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
