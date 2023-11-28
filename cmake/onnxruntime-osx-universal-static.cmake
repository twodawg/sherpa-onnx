# Possible values for CMAKE_SYSTEM_NAME: Linux, Windows, Darwin

message(STATUS "CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "CMAKE_OSX_ARCHITECTURES: ${CMAKE_OSX_ARCHITECTURES}")
message(STATUS "CMAKE_APPLE_SILICON_PROCESSOR : ${CMAKE_APPLE_SILICON_PROCESSOR}")

if(NOT CMAKE_SYSTEM_NAME STREQUAL Darwin)
  message(FATAL_ERROR "This file is for macOS only. Given: ${CMAKE_SYSTEM_NAME}")
endif()

if(BUILD_SHARED_LIBS)
  message(FATAL_ERROR "This file is for building static libraries. BUILD_SHARED_LIBS: ${BUILD_SHARED_LIBS}")
endif()

set(onnxruntime_URL  "https://github.com/csukuangfj/onnxruntime-libs/releases/download/v1.16.3/onnxruntime-osx-universal2-static_lib-1.16.3.zip")
set(onnxruntime_URL2 "https://huggingface.co/csukuangfj/onnxruntime-libs/resolve/main/onnxruntime-osx-universal2-static_lib-1.16.3.zip")
set(onnxruntime_HASH "SHA256=19e39beefbb6d103c1d4c5a2d64bfbd6dd4c21f37d6545170ce3c59a5e2af452")

# If you don't have access to the Internet,
# please download onnxruntime to one of the following locations.
# You can add more if you want.
set(possible_file_locations
  $ENV{HOME}/Downloads/onnxruntime-osx-universal2-static_lib-1.16.3.zip
  ${PROJECT_SOURCE_DIR}/onnxruntime-osx-universal2-static_lib-1.16.3.zip
  ${PROJECT_BINARY_DIR}/onnxruntime-osx-universal2-static_lib-1.16.3.zip
  /tmp/onnxruntime-osx-universal2-static_lib-1.16.3.zip
)

foreach(f IN LISTS possible_file_locations)
  if(EXISTS ${f})
    set(onnxruntime_URL  "${f}")
    file(TO_CMAKE_PATH "${onnxruntime_URL}" onnxruntime_URL)
    message(STATUS "Found local downloaded onnxruntime: ${onnxruntime_URL}")
    set(onnxruntime_URL2)
    break()
  endif()
endforeach()

FetchContent_Declare(onnxruntime
  URL
    ${onnxruntime_URL}
    ${onnxruntime_URL2}
  URL_HASH          ${onnxruntime_HASH}
)

FetchContent_GetProperties(onnxruntime)
if(NOT onnxruntime_POPULATED)
  message(STATUS "Downloading onnxruntime from ${onnxruntime_URL}")
  FetchContent_Populate(onnxruntime)
endif()
message(STATUS "onnxruntime is downloaded to ${onnxruntime_SOURCE_DIR}")

# for static libraries, we use onnxruntime_lib_files directly below
include_directories(${onnxruntime_SOURCE_DIR}/include)

file(GLOB onnxruntime_lib_files "${onnxruntime_SOURCE_DIR}/lib/lib*.a")

set(onnxruntime_lib_files ${onnxruntime_lib_files} PARENT_SCOPE)

message(STATUS "onnxruntime lib files: ${onnxruntime_lib_files}")
install(FILES ${onnxruntime_lib_files} DESTINATION lib)