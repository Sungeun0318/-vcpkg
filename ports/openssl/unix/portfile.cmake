if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make perl)
    set(MAKE "${MSYS_ROOT}/usr/bin/make.exe")
    set(PERL "${MSYS_ROOT}/usr/bin/perl.exe")
else()
    find_program(MAKE make)
    if(NOT MAKE)
        message(FATAL_ERROR "Could not find make. Please install it through your package manager.")
    endif()
endif()

if(VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(OPENSSL_SHARED shared)
else()
    set(OPENSSL_SHARED no-shared no-module)
endif()

set(INTERPRETER "${PERL}")

set(CONFIGURE_OPTIONS
    enable-static-engine
    enable-capieng
    no-ssl2
    no-tests
    ${OPENSSL_SHARED}
)

if(DEFINED OPENSSL_USE_NOPINSHARED)
    set(CONFIGURE_OPTIONS ${CONFIGURE_OPTIONS} no-pinshared)
endif()

if(OPENSSL_NO_AUTOLOAD_CONFIG)
    set(CONFIGURE_OPTIONS ${CONFIGURE_OPTIONS} no-autoload-config)
endif()

if(VCPKG_TARGET_IS_ANDROID)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH android-arm64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(OPENSSL_ARCH android-arm)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(OPENSSL_ARCH android-x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(OPENSSL_ARCH android-x86)
    else()
        message(FATAL_ERROR "Unknown iOS target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH linux-aarch64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(OPENSSL_ARCH linux-armv4)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(OPENSSL_ARCH linux-x86_64)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
        set(OPENSSL_ARCH linux-x86)
    else()
        set(OPENSSL_ARCH linux-generic32)
    endif()
elseif(VCPKG_TARGET_IS_IOS)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH ios64-xcrun)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
        set(OPENSSL_ARCH ios-xcrun)
    elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86" OR VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(OPENSSL_ARCH iossimulator-xcrun)
    else()
        message(FATAL_ERROR "Unknown iOS target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    # disable that makes linkage error (e.g. require stderr usage)
    list(APPEND CONFIGURE_OPTIONS no-ui no-asm)
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
        set(OPENSSL_ARCH darwin64-arm64)
    else()
        set(OPENSSL_ARCH darwin64-x86_64)
    endif()
elseif(VCPKG_TARGET_IS_FREEBSD OR VCPKG_TARGET_IS_OPENBSD)
    set(OPENSSL_ARCH BSD-generic64)
elseif(VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(OPENSSL_ARCH mingw64)
    else()
        set(OPENSSL_ARCH mingw)
    endif()
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    set(INTERPRETER "$ENV{EMSDK}/upstream/emscripten/emconfigure")
    set(MAKE "$ENV{EMSDK}/upstream/emscripten/emmake")
    set(ENV{MAKE} "${MAKE}")
    vcpkg_list(APPEND CONFIGURE_OPTIONS
        threads
        no-engine
        no-asm
        no-sse2
        no-srtp
        --cross-compile-prefix=
    )
else()
    message(FATAL_ERROR "Unknown platform")
endif()

file(MAKE_DIRECTORY "${SOURCE_PATH}/vcpkg")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}/vcpkg")
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "vcpkg"
    NO_ADDITIONAL_PATHS
    OPTIONS
        "${INTERPRETER}"
        "${SOURCE_PATH}/Configure"
        ${OPENSSL_ARCH}
        ${CONFIGURE_OPTIONS}
        "--openssldir=/etc/ssl"
        "--libdir=lib"
)
vcpkg_install_make(BUILD_TARGET build_sw)
vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
foreach(script IN ITEMS "bin/c_rehash") # "misc/CA" "misc/tsget")
    file(COPY "${CURRENT_PACKAGES_DIR}/${script}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/${script}" "${CURRENT_PACKAGES_DIR}/debug/${script}")
endforeach()
vcpkg_copy_tools(TOOL_NAMES openssl AUTO_CLEAN)

file(TOUCH "${CURRENT_PACKAGES_DIR}/etc/ssl/certs/.keep")
file(TOUCH "${CURRENT_PACKAGES_DIR}/etc/ssl/private/.keep")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_MINGW)
    # For consistency with nmake build
    file(GLOB engines "${CURRENT_PACKAGES_DIR}/lib/ossl-modules/*.dll")
    if(engines)
        file(COPY ${engines} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/ossl-modules")
    endif()
    file(GLOB engines "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules/*.dll")
    if(engines)
        file(COPY ${engines} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/ossl-modules")
    endif()
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
