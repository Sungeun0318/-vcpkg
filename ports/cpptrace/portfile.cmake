vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO jeremy-rifkin/cpptrace
	REF 4b11b87e4d905d003d0325a53994441cc767017a
	SHA512
5ed41245ec7aef8d769d7a0718293817d93d75008abd1290b52a42b2c33bbc464fa91f1501856d68935489d81e4002634d26a21fc879eb7d5322327831ea2821
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/LICENSE"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright)
