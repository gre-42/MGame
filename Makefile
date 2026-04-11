.PHONY: recastnavigation build run run_dev test compress pack_snap flame_graph

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
    CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)  \
    -C Mlib echo_build_dir
PACKAGE_DIR = $(BUILD_SUBDIR)
BIN_ARTIFACT_DIR ?= $(SOURCE_C_DIR)/Mlib/$(BUILD_SUBDIR)/Bin
ASSET_DIRS ?= data
RUN_ARGS ?=
REMOTE_ARGS !=                                 \
    if [ "$(REMOTE_ROLE)" = server ]; then     \
        echo --remote_site_id 42               \
         --remote_role server                  \
         --remote_ip 127.0.0.1                 \
         --remote_port 8042;                   \
    elif [ "$(REMOTE_ROLE)" = client ]; then   \
        echo --remote_site_id 43               \
         --remote_role client                  \
         --remote_ip 127.0.0.1                 \
         --remote_port 8042;                   \
    fi
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
CHK_ARGS !=                                \
    if [ "$(CHK)" = 1 ]; then              \
        echo --check_gl_errors;            \
    fi
OMP_ENV !=                        \
    if [ "$(OMP)" = 0 ]; then     \
        echo OMP_NUM_THREADS=1;   \
    fi

CACHE ?= 0

all: recastnavigation cmake build package test

recastnavigation:
	make -C Mlib recastnavigation \
		CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)

echo_build_dir:
	@echo "$(BUILD_SUBDIR)"

cmake:
	$(MAKE) build BUILD_TARGET=cmake

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
		$(CHK_ARGS) $(REMOTE_ARGS) $(RUN_ARGS)

test: build compress run

compress:
	$(PERF_ARGS) $(GDB_ARGS) "$(BIN_ARTIFACT_DIR)/compress_images" --source_dirs "$(COMPRESS_SOURCE_DATA_DIRS)" --configs "$(COMPRESS_CONFIGS)" $(COMPRESS_FLAGS)

package:
	@echo "OS Type: $(ostype)"
	@echo "Platform dir: $(PLATFORM_DIR)"
	if [ "$$OSTYPE" = "msys" ] || [ "$$OSTYPE" = "cygwin" ]; then \
		rsync -avh --checksum \
			/mingw64/bin/glfw3.dll \
			Mlib/$(PLATFORM_DIR)/Bin/download_heightmap.exe \
			Mlib/$(PLATFORM_DIR)/Bin/render_scene_file.exe \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibArray.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibAudio.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibComponents.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibCppHttplib.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlib.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibGeography.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibGeometry.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibGlad.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibHalf.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibImages.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibIo.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibJson.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibLayout.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibMacroExecutor.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibMath.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibMemory.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibNavigation.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibNvDds.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibOs.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibOsmLoader.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibPhysics.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibPlayers.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibPoly2Tri.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibRegex.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibRemote.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibRender.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibScene.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibSceneGraph.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibStats.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibStbCpp.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibStb.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibStrings.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibThreads.dll \
			Mlib/$(PLATFORM_DIR)/Bin/libMlibTime.dll \
			Mlib/RecastBuild/DebugUtils/libDebugUtils.dll \
			Mlib/RecastBuild/Detour/libDetour.dll \
			Mlib/RecastBuild/Recast/libRecast.dll \
			/mingw64/bin/libgcc_s_seh-1.dll \
			/mingw64/bin/libgomp-1.dll \
			/mingw64/bin/libstdc++-6.dll \
			/mingw64/bin/vulkan-1.dll \
			/mingw64/bin/libwinpthread-1.dll \
			/mingw64/bin/libopenal-1.dll \
			/mingw64/bin/libalut-0.dll \
			$(PACKAGE_DIR)/; \
	else \
		rsync -avh --checksum \
			/usr/lib/x86_64-linux-gnu/libalut.so* \
			/usr/lib/x86_64-linux-gnu/libglfw.so* \
			/usr/lib/x86_64-linux-gnu/libopenal.so* \
			Mlib/$(PLATFORM_DIR)/Bin/download_heightmap \
			Mlib/$(PLATFORM_DIR)/Bin/render_scene_file \
			Mlib/$(PLATFORM_DIR)/Lib/ \
			Mlib/RecastBuild/DebugUtils/libDebugUtils.so* \
			Mlib/RecastBuild/Detour/libDetour.so* \
			Mlib/RecastBuild/Recast/libRecast.so* \
			$(PACKAGE_DIR)/; \
	fi

test:
	LD_LIBRARY_PATH=$(PACKAGE_DIR) $(PACKAGE_DIR)/download_heightmap --help > /dev/null
	LD_LIBRARY_PATH=$(PACKAGE_DIR) $(PACKAGE_DIR)/render_scene_file --help > /dev/null

pack_snap:
	$(MAKE) build BUILD_TARGET="recastnavigation build" CMAKE_BUILD_TYPE=Release CLANG=1 GDB=0
	rsync --archive "$(SOURCE_C_DIR)/Mlib/LURelease/Bin/" Bin
	rsync --archive \
		--include='*.so' \
		--include='*.so.?' \
		--include='*.so.?.?.?' \
		--exclude='*' \
		"$(SOURCE_C_DIR)/Mlib/LURelease/Lib/" \
		"$(SOURCE_C_DIR)/Mlib/RecastBuild/DebugUtils/" \
		"$(SOURCE_C_DIR)/Mlib/RecastBuild/Detour/" \
		"$(SOURCE_C_DIR)/Mlib/RecastBuild/Recast/" \
		Lib
	$(MAKE) -f Makefile.user compress CMAKE_BUILD_TYPE=Release CLANG=1 GDB=0
	snapcraft pack

flame_graph:
	sudo perf script | stackcollapse-perf.pl > out.perf-folded
	flamegraph.pl out.perf-folded > perf.svg
