set(IGN_GRAPH_PREV_MODULE_PATH "${CMAKE_MODULE_PATH}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../ignition-cmake2")

_find_package(${ARGS})

set(CMAKE_MODULE_PATH "${IGN_GRAPH_PREV_MODULE_PATH}")
