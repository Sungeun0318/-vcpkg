[CmdletBinding()]
param (
    $libraries = @(),
    $version = "1.75.0",
    $portsDir = $null
)

$ErrorActionPreference = 'Stop'

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
if ($null -eq $portsDir)
{
    $portsDir = "$scriptsDir/../../ports"
}

if ($IsWindows)
{
    $vcpkg = "$scriptsDir/../../vcpkg.exe"
}
else
{
    $vcpkg = "$scriptsDir/../../vcpkg"
}

# Optionally clear this array when moving to a new boost version
$port_versions = @{
    #e.g.  "asio" = 1;
}

$per_port_data = @{
    "asio" =  @{ "supports" = "!emscripten" };
    "beast" =  @{ "supports" = "!emscripten" };
    "fiber" = @{ "supports" = "!osx&!uwp&!arm&!emscripten" };
    "filesystem" = @{ "supports" = "!uwp" };
    "iostreams" = @{ "supports" = "!uwp" };
    "context" = @{ "supports" = "!uwp&!emscripten" };
    "stacktrace" = @{ "supports" = "!uwp" };
    "coroutine" = @{ "supports" = "!arm&!uwp&!emscripten" };
    "coroutine2" = @{ "supports" = "!emscripten" };
    "test" = @{ "supports" = "!uwp" };
    "wave" = @{ "supports" = "!uwp" };
    "log" = @{ "supports" = "!uwp&!emscripten" };
    "locale" = @{
        "supports" = "!uwp";
        "features" = @(
            "Feature: icu"
            "Build-Depends: icu"
            "Description: ICU backend for Boost.Locale"
        )};
    "parameter-python" =  @{ "supports" = "!emscripten" };
    "process" =  @{ "supports" = "!emscripten" };
    "python" = @{
        "supports" = "!uwp&!(arm&windows)&!emscripten";
        "features" = @(
            "Feature: python2"
            "Build-Depends: python2 (windows)"
            "Description: Build with Python2 support"
        )};
    "regex" = @{ "features" = @(
            "Feature: icu"
            "Build-Depends: icu"
            "Description: ICU backend for Boost.Regex"
        )}
}

function TransformReference()
{
    param (
        [string]$library
    )

    if ($per_port_data[$library].supports)
    {
        "$library ($($per_port_data[$library].supports))"
    }
    else
    {
        "$library"
    }
}

function Generate()
{
    param (
        [string]$Name,
        [string]$PortName,
        [string]$Hash,
        [bool]$NeedsBuild,
        $Depends = @()
    )

    $controlDeps = ($Depends | sort) -join ", "

    mkdir "$portsDir/boost-$PortName" -erroraction SilentlyContinue | out-null
    $controlLines = @(
        "# Automatically generated by scripts/boost/generate-ports.ps1"
        "Source: boost-$PortName"
        "Version: $version"
    )
    if ($port_versions[$PortName])
    {
        $controlLines += @("Port-Version: $($port_versions[$PortName])")
    }
    $controlLines += @(
        "Build-Depends: $controlDeps"
        "Homepage: https://github.com/boostorg/$Name"
        "Description: Boost $Name module"
    )
    if ($per_port_data[$PortName].supports)
    {
        $controlLines += @("Supports: $($per_port_data[$PortName].supports)")
    }
    if ($per_port_data[$PortName].features)
    {
        $controlLines += @("") + $per_port_data[$PortName].features
    }
    $controlLines | out-file -enc ascii "$portsDir/boost-$PortName/CONTROL"

    $portfileLines = @(
        "# Automatically generated by scripts/boost/generate-ports.ps1"
        ""
    )

    if ($PortName -eq "system")
    {
        $portfileLines += @(
            "vcpkg_buildpath_length_warning(37)"
            ""
        )
    }

    $portfileLines += @(
        "vcpkg_from_github("
        "    OUT_SOURCE_PATH SOURCE_PATH"
        "    REPO boostorg/$Name"
        "    REF boost-$version"
        "    SHA512 $Hash"
        "    HEAD_REF master"
    )
    $patches = ls $portsDir/boost-$PortName/*.patch
    if ($patches.Count -eq 0)
    {
    }
    elseif ($patches.Count -eq 1)
    {
        $portfileLines += @("    PATCHES $($patches.name)")
    }
    else
    {
        $portfileLines += @("    PATCHES")
        foreach ($patch in $patches)
        {
            $portfileLines += @("        $($patch.name)")
        }
    }
    $portfileLines += @(
        ")"
        ""
    )

    if (Test-Path "$scriptsDir/post-source-stubs/$PortName.cmake")
    {
        $portfileLines += @(get-content "$scriptsDir/post-source-stubs/$PortName.cmake")
    }

    if ($NeedsBuild)
    {
        $portfileLines += @(
            "include(`${CURRENT_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)"
        )
        # b2-options.cmake contains port-specific build options
        if (Test-Path "$portsDir/boost-$PortName/b2-options.cmake")
        {
            $portfileLines += @(
                "boost_modular_build("
                "    SOURCE_PATH `${SOURCE_PATH}"
                "    BOOST_CMAKE_FRAGMENT `"`${CMAKE_CURRENT_LIST_DIR}/b2-options.cmake`""
                ")"
            )
        }
        elseif (Test-Path "$portsDir/boost-$PortName/b2-options.cmake.in")
        {
            $portfileLines += @(
                'configure_file('
                '    "${CMAKE_CURRENT_LIST_DIR}/b2-options.cmake.in"'
                '    "${CURRENT_BUILDTREES_DIR}/vcpkg-b2-options.cmake"'
                '    @ONLY'
                ')'
                'boost_modular_build('
                '    SOURCE_PATH ${SOURCE_PATH}'
                '    BOOST_CMAKE_FRAGMENT "${CURRENT_BUILDTREES_DIR}/vcpkg-b2-options.cmake"'
                ')'
            )
        }
        else
        {
            $portfileLines += @(
                "boost_modular_build(SOURCE_PATH `${SOURCE_PATH})"
            )
        }
    }

    $portfileLines += @(
        "include(`${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)"
        "boost_modular_headers(SOURCE_PATH `${SOURCE_PATH})"
    )

    if (Test-Path "$scriptsDir/post-build-stubs/$PortName.cmake")
    {
        $portfileLines += @(get-content "$scriptsDir/post-build-stubs/$PortName.cmake")
    }

    $portfileLines | out-file -enc ascii "$portsDir/boost-$PortName/portfile.cmake"
}

if (!(Test-Path "$scriptsDir/boost"))
{
    "Cloning boost..."
    pushd $scriptsDir
    try
    {
        git clone https://github.com/boostorg/boost --branch boost-$version
    }
    finally
    {
        popd
    }
}
else
{
    pushd $scriptsDir/boost
    try
    {
        git fetch
        git checkout -f boost-$version
    }
    finally
    {
        popd
    }
}

$libraries_found = ls $scriptsDir/boost/libs -directory | % name | % {
    if ($_ -match "numeric")
    {
        "numeric_conversion"
        "interval"
        "odeint"
        "ublas"
        "safe_numerics"
    }
    elseif ($_ -eq "headers")
    {
    }
    else
    {
        $_
    }
}

mkdir $scriptsDir/downloads -erroraction SilentlyContinue | out-null

if ($libraries.Length -eq 0)
{
    $libraries = $libraries_found
}

$libraries_in_boost_port = @()

foreach ($library in $libraries)
{
    "Handling boost/$library..."
    $archive = "$scriptsDir/downloads/$library-boost-$version.tar.gz"
    if (!(Test-Path $archive))
    {
        "Downloading boost/$library..."
        & @(& $vcpkg fetch aria2)[-1] "https://github.com/boostorg/$library/archive/boost-$version.tar.gz" -d "$scriptsDir/downloads" -o "$library-boost-$version.tar.gz"
    }
    $hash = & $vcpkg hash $archive
    $unpacked = "$scriptsDir/libs/$library-boost-$version"
    if (!(Test-Path $unpacked))
    {
        "Unpacking boost/$library..."
        mkdir $scriptsDir/libs -erroraction SilentlyContinue | out-null
        pushd $scriptsDir/libs
        try
        {
            cmake -E tar xf $archive
        }
        finally
        {
            popd
        }
    }
    pushd $unpacked
    try
    {
        $groups = $(
            findstr /si /C:"include <boost/" include/*
            findstr /si /C:"include <boost/" src/*
        ) |
        % { $_ `
                -replace "^[^:]*:","" `
                -replace "boost/numeric/conversion/","boost/numeric_conversion/" `
                -replace "boost/functional/hash.hpp","boost/container_hash/hash.hpp" `
                -replace "boost/detail/([^/]+)/","boost/`$1/" `
                -replace " *# *include *<boost/([a-zA-Z0-9\._]*)(/|>).*", "`$1" `
                -replace "/|\.hp?p?| ","" } | group | % name | % {
            # mappings
            Write-Verbose "${library}: $_"
            if ($_ -match "aligned_storage") { "type_traits" }
            elseif ($_ -match "noncopyable|ref|swap|get_pointer|checked_delete|visit_each") { "core" }
            elseif ($_ -eq "type") { "core" }
            elseif ($_ -match "concept|concept_archetype") { "concept_check" }
            elseif ($_ -match "unordered_") { "unordered" }
            elseif ($_ -match "cstdint|integer_fwd|integer_traits") { "integer" }
            elseif ($_ -match "call_traits|operators|current_function|cstdlib|next_prior|compressed_pair") { "utility" }
            elseif ($_ -match "^version|^workaround") { "config" }
            elseif ($_ -match "enable_shared_from_this|shared_ptr|make_shared|make_unique|intrusive_ptr|scoped_ptr|pointer_cast|pointer_to_other|weak_ptr|shared_array|scoped_array") { "smart_ptr" }
            elseif ($_ -match "iterator_adaptors|generator_iterator|pointee") { "iterator" }
            elseif ($_ -eq "regex_fwd") { "regex" }
            elseif ($_ -eq "make_default") { "convert" }
            elseif ($_ -eq "foreach_fwd") { "foreach" }
            elseif ($_ -eq "cerrno") { "system" }
            elseif ($_ -eq "circular_buffer_fwd") { "circular_buffer" }
            elseif ($_ -eq "archive") { "serialization" }
            elseif ($_ -match "none|none_t") { "optional" }
            elseif ($_ -eq "limits") { "compatibility" }
            elseif ($_ -match "cstdfloat|math_fwd") { "math" }
            elseif ($_ -eq "cast") { "conversion"; "numeric_conversion" } # DEPRECATED header file, includes <boost/polymorphic_cast.hpp> and <boost/numeric/conversion/cast.hpp> 
            elseif ($_ -match "polymorphic_cast|implicit_cast") { "conversion" }
            elseif ($_ -eq "nondet_random") { "random" }
            elseif ($_ -eq "memory_order") { "atomic" }
            elseif ($_ -match "blank|blank_fwd|numeric_traits|fenv") { "detail" }
            elseif ($_ -match "is_placeholder|mem_fn") { "bind" }
            elseif ($_ -eq "exception_ptr") { "exception" }
            elseif ($_ -match "multi_index_container|multi_index_container_fwd") { "multi_index" }
            elseif ($_ -eq "lexical_cast") { "lexical_cast"; "math" }
            elseif ($_ -match "token_iterator|token_functions") { "tokenizer" }
            elseif ($_ -eq "numeric" -and $library -notmatch "numeric_conversion|interval|odeint|ublas") { "numeric_conversion"; "interval"; "odeint"; "ublas" }
            elseif ($_ -eq "io_fwd") { "io" }
            else { $_ }
        } | group | % name | ? { $_ -ne $library }

        #"`nFor ${library}:"
        "      [known] " + $($groups | ? { $libraries_found -contains $_ })
        "    [unknown] " + $($groups | ? { $libraries_found -notcontains $_ })

        $deps = @($groups | ? { $libraries_found -contains $_ })

        $deps = @($deps | ? {
            # Boost contains cycles, so remove a few dependencies to break the loop.
            (($library -notmatch "core|assert|mpl|detail|throw_exception|type_traits|^exception") -or ($_ -notmatch "utility")) `
            -and `
            (($library -notmatch "assert") -or ($_ -notmatch "integer"))`
            -and `
            (($library -notmatch "range") -or ($_ -notmatch "algorithm"))`
            -and `
            (($library -ne "config") -or ($_ -notmatch "integer"))`
            -and `
            (($library -notmatch "multiprecision") -or ($_ -notmatch "random|math"))`
            -and `
            (($library -notmatch "lexical_cast") -or ($_ -notmatch "math"))`
            -and `
            (($library -notmatch "functional") -or ($_ -notmatch "function"))`
            -and `
            (($library -notmatch "detail") -or ($_ -notmatch "static_assert|integer|mpl|type_traits"))`
            -and `
            ($_ -notmatch "mpi")`
            -and `
            (($library -notmatch "spirit") -or ($_ -notmatch "serialization"))`
            -and `
            (($library -notmatch "throw_exception") -or ($_ -notmatch "^exception"))`
            -and `
            (($library -notmatch "iostreams|math") -or ($_ -notmatch "random"))`
            -and `
            (($library -notmatch "utility|concept_check") -or ($_ -notmatch "iterator"))
        } | % { $_ -replace "_","-" } | % {
            "boost-" + (TransformReference $_)
        })

        $deps += @("boost-vcpkg-helpers")

        $needsBuild = $false
        if ((Test-Path $unpacked/build/Jamfile.v2) -and $library -ne "metaparse" -and $library -ne "graph_parallel")
        {
            $deps += @("boost-build", "boost-modular-build-helper")
            $needsBuild = $true
        }

        if ($library -eq "python")
        {
            $deps += @("python3")
            $needsBuild = $true
        }
        elseif ($library -eq "iostreams")
        {
            $deps += @("zlib", "bzip2", "liblzma", "zstd")
        }
        elseif ($library -eq "locale")
        {
            $deps += @("libiconv (!uwp&!windows)", "boost-system")
        }
        elseif ($library -eq "asio")
        {
            $deps += @("openssl")
        }
        elseif ($library -eq "mpi")
        {
            $deps += @("mpi")
        }

        $portName = $library -replace "_","-"

        Generate `
            -Name $library `
            -PortName $portName `
            -Hash $hash `
            -Depends $deps `
            -NeedsBuild $needsBuild

        $libraries_in_boost_port += @(TransformReference $portName)
    }
    finally
    {
        popd
    }
}

if ($libraries_in_boost_port.length -gt 1) {
    # Generate master boost control file which depends on each individual library
    # mpi is excluded due to it having a dependency on msmpi/openmpi
    $boostDependsList = @($libraries_in_boost_port | % { "boost-$_" } | ? { $_ -notmatch "boost-mpi" }) -join ", "

    @(
        "# Automatically generated by scripts/boost/generate-ports.ps1"
        "Source: boost"
        "Version: $version"
        "Port-Version: $($port_versions.boost)"
        "Homepage: https://boost.org"
        "Description: Peer-reviewed portable C++ source libraries"
        "Build-Depends: $boostDependsList"
        ""
        "Feature: mpi"
        "Description: Build with MPI support"
        "Build-Depends: boost-mpi"
    ) | out-file -enc ascii $portsDir/boost/CONTROL

    "set(VCPKG_POLICY_EMPTY_PACKAGE enabled)`n" | out-file -enc ascii $portsDir/boost/portfile.cmake
}

return
