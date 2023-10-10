vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/SkyrimScripting/PluginInfoNG.git
    REF 6d97d5de3ea9eb73bf42a197c2f610c0770cb941
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

message(STATUS "Debug folder contents:")
file(GLOB DEBUG_CONTENTS "${CURRENT_PACKAGES_DIR}/debug/*")
foreach(item ${DEBUG_CONTENTS})
    message(STATUS "   ${item}")
endforeach()

file(INSTALL "${CURRENT_PACKAGES_DIR}/debug/skse_plugin_info_ng.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/skse_plugin_info_ng.lib")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
