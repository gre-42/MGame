.PHONY: recastnavigation build package test run run_dev

CMAKE_BUILD_TYPE ?= Release
BUILD_PREFIX ?= G
PLATFORM_DIR != if [ "$$OSTYPE" = "msys" ] || [ "$$OSTYPE" = "cygwin" ]; then \
        echo $(BUILD_PREFIX)M$(CMAKE_BUILD_TYPE); \
    else \
        echo $(BUILD_PREFIX)U$(CMAKE_BUILD_TYPE); \
    fi
ostype != echo "$$OSTYPE";
BIN_DIR = $(PLATFORM_DIR)

all: recastnavigation build package test

recastnavigation:
	make -C Mlib recastnavigation \
		CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)

build_any:
	BUILD_PREFIX=$(BUILD_PREFIX) \
	CMAKE_OPTIONS="-DBUILD_TRIANGLE=OFF" \
		make -C Mlib $(TARGET) \
			CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)

build:
	make build_any TARGET=build

build_clang:
	make build_any TARGET=build_clang

build_clang_libcpp:
	make build_any TARGET=build_clang_libcpp

build_asan:
	make build_any TARGET=build_asan

build_tsan:
	make build_any TARGET=build_tsan

build_ubsan:
	make build_any TARGET=build_ubsan

build_asan_clang:
	make build_any TARGET=build_asan_clang

build_tsan_clang:
	make build_any TARGET=build_tsan_clang

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
			$(BIN_DIR)/; \
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
			$(BIN_DIR)/; \
	fi

test:
	LD_LIBRARY_PATH=$(BIN_DIR) $(BIN_DIR)/download_heightmap --help > /dev/null
	LD_LIBRARY_PATH=$(BIN_DIR) $(BIN_DIR)/render_scene_file --help > /dev/null

run:
	LD_LIBRARY_PATH=$(BIN_DIR) \
		$(BIN_DIR)/render_scene_file \
		data \
		data/levels/main/main.scn.json \
		--app_reldir .osm_rally \
		--print_render_residual_time \
		--nsamples_msaa 2 \
		--show_mouse_cursor \
		--windowed_width 1500 \
		--windowed_height 900

run_dev: build
	gdb -ex="catch throw" --ex=r --args Mlib/$(PLATFORM_DIR)/Bin/render_scene_file \
		data \
		data/levels/main/main.scn.json \
		--app_reldir .osm_rally \
		--print_render_residual_time \
		--print_physics_residual_time \
		--nsamples_msaa 2 \
		--show_mouse_cursor \
		--windowed_width 1500 \
		--windowed_height 900 \
		--devel_mode

run_tsan:
	OMP_NUM_THREADS=1 \
	TSAN_OPTIONS="second_deadlock_stack=1 suppressions=Mlib/suppressions.txt" \
		Mlib/T$(PLATFORM_DIR)/Bin/render_scene_file \
		data \
		data/levels/main/main.scn.json \
		--app_reldir .osm_rally \
		--print_render_residual_time \
		--print_physics_residual_time \
		--nsamples_msaa 2 \
		--show_mouse_cursor \
		--windowed_width 1500 \
		--windowed_height 900 \
		--devel_mode
