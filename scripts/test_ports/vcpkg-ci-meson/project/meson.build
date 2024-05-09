project('vcpkg-ci-meson', 'c')

iconv_dep = dependency('iconv', required: true)
iconv_t = executable('iconv_t',
  sources: ['iconv_t.c'],
  dependencies: [iconv_dep],
)

intl_dep = dependency('intl', required: true)
intl_t = executable('intl_t',
  sources: ['intl_t.c'],
  dependencies: [intl_dep],
)
