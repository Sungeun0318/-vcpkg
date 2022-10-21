_find_package(${ARGS})
if(TARGET X11::X11 AND TARGET X11::xcb)
    target_link_libraries(X11::X11 INTERFACE X11::xcb)
endif()
if(TARGET X11::xcb)
    if(TARGET X11::Xdmcp)
        set_property(TARGET X11::xcb APPEND PROPERTY INTERFACE_LINK_LIBRARIES X11::Xdmcp)
    endif()
    if(TARGET X11::Xau)
        set_property(TARGET X11::xcb APPEND PROPERTY INTERFACE_LINK_LIBRARIES X11::Xau)
    endif()
endif()
