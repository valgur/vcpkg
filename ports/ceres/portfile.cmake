set(MSVC_USE_STATIC_CRT_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        message(FATAL_ERROR "Ceres does not support mixing static CRT and dynamic library linkage")
    endif()
    set(MSVC_USE_STATIC_CRT_VALUE ON)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ceres-solver/ceres-solver
    REF ${VERSION}
    SHA512 d4cefe5851e25bd3c7b76352092d8d549eb371af2e35a325736554c54fe58a3523658697c3e2d65af660fe6895ae3d96fe31bd1875870474fc4b6fed3bbdfae9
    HEAD_REF master
    PATCHES
        0001_find-package-required.patch
        0003_fix_exported_ceres_config.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindCXSparse.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindEigen.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindMETIS.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "schur"             SCHUR_SPECIALIZATIONS
        "suitesparse"       SUITESPARSE
        "cxsparse"          CXSPARSE
        "lapack"            LAPACK
        "eigensparse"       EIGENSPARSE
        "tools"             GFLAGS
        "cuda"              CUDA
)
if(VCPKG_TARGET_IS_UWP)
    list(APPEND FEATURE_OPTIONS -DMINIGLOG=ON)
endif()

foreach (FEATURE ${FEATURE_OPTIONS})
    message(STATUS "${FEATURE}")
endforeach()

set(TARGET_OPTIONS )
if(VCPKG_TARGET_IS_IOS)
    # Note: CMake uses "OSX" not just for macOS, but also iOS, watchOS and tvOS.
    list(APPEND TARGET_OPTIONS "-DIOS_DEPLOYMENT_TARGET=${VCPKG_OSX_DEPLOYMENT_TARGET}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${TARGET_OPTIONS}
        -DEXPORT_BUILD_DIR=ON
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARKS=OFF
        -DPROVIDE_UNINSTALL_TARGET=OFF
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT_VALUE}
        -DLIB_SUFFIX=${LIB_SUFFIX}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib${LIB_SUFFIX}/cmake/Ceres")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
