.PHONY: recastnavigation build run run_dev test compress pack_snap flame_graph headless_up headless_down headless_logs emsdk_up emsdk_down
SHELL := /bin/bash

ostype != uname

COMPRESS_SOURCE_DATA_DIRS ?= data;compression/data_extra
COMPRESS_FLAGS ?=
COMPRESS_CONFIGS ?= $(shell echo "                                                    \
compression/dest/compressed=compression/src/compression.json;                         \
compression/dest/compressed=compression/src/transition/compression.arena.json;        \
compression/dest/compressed=compression/src/transition/compression.arena_humans.json; \
compression/dest/compressed=compression/src/transition/compression.nyc.json;          \
compression/dest/compressed=compression/src/transition/compression.nyc_td0.json;      \
compression/dest/compressed=compression/src/transition/compression.race_track0.json;  \
compression/dest/compressed.extended=compression/src/compression.extended.json" | sed "s/ //g")

BUILD_TARGET ?= build
SOURCE_C_DIR ?= .
export CMAKE_BUILD_TYPE ?= Release
BUILD_SUBDIR != $(MAKE) --silent -C Mlib echo_build_dir
PLATFORM_CHAR != $(MAKE) --silent -C Mlib echo_platform_char
PACKAGE_DIR = $(BUILD_SUBDIR)
BIN_ARTIFACT_DIR ?= $(SOURCE_C_DIR)/Mlib/$(BUILD_SUBDIR)/Bin
ASSET_DIRS ?= data
RUN_ARGS ?=
FILE_EXT_ARGS ?=
ifeq ($(COMPRESSED),1)
	override ASSET_DIRS := compression/data;compression/dest/compressed;compression/dest/compressed.extended;compression/dest/compressed.private
	override FILE_EXT_ARGS := --mesh obj.gz --animated_mesh mhx2.gz --audio mp3 --compressed
	APP_RELDIR := .vanilla_rally_compressed
else
	APP_RELDIR := .vanilla_rally
endif
ifeq ($(HEADLESS),1)
	override RUN_ARGS :=          \
		$(RUN_ARGS)               \
		--remote_site_id 42       \
		--udp_ip 127.0.0.1        \
		--udp_port 8042           \
		--http_ip 127.0.0.1       \
		--http_port 8082
endif
ifeq ($(REMOTE_ROLE),server)
	override RUN_ARGS :=          \
		$(RUN_ARGS)               \
		--remote_site_id 42       \
		--remote_role server      \
		--udp_ip 127.0.0.1        \
		--udp_port 8042
else ifeq ($(REMOTE_ROLE),client)
	override RUN_ARGS :=          \
		$(RUN_ARGS)               \
		--remote_site_id 43       \
		--remote_role client      \
		--udp_ip 127.0.0.1        \
		--udp_port 8042
else ifeq ($(REMOTE_ROLE),client2)
	override RUN_ARGS :=          \
		$(RUN_ARGS)               \
		--remote_site_id 73       \
		--remote_role client      \
		--udp_ip 127.0.0.1        \
		--udp_port 8042
else ifeq ($(REMOTE_ROLE),podman)
	override RUN_ARGS :=          \
		$(RUN_ARGS)               \
		--remote_site_id 42       \
		--remote_role server      \
		--udp_ip 0.0.0.0          \
		--udp_port 8042
endif
ifeq ($(REMOTE_DEBUG),1)
	override RUN_ARGS :=      \
		$(RUN_ARGS)           \
		--print_remote_metadata
endif
ifeq ($(REMOTE_DEBUG),2)
	override RUN_ARGS :=      \
		$(RUN_ARGS)           \
		--print_remote_data   \
		--print_remote_metadata
endif
ifeq ($(PACKAGE),0)
	BIN_DIR := $(BUILD_SUBDIR)
else
	BIN_DIR := $(BIN_ARTIFACT_DIR)
endif
GDB_ARGS :=
ifneq ($(GDB),0)
	GDB_ARGS := gdb -ex='catch throw' -ex=r --args
endif
SHOW_MOUSE_CURSOR_ARGS :=
ifneq ($(CURSOR),0)
	SHOW_MOUSE_CURSOR_ARGS := --show_mouse_cursor
endif
PERF_ARGS :=
ifeq ($(PERF),1)
	PERF_ARGS := sudo -E perf record -F 99 -a -g --
endif
PRINT_MATERIALS_ARGS :=
ifeq ($(PMAT),1)
	PRINT_MATERIALS_ARGS := --print_rendered_materials
endif
CHK_ARGS :=
ifeq ($(CHK),1)
	CHK_ARGS := --check_al_errors --check_gl_errors
endif
OMP_ENV :=
ifeq ($(OMP),0)
	OMP_ENV := OMP_NUM_THREADS=1
endif
SERVE := prod
ifeq ($(DEV),1)
	SERVE := dev
endif
BUILD_FLAG := --build
ifeq ($(BUILD),0)
	BUILD_FLAG :=
endif
PROFILE_FLAG := --profile all
ifeq ($(DYNAMIC),0)
	PROFILE_FLAG := --profile static
endif
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
		python3 /emsdk/upstream/emscripten/tools/file_packager.py   \
		public/client/assets.data \
		--preload \
			data \
			appdata \
		--js-output=public/client/assets.js \
		--export-es6 \
		--use-preload-cache

empackage_compressed:
	podman run --rm -it -v "$(PWD):/src:Z" -w /src emscripten/emsdk \
		python3 /emsdk/upstream/emscripten/tools/file_packager.py   \
		public/client/assets_compressed.data \
		--preload \
			compression/data \
			compression/dest/compressed \
			compression/dest/compressed.extended \
			appdata \
		--js-output=public/client/assets_compressed.js \
		--export-es6 \
		--use-preload-cache

build:
	$(MAKE) $(BUILD_TARGET) -C $(SOURCE_C_DIR)/Mlib

run:
	$(OMP_ENV)                                                     \
	TSAN_OPTIONS="second_deadlock_stack=1 suppressions=$(SOURCE_C_DIR)/suppressions.txt" \
	ENABLE_OSM_MAP_CACHE=$(CACHE)                                  \
	$(PERF_ARGS) $(GDB_ARGS) "$(BIN_DIR)/render_scene_file"        \
	    "$(ASSET_DIRS)"                                            \
	    data/levels/main/main.scn.json                             \
	    --app_reldir $(APP_RELDIR)                                 \
	    --print_render_residual_time                               \
	    $(SHOW_MOUSE_CURSOR_ARGS)                                  \
	    $(PRINT_MATERIALS_ARGS)                                    \
	    --windowed_width 1500                                      \
	    --windowed_height 900                                      \
	    $(CHK_ARGS) $(FILE_EXT_ARGS) $(RUN_ARGS)

compress:
	$(PERF_ARGS) $(GDB_ARGS) "$(BIN_ARTIFACT_DIR)/compress_images" \
		--source_dirs "$(COMPRESS_SOURCE_DATA_DIRS)" \
		--configs "$(COMPRESS_CONFIGS)" $(COMPRESS_FLAGS)

headless_up:
	podman-compose -p mgame-serve -f docker-compose.serve.$(SERVE).yaml $(PROFILE_FLAG) up $(BUILD_FLAG) -d

headless_down:
	podman-compose -p mgame-serve -f docker-compose.serve.$(SERVE).yaml $(PROFILE_FLAG) down

headless_logs:
	podman-compose -f docker-compose.serve.$(SERVE).yaml -p mgame-serve logs -f

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
			Mlib/$(BUILD_SUBDIR)/Bin/libMlibResourceContext.dll \
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
	@if [[ "$(SKIP_TESTS)" = 1 ]]; then \
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
