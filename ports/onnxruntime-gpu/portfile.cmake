vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(VERSION 1.12.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/microsoft/onnxruntime/releases/download/v1.12.1/onnxruntime-win-x64-gpu-1.12.1.zip"
    FILENAME "onnxruntime-win-x64-gpu-1.12.1.zip"
    SHA512 eea4d95189da1dc0358673d09d66b6c2880cb66333d76d6c6d54cacc87ac04a7a52f4aa911da02c40bc86718e584d130e492d7a0499ed0daa323194c05d41960
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
    REF ${VERSION}
)

file(MAKE_DIRECTORY
        ${CURRENT_PACKAGES_DIR}/include
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/lib
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )

file(COPY
        ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/include
        DESTINATION ${CURRENT_PACKAGES_DIR}
    )

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_cuda.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_cuda.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_cuda.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_cuda.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_shared.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_shared.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_tensorrt.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_tensorrt.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_shared.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_shared.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_tensorrt.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_tensorrt.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_shared.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_shared.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_tensorrt.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_tensorrt.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_cuda.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/lib/onnxruntime_providers_cuda.dll
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
# # Handle copyright
file(INSTALL ${SOURCE_PATH}/onnxruntime-win-x64-gpu-1.12.1/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
