.PHONY: recastnavigation build run run_dev test compress pack_snap flame_graph headless_up headless_down headless_logs emsdk_up emsdk_down
SHELL := /bin/bash

ostype != uname

COMPRESS_SOURCE_DATA_DIRS ?= data
COMPRESS_FLAGS ?=
COMPRESS_CONFIGS ?= $(shell echo "             \
compressed=compression.json;                   \
compressed.extended=compression.extended.json" | sed "s/ //g")

BUILD_TARGET ?= build
SOURCE_C_DIR ?= .
export CMAKE_BUILD_TYPE ?= Release
BUILD_SUBDIR != $(MAKE) --silent          \
    ASAN=$(ASAN)                          \
    TSAN=$(TSAN)                          \
    UBSAN=$(UBSAN)                        \
    CLANG=$(CLANG)                        \
    LIBCPP=$(LIBCPP)                      \
    EMSDK64=$(EMSDK64)                    \
    EMSDK32=$(EMSDK32)                    \
    PROF=$(PROF)                          \
    CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)  \
    -C Mlib echo_build_dir
PLATFORM_CHAR != $(MAKE) --silent -C Mlib echo_platform_char
PACKAGE_DIR = $(BUILD_SUBDIR)
BIN_ARTIFACT_DIR ?= $(SOURCE_C_DIR)/Mlib/$(BUILD_SUBDIR)/Bin
ASSET_DIRS ?= data
RUN_ARGS ?=
ifeq ($(REMOTE_ROLE),server)
    RUN_ARGS := $(RUN_ARGS)           \
                --remote_site_id 42   \
                --remote_role server  \
                --udp_ip 127.0.0.1    \
                --udp_port 8042
else ifeq ($(REMOTE_ROLE),client)
    RUN_ARGS := $(RUN_ARGS)           \
                --remote_site_id 43   \
                --remote_role client  \
                --udp_ip 127.0.0.1    \
                --udp_port 8042
else ifeq ($(REMOTE_ROLE),client2)
    RUN_ARGS := $(RUN_ARGS)           \
                --remote_site_id 73   \
                --remote_role client  \
                --udp_ip 127.0.0.1    \
                --udp_port 8042
else ifeq ($(REMOTE_ROLE),podman)
    RUN_ARGS := $(RUN_ARGS)           \
                --remote_site_id 42   \
                --remote_role server  \
                --udp_ip 0.0.0.0      \
                --udp_port 8042
endif
ifeq ($(REMOTE_DEBUG),1)
    RUN_ARGS := $(RUN_ARGS)           \
                --print_remote_data   \
                --print_remote_metadata
endif
BIN_DIR !=                                     \
    if [ "$(PACKAGE)" != 0 ]; then             \
        echo "$(BIN_ARTIFACT_DIR)";            \
    else                                       \
        echo "$(BUILD_SUBDIR)";                \
    fi
GDB_ARGS !=                                         \
    if [ "$(GDB)" != 0 ]; then                      \
        echo "gdb -ex='catch throw' -ex=r --args";  \
    fi
SHOW_MOUSE_CURSOR_ARGS !=           \
    if [ "$(CURSOR)" != 0 ]; then   \
        echo --show_mouse_cursor;   \
    fi
PERF_ARGS !=                                       \
    if [ "$(PERF)" = 1 ]; then                     \
        echo sudo -E perf record -F 99 -a -g --;   \
    fi
PRINT_MATERIALS_ARGS !=                    \
    if [ "$(PMAT)" = 1 ]; then             \
        echo --print_rendered_materials;   \
    fi
CHK_ARGS !=                                         \
    if [ "$(CHK)" = 1 ]; then                       \
        echo --check_al_errors --check_gl_errors;   \
    fi
OMP_ENV !=                        \
    if [ "$(OMP)" = 0 ]; then     \
        echo OMP_NUM_THREADS=1;   \
    fi
SKIP_TESTS ?= 0
CACHE ?= 0

all: recastnavigation cmake build package test_package

recastnavigation:
	make -C Mlib recastnavigation \
		CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)

echo_build_dir:
	@echo "$(BUILD_SUBDIR)"

cmake:
	$(MAKE) build BUILD_TARGET=cmake

cmake_fresh:
	$(MAKE) build BUILD_TARGET=cmake_fresh

login:
	$(MAKE) build BUILD_TARGET=login

daemon:
	$(MAKE) build BUILD_TARGET=daemon

empackage:
	podman run --rm -it -v "$(PWD):/src:Z" -w /src emscripten/emsdk \
		python3 /emsdk/upstream/emscripten/tools/file_packager.py \
		static/client/assets.data \
		--preload data \
		--js-output=static/client/assets.js \
		--export-es6

build:
	$(MAKE) $(BUILD_TARGET) -C $(SOURCE_C_DIR)/Mlib

run:
	$(OMP_ENV)                                                     \
	TSAN_OPTIONS="second_deadlock_stack=1 suppressions=$(SOURCE_C_DIR)/suppressions.txt" \
	ENABLE_OSM_MAP_CACHE=$(CACHE)                                  \
	$(PERF_ARGS) $(GDB_ARGS) "$(BIN_DIR)/render_scene_file"        \
		"$(ASSET_DIRS)"                                            \
		data/levels/main/main.scn.json                             \
		--app_reldir .vanilla_rally                                \
		--print_render_residual_time                               \
		--nsamples_msaa 2                                          \
		$(SHOW_MOUSE_CURSOR_ARGS)                                  \
		$(PRINT_MATERIALS_ARGS)                                    \
		--windowed_width 1500                                      \
		--windowed_height 900                                      \
		$(CHK_ARGS) $(RUN_ARGS)

compress:
	$(PERF_ARGS) $(GDB_ARGS) "$(BIN_ARTIFACT_DIR)/compress_images" --source_dirs "$(COMPRESS_SOURCE_DATA_DIRS)" --configs "$(COMPRESS_CONFIGS)" $(COMPRESS_FLAGS)

headless_up:
	podman-compose -p mgame-serve -f docker-compose.serve.yaml up --build -d

headless_down:
	podman-compose -p mgame-serve -f docker-compose.serve.yaml down

headless_logs:
	podman-compose -f docker-compose.serve.yaml -p mgame-serve logs -f

emsdk_up:
	podman-compose -p mgame-emsdk -f docker-compose.dev.emsdk.yaml up -d

emsdk_down:
	podman-compose -p mgame-emsdk -f docker-compose.dev.emsdk.yaml down

package:
	@echo "OS Type: $(ostype)"
	@echo "Platform dir: $(BUILD_SUBDIR)"
	if [[ "$(PLATFORM_CHAR)" = M ]]; then \
		rsync -avh --checksum \
			Mlib/$(BUILD_SUBDIR)/Bin/download_heightmap.exe \
			Mlib/$(BUILD_SUBDIR)/Bin/render_scene_file.exe \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibArray.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibAudio.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibComponents.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibCompression.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibCppHttplib.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibGeography.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibGeometry.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibGlad.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibHalf.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibImages.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibIo.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibJson.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibLayout.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibMacroExecutor.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibMath.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibMemory.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibMiniMp3.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibMisc.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibNavigation.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibNvDds.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibOpenGL.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibOsmLoader.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibOs.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibPhysics.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibPlayers.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibPoly2Tri.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibProctree.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibRegex.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibRemote.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibSceneGraph.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibScene.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibStats.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibStbCpp.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibStb.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibStrings.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibThreads.dll \
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibTime.dll \
			Mlib/$(PLATFORM_CHAR)RecastBuild/DebugUtils/libDebugUtils.dll \
			Mlib/$(PLATFORM_CHAR)RecastBuild/Detour/libDetour.dll \
			Mlib/$(PLATFORM_CHAR)RecastBuild/Recast/libRecast.dll \
			/clang64/bin/glfw3.dll \
			/clang64/bin/libc++.dll \
			/clang64/bin/libicudt*.dll \
			/clang64/bin/libicuin*.dll \
			/clang64/bin/libicuuc*.dll \
			/clang64/bin/libomp.dll \
			/clang64/bin/libopenal-1.dll \
			/clang64/bin/libunwind.dll \
			/clang64/bin/libwinpthread-1.dll \
			/clang64/bin/vulkan-1.dll \
			$(PACKAGE_DIR)/; \
	else \
		rsync -avh --checksum \
			/usr/lib/x86_64-linux-gnu/libglfw.so* \
			/usr/lib/x86_64-linux-gnu/libopenal.so* \
			Mlib/$(BUILD_SUBDIR)/Bin/download_heightmap \
			Mlib/$(BUILD_SUBDIR)/Bin/render_scene_file \
			Mlib/$(BUILD_SUBDIR)/Lib/ \
			Mlib/$(PLATFORM_CHAR)RecastBuild/DebugUtils/libDebugUtils.so* \
			Mlib/$(PLATFORM_CHAR)RecastBuild/Detour/libDetour.so* \
			Mlib/$(PLATFORM_CHAR)RecastBuild/Recast/libRecast.so* \
			$(PACKAGE_DIR)/; \
	fi

test_package:
	@if [ "$(SKIP_TESTS)" = 1 ]; then \
		echo "Skipping tests (SKIP_TESTS=1)"; \
	else \
		LD_LIBRARY_PATH=$(PACKAGE_DIR) $(PACKAGE_DIR)/download_heightmap --help > /dev/null; \
		LD_LIBRARY_PATH=$(PACKAGE_DIR) $(PACKAGE_DIR)/render_scene_file --help > /dev/null; \
	fi

pack_snap:
	$(MAKE) build BUILD_TARGET="recastnavigation build" CMAKE_BUILD_TYPE=Release CLANG=1 GDB=0
	rsync --archive "$(SOURCE_C_DIR)/Mlib/LURelease/Bin/" Bin
	rsync --archive \
		--include='*.so' \
		--include='*.so.?' \
		--include='*.so.?.?.?' \
		--exclude='*' \
		"$(SOURCE_C_DIR)/Mlib/LURelease/Lib/" \
		"$(SOURCE_C_DIR)/Mlib/$(PLATFORM_CHAR)RecastBuild/DebugUtils/" \
		"$(SOURCE_C_DIR)/Mlib/$(PLATFORM_CHAR)RecastBuild/Detour/" \
		"$(SOURCE_C_DIR)/Mlib/$(PLATFORM_CHAR)RecastBuild/Recast/" \
		Lib
	$(MAKE) -f Makefile.user compress CMAKE_BUILD_TYPE=Release CLANG=1 GDB=0
	snapcraft pack

flame_graph:
	sudo perf script | stackcollapse-perf.pl > out.perf-folded
	flamegraph.pl out.perf-folded > perf.svg
