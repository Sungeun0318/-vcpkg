if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp
    REF v1.0.0-rc4
    SHA512 93de3e61b6bd0a9237cf81dedbcdb078fb92c1dc562975c82134d791ad911d4d3c0e717f390a0a993fbeda5d5c90206c0e7a0c7085e58d9cfefbc9fd4ff209d2
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        etw WITH_ETW
        otlp WITH_OTLP
        zipkin WITH_ZIPKIN
        prometheus WITH_PROMETHEUS
        elasticsearch WITH_ELASTICSEARCH
        jaeger WITH_JAEGER
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        -DWITH_EXAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/opentelemetry-cpp RENAME copyright)
