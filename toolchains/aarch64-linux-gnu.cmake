# CMake cross-compilation toolchain for AArch64 Linux (spec §11).
#
# Target: RK3326 / R36S (ARM Cortex-A35, ARMv8-A). We deliberately use the
# portable baseline -march=armv8-a first; Cortex-A35 tuning is an OPTIONAL
# second pass after a verified baseline build (spec §11, do not tune early).
#
# Usage:
#   cmake -S upstream/ags -B build/ags-aarch64 \
#         -DCMAKE_TOOLCHAIN_FILE="$PWD/toolchains/aarch64-linux-gnu.cmake" ...

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Cross compilers. Override with -DCROSS_TRIPLE=... if your toolchain differs.
if(NOT DEFINED CROSS_TRIPLE)
  set(CROSS_TRIPLE aarch64-linux-gnu)
endif()

set(CMAKE_C_COMPILER   ${CROSS_TRIPLE}-gcc)
set(CMAKE_CXX_COMPILER ${CROSS_TRIPLE}-g++)
set(CMAKE_AR           ${CROSS_TRIPLE}-ar)
set(CMAKE_RANLIB       ${CROSS_TRIPLE}-ranlib)
set(CMAKE_STRIP        ${CROSS_TRIPLE}-strip)

# Optional sysroot (set via -DCMAKE_SYSROOT=... or the CROSS_SYSROOT env var).
if(DEFINED ENV{CROSS_SYSROOT})
  set(CMAKE_SYSROOT $ENV{CROSS_SYSROOT})
endif()

# Portable baseline. RK3326 is ARMv8-A. Do NOT add -mcpu=cortex-a35 here until
# a plain armv8-a build is verified working on-device (spec §11).
set(_AGS_ARCH_FLAGS "-march=armv8-a")
set(CMAKE_C_FLAGS_INIT   "${_AGS_ARCH_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${_AGS_ARCH_FLAGS}")

# Search for libraries/headers in the target sysroot only; run host programs
# from the host. This keeps the cross build from picking up host x86 libs.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Help pkg-config find the target's .pc files when a sysroot is used.
if(CMAKE_SYSROOT)
  set(ENV{PKG_CONFIG_DIR} "")
  set(ENV{PKG_CONFIG_LIBDIR} "${CMAKE_SYSROOT}/usr/lib/${CROSS_TRIPLE}/pkgconfig:${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig")
  set(ENV{PKG_CONFIG_SYSROOT_DIR} "${CMAKE_SYSROOT}")
endif()
