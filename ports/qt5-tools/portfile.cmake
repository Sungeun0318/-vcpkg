include(vcpkg_common_functions)

include(${CURRENT_INSTALLED_DIR}/share/qt5modularscripts/qt_modular_library.cmake)

qt_modular_library(qttools cf690c630db79b4cd86d5d608175fb2c5463a985d7cb8a592c0995db04593c2c2ddddb52a3dc21348462639efdd3f9c57d3897a8384708b912b42cf1ac2c7482)

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/qt5-tools/platforminputcontexts)