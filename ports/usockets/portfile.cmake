IF (NOT VCPKG_TARGET_IS_LINUX)
   set(USE_LIBUV ON)
EndIF ()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF 0a81a97aa2182cbf55a38bc18196ef6c535c3981 # v0.6.0
    SHA512 244f8111a5e42d7b12094d6d5e3ddd4848b71477f74d023874cdb70799aa4c86322608a4483ff3e1a4029db9c51c06462460f9f89456692c75fbad754e2c3384
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if ("network" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "Feature network only support Windows")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    ssl CMAKE_USE_OPENSSL
    event CMAKE_USE_EVENT
    network CMAKE_USE_NETWORK
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DLIBUS_USE_LIBUV=${USE_LIBUV}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()