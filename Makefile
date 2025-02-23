.PHONY: recastnavigation build package test run run_dev

CMAKE_BUILD_TYPE ?= Release
BUILD_PREFIX ?= G
platform_dir != if [ "$$OSTYPE" = "msys" ] || [ "$$OSTYPE" = "cygwin" ]; then \
        echo $(BUILD_PREFIX)M$(CMAKE_BUILD_TYPE); \
    else \
        echo $(BUILD_PREFIX)U$(CMAKE_BUILD_TYPE); \
    fi
ostype != echo "$$OSTYPE";
bin_dir = $(platform_dir)

all: recastnavigation build package test

recastnavigation:
	make -C Mlib recastnavigation \
		CMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE)

build_any:
	BUILD_PREFIX=$(BUILD_PREFIX) \
	CMAKE_OPTIONS="-DBUILD_TRIANGLE=OFF -DBUILD_CV=OFF -DBUILD_SFM=OFF -DBUILD_OPENCV=OFF" \
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
	@echo "Platform dir: $(platform_dir)"
	if [ "$$OSTYPE" = "msys" ] || [ "$$OSTYPE" = "cygwin" ]; then \
		rsync -avh --checksum \
			/mingw64/bin/glfw3.dll \
			Mlib/$(platform_dir)/Bin/download_heightmap.exe \
			Mlib/$(platform_dir)/Bin/render_scene_file.exe \
			Mlib/$(platform_dir)/Bin/libMlibArray.dll \
			Mlib/$(platform_dir)/Bin/libMlibAudio.dll \
			Mlib/$(platform_dir)/Bin/libMlibComponents.dll \
			Mlib/$(platform_dir)/Bin/libMlibCppHttplib.dll \
			Mlib/$(platform_dir)/Bin/libMlib.dll \
			Mlib/$(platform_dir)/Bin/libMlibGeography.dll \
			Mlib/$(platform_dir)/Bin/libMlibGeometry.dll \
			Mlib/$(platform_dir)/Bin/libMlibGlad.dll \
			Mlib/$(platform_dir)/Bin/libMlibHalf.dll \
			Mlib/$(platform_dir)/Bin/libMlibImages.dll \
			Mlib/$(platform_dir)/Bin/libMlibIo.dll \
			Mlib/$(platform_dir)/Bin/libMlibJson.dll \
			Mlib/$(platform_dir)/Bin/libMlibLayout.dll \
			Mlib/$(platform_dir)/Bin/libMlibMacroExecutor.dll \
			Mlib/$(platform_dir)/Bin/libMlibMath.dll \
			Mlib/$(platform_dir)/Bin/libMlibMemory.dll \
			Mlib/$(platform_dir)/Bin/libMlibNavigation.dll \
			Mlib/$(platform_dir)/Bin/libMlibNvDds.dll \
			Mlib/$(platform_dir)/Bin/libMlibOs.dll \
			Mlib/$(platform_dir)/Bin/libMlibOsmLoader.dll \
			Mlib/$(platform_dir)/Bin/libMlibPhysics.dll \
			Mlib/$(platform_dir)/Bin/libMlibPlayers.dll \
			Mlib/$(platform_dir)/Bin/libMlibPoly2Tri.dll \
			Mlib/$(platform_dir)/Bin/libMlibRegex.dll \
			Mlib/$(platform_dir)/Bin/libMlibRender.dll \
			Mlib/$(platform_dir)/Bin/libMlibScene.dll \
			Mlib/$(platform_dir)/Bin/libMlibSceneGraph.dll \
			Mlib/$(platform_dir)/Bin/libMlibStats.dll \
			Mlib/$(platform_dir)/Bin/libMlibStbCpp.dll \
			Mlib/$(platform_dir)/Bin/libMlibStb.dll \
			Mlib/$(platform_dir)/Bin/libMlibStrings.dll \
			Mlib/$(platform_dir)/Bin/libMlibThreads.dll \
			Mlib/$(platform_dir)/Bin/libMlibTime.dll \
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
			$(bin_dir)/; \
	else \
		rsync -avh --checksum \
			/usr/lib/x86_64-linux-gnu/libalut.so* \
			/usr/lib/x86_64-linux-gnu/libglfw.so* \
			/usr/lib/x86_64-linux-gnu/libopenal.so* \
			Mlib/$(platform_dir)/Bin/download_heightmap \
			Mlib/$(platform_dir)/Bin/render_scene_file \
			Mlib/$(platform_dir)/Lib/ \
			Mlib/RecastBuild/DebugUtils/libDebugUtils.so* \
			Mlib/RecastBuild/Detour/libDetour.so* \
			Mlib/RecastBuild/Recast/libRecast.so* \
			$(bin_dir)/; \
	fi

test:
	LD_LIBRARY_PATH=$(bin_dir) $(bin_dir)/download_heightmap --help > /dev/null
	LD_LIBRARY_PATH=$(bin_dir) $(bin_dir)/render_scene_file --help > /dev/null

run:
	LD_LIBRARY_PATH=$(bin_dir) \
		$(bin_dir)/render_scene_file \
		data \
		data/levels/main/main.scn.json \
		--app_reldir .osm_rally \
		--print_render_residual_time \
		--nsamples_msaa 2 \
		--show_mouse_cursor \
		--windowed_width 1500 \
		--windowed_height 900

run_dev: build
	gdb -ex="catch throw" --ex=r --args Mlib/$(platform_dir)/Bin/render_scene_file \
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
		Mlib/TGURelWithDebInfo/Bin/render_scene_file \
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
