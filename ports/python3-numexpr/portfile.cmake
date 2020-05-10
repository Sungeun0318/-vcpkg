vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/pydata/numexpr/archive/d274455bc6a092cb49c0606f61a67c61afb86f72.zip"
    FILENAME "numexpr.zip"
    SHA512 2e248bbed52ebaa2b12aa35dc45dcaed716453599882fa51d95574a5dda8af92b3f3a6dcd4c059f762978e619c423291ac1ea24c82ad9e23dfc7322c28767ba0
)

vcpkg_extract_source_archive_ex(OUT_SOURCE_PATH SOURCE_PATH ARCHIVE ${ARCHIVE})
vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
