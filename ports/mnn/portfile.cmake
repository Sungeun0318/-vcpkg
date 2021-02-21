vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp" "ios" "android")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/MNN
    REF 1.1.0
    SHA512 3e31eec9a876be571cb2d29e0a2bcdb8209a43a43a5eeae19b295fadfb1252dd5bd4ed5b7c584706171e1b531710248193bc04520a796963e2b21546acbedae0
    HEAD_REF master
    PATCHES
        use-package-and-install.patch
        fix-dllexport.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    test        MNN_BUILD_TEST
    tools       MNN_BUILD_TOOLS
    cuda        MNN_CUDA
    vulkan      MNN_VULKAN
    opencl      MNN_OPENCL
    metal       MNN_METAL
)

# 'cuda' feature in Windows failes with Ninja because of parallel PDB access. Make it optional
set(NINJA_OPTION PREFER_NINJA) 
if("cuda" IN_LIST FEATURES)
    unset(NINJA_OPTION)
endif()

if("test" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DMNN_BUILD_BENCHMARK=ON)
endif()
if("tools" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DMNN_BUILD_QUANTOOLS=ON
                              -DMNN_BUILD_TRAIN=ON 
                              -DMNN_BUILD_DEMO=ON 
                              -DMNN_EVALUATION=ON 
                              -DMNN_BUILD_CONVERTER=ON
    )
endif()
if("cuda" IN_LIST FEATURES OR "vulkan" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DMNN_GPU_TRACE=ON)
endif()
if("opencl" IN_LIST FEATURES OR "vulkan" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -DMNN_USE_SYSTEM_LIB=ON)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_RUNTIME_MT)
    list(APPEND PLATFORM_OPTIONS -DMNN_WIN_RUNTIME_MT=${USE_RUNTIME_MT})
elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    if("metal" IN_LIST FEATURES)
        list(APPEND PLATFORM_OPTIONS -DMNN_GPU_TRACE=ON)
    endif()
endif()
message(STATUS "Applying build options")
message(STATUS "  ${FEATURE_OPTIONS}")
message(STATUS "  ${BUILD_OPTIONS}")
message(STATUS "  ${PLATFORM_OPTIONS}")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    ${NINJA_OPTION}
    OPTIONS
        -DMNN_SEP_BUILD=OFF # build with backends/expression(no separate)
        -DMNN_BUILD_SHARED_LIBS=${BUILD_SHARED}
        ${FEATURE_OPTIONS} ${BUILD_OPTIONS} ${PLATFORM_OPTIONS}
        # 1.1.0.0-${commit}
        -DMNN_VERSION_MAJOR=1 -DMNN_VERSION_MINOR=1 -DMNN_VERSION_PATCH=0 -DMNN_VERSION_BUILD=0 -DMNN_VERSION_SUFFIX=-d6795ad
    OPTIONS_DEBUG
        -DMNN_DEBUG_MEMORY=ON -DMNN_DEBUG_TENSOR_SIZE=ON
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT})

file(INSTALL ${CURRENT_PORT_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    if("metal" IN_LIST FEATURES)
        file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mnn.metallib
                    ${CURRENT_PACKAGES_DIR}/share/${PORT}/mnn.metallib)
    endif()
else()
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if("test" IN_LIST FEATURES)
    # no install(TARGETS) for the following binaries. check the buildtrees...
    # vcpkg_copy_tools(
    #     TOOL_NAMES run_test.out benchmark.out benchmarkExprModels.out # test/
    #     AUTO_CLEAN
    # )
endif()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES MNNV2Basic.out mobilenetTest.out backendTest.out testModel.out testModelWithDescrisbe.out getPerformance.out checkInvalidValue.out timeProfile.out # tools/cpp
                   quantized.out # tools/quantization
                   classficationTopkEval.out # tools/evaluation
                   MNNDump2Json MNNConvert # tools/converter
                   transformer.out train.out dataTransformer.out runTrainDemo.out # tools/train
        AUTO_CLEAN
    )
    if(BUILD_SHARED)
        vcpkg_copy_tools(TOOL_NAMES TestConvertResult AUTO_CLEAN) # tools/converter
    endif()
    if(VCPKG_TARGET_IS_OSX)
        # no install(TARGETS) for the following binaries. check the buildtrees...
        # vcpkg_copy_tools(
        #     TOOL_NAMES checkDir.out checkFile.out winogradExample.out winogradGenerateGLSL.out winogradGenerateCL.out # tools/cpp
        #     AUTO_CLEAN
        # )
    endif()
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # remove the others. ex) mnn.metallib
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin
                        ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
