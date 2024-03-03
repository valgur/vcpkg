vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fixstars/libSGM
    REF "${VERSION}"
    SHA512 993573fc460f26e17aba9356b3ca90d8a402ffda47cbf3462cc20472098edc8f2131d3dbcd48be1be7d10d246e9da6f15b0fdabf6a622528b67f59a1e8e7cb4b
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBSGM_SHARED=${BUILD_SHARED}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(COPY "${CURRENT_PACKAGES_DIR}/FindLibSGM.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/FindLibSGM.cmake")
file(REMOVE "${CURRENT_PACKAGES_DIR}/FindLibSGM.cmake")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
