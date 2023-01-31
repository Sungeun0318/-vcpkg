set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_ENV_PASSTHROUGH GameDKLatest GRDKLatest GXDKLatest)
set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DXBOX_CONSOLE_TARGET=scarlett")
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../../scripts/toolchains/xbox.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON)
set(VCPKG_TARGET_IS_XBOX ON)
set(VCPKG_TARGET_IS_XBOX_SCARLETT ON)
