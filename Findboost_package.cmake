##
#
# Download and initialize variable Boost_ROOT
#

IF(NOT CMAKE_BUILD_TYPE)
	MESSAGE(FATAL_ERROR "Boost package does not provide multi-conf support!")
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)
CMLIB_DEPENDENCY(
	URI "https://github.com/bringauto/cmake-package-tools.git"
	URI_TYPE GIT
	TYPE MODULE
)
FIND_PACKAGE(CMAKE_PACKAGE_TOOLS REQUIRED)

SET(platform_string)
CMAKE_PACKAGE_TOOLS_PLATFORM_STRING(platform_string)

SET(version v1.76.0)
SET(boost_url
	"https://github.com/bringauto/boost-package/releases/download/${version}/libboost-dev_${version}_${platform_string}.tar.gz"
)

CMLIB_DEPENDENCY(
	URI "${boost_url}"
	TYPE ARCHIVE
	OUTPUT_PATH_VAR _boost_ROOT
)

STRING(REPLACE "." "_" std_version ${version})
STRING(REPLACE "v" "" std_version ${std_version})
SET(Boost_ROOT "${_boost_ROOT}/boost_${std_version}"
	CACHE STRING
	"boost root directory"
	FORCE
)

SET(release_libs OFF)
SET(debug_libs OFF)
IF(CMAKE_BUILD_TYPE STREQUAL "Release")
	SET(release_libs ON)
ELSEIF(CMAKE_BUILD_TYPE STREQUAL "Debug")
	SET(debug_libs ON)
ELSE()
	MESSAGE(FATAL_ERROR "Boost - unsuported build type '${CMAKE_BUILD_TYPE}'")
ENDIF()

SET(Boost_USE_DEBUG_LIBS ${debug_libs}
	CACHE BOOL
	"Use Debug libs if on!"
	FORCE
)
SET(Boost_USE_RELEASE_LIBS ${release_libs}
	CACHE BOOL
	"Use Release libs if on!"
	FORCE
)
SET(Boost_USE_STATIC_LIBS ON
	CACHE BOOL
	"Use static libs only!"
	FORCE
)

SET(Boost_NO_SYSTEM_PATHS ON
	CACHE BOOL
	"Do not use system boost!"
	FORCE
)

UNSET(_boost_ROOT)
UNSET(boost_url)
UNSET(platform_string)
UNSET(std_version)
UNSET(version)
UNSET(release_libs)
UNSET(debug_libs)
