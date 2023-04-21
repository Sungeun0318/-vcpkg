z_vcpkg_underlying_find_package(${ARGS})

if("@VCPKG_LIBRARY_LINKAGE@" STREQUAL "static")
    if(NOT "@VCPKG_TARGET_IS_WINDOWS@")
        find_package(Iconv REQUIRED)
    endif()
    if("@EXIV2_ENABLE_NLS@")
        find_package(Intl REQUIRED)
    endif()
    if(TARGET exiv2lib)
        if(NOT "@VCPKG_TARGET_IS_WINDOWS@")
            set_property(TARGET exiv2lib APPEND PROPERTY INTERFACE_LINK_LIBRARIES Iconv::Iconv)
        endif()
        if("@EXIV2_ENABLE_NLS@")
            set_property(TARGET exiv2lib APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${Intl_LIBRARIES})
        endif()
    endif()
endif()
