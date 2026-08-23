# Native-in-emulation AArch64 build of the AGS engine (spec §11, strategy 2).
#
# Built with:  docker buildx build --platform linux/arm64 ...
# so the whole compile runs as genuine arm64 (via QEMU/binfmt). This avoids
# cross-toolchain/sysroot friction and guarantees an arm64 output binary.
#
# The final stage contains ONLY the staged engine + bundled libs under /out,
# so `--output type=local` extracts a clean artifact with no build junk.

# ---------------------------------------------------------------------------
# bullseye = glibc 2.31, matching the ArkOS R36S target (device has glibc 2.31).
# A binary built here runs on glibc >= 2.31 (i.e. this device and newer).
FROM debian:bullseye-slim AS builder

ARG AGS_REPO=https://github.com/adventuregamestudio/ags.git
ARG AGS_GIT_COMMIT=810192970bfa8859041bca6f50ff6d9eba190036

RUN apt-get update && apt-get install -y --no-install-recommends \
      git ca-certificates cmake ninja-build build-essential pkg-config \
      libsdl2-dev libogg-dev libvorbis-dev libtheora-dev \
      libfreetype-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --no-checkout "$AGS_REPO" ags \
    && cd ags \
    && git fetch --tags origin \
    && git checkout --detach "$AGS_GIT_COMMIT" \
    && git submodule update --init --recursive

# Video stays ENABLED (spec §7). Engine only (spec §12).
# - SDL_WAYLAND=OFF: AGS builds its own SDL2; bullseye's wayland (1.18) is too old
#   and the R36S/ArkOS uses KMSDRM/X11, not wayland.
# - static libstdc++/libgcc: makes the device's GLIBCXX version irrelevant, so
#   only glibc (2.31) matters for compatibility.
RUN cmake -G Ninja -S /src/ags -B /build \
      -DCMAKE_BUILD_TYPE=Release \
      -DAGS_BUILD_ENGINE=ON \
      -DAGS_BUILD_TOOLS=OFF \
      -DAGS_BUILD_COMPILER=OFF \
      -DAGS_TESTS=OFF \
      -DSDL_WAYLAND=OFF -DSDL_WAYLAND_SHARED=OFF \
      -DCMAKE_C_FLAGS="-march=armv8-a" -DCMAKE_CXX_FLAGS="-march=armv8-a" \
      -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc" \
    && cmake --build /build -j"$(nproc)"

# Collect the binary + its non-system shared-lib dependencies into /out.
RUN set -eux; \
    BIN="$(find /build -type f -name ags -perm -u+x | head -n1)"; \
    test -n "$BIN"; \
    mkdir -p /out/bin /out/lib; \
    cp "$BIN" /out/bin/ags; \
    aarch64-linux-gnu-strip /out/bin/ags || true; \
    # bundle SDL2 + codec libs, skip the core system/loader libs that ArkOS has
    ldd /out/bin/ags | awk '/=>/{print $3}' | while read -r so; do \
        case "$so" in \
          */libc.so*|*/libm.so*|*/libdl.so*|*/libpthread.so*|*/librt.so*|\
          */ld-linux*|*/libstdc++.so*|*/libgcc_s.so*|*/libresolv.so*) : ;; \
          *) cp -v "$so" /out/lib/ ;; \
        esac; \
    done; \
    file /out/bin/ags; \
    /out/bin/ags --version || true

# ---------------------------------------------------------------------------
# Export-only stage: `docker buildx ... --output type=local,dest=...` will
# write exactly this filesystem out to the host.
FROM scratch AS export
COPY --from=builder /out/ /
