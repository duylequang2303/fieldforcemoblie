cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

# Use system glib instead of snap's glib to avoid libsecret version mismatch
# System glib (=2.80) has symbols required by system libsecret-1
pkg_get_variable(GLIB_PREFIX glib-2.0 prefix)
if(GLIB_PREFIX MATCHES "/snap/")
  # Force system glib via find_library with explicit path
  find_library(SYSTEM_GLIB NAMES glib-2.so.0 glib-2.0 PATHS /usr/lib/x86_64-linux-gnu NO_CMAKE_FIND_ROOT_PATH)
  find_library(SYSTEM_GOBJECT NAMES gobject-2.0.so.0 gobject-2.0 PATHS /usr/lib/x86_64-linux-gnu NO_CMAKE_FIND_ROOT_PATH)
  find_library(SYSTEM_GIO NAMES gio-2.0.so.0 gio-2.0 PATHS /usr/lib/x86_64-linux-gnu NO_CMAKE_FIND_ROOT_PATH)
  find_library(SYSTEM_GIO_MODULE NAMES gmodule-2.0.so.0 gmodule-2.0 PATHS /usr/lib/x86_64-linux-gnu NO_CMAKE_FIND_ROOT_PATH)
  if(SYSTEM_GLIB)
    target_link_libraries(${BINARY_NAME} PRIVATE ${SYSTEM_GLIB} ${SYSTEM_GOBJECT} ${SYSTEM_GIO} ${SYSTEM_GIO_MODULE})
    message(STATUS "Using SYSTEM glib: ${SYSTEM_GLIB}")
  else()
    target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GLIB)
  endif()
else()
  target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GLIB)
endif()

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
