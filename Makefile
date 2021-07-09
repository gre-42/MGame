CMAKE_BUILD_TYPE ?= Release
platform_dir != if [ "$$OSTYPE" = "msys" ] ; then \
        echo M${CMAKE_BUILD_TYPE}; \
    else \
        echo U${CMAKE_BUILD_TYPE}; \
    fi
build_target != if [ "$$OSTYPE" = "msys" ] ; then \
        echo build; \
    else \
        echo build10; \
    fi
ostype != echo "$$OSTYPE";
bin_dir = $(platform_dir)

all: build package

build:
	@echo "OS Type: $(ostype)"
	make -C Mlib $(build_target) CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}

package:
	@echo "OS Type: $(ostype)"
	if [ "$$OSTYPE" = "msys" ] ; then \
		rsync -avh --checksum \
			/mingw64/bin/glfw3.dll \
			Mlib/$(platform_dir)/Bin/render_scene_file.exe \
			Mlib/$(platform_dir)/Bin/libMlib.so \
			Mlib/$(platform_dir)/Bin/libMlibCv.so \
			Mlib/$(platform_dir)/Bin/libMlibGeometry.so \
			Mlib/$(platform_dir)/Bin/libMlibImages.so \
			Mlib/$(platform_dir)/Bin/libMlibMath.so \
			Mlib/$(platform_dir)/Bin/libMlibPhysics.so \
			Mlib/$(platform_dir)/Bin/libMlibPoly2Tri.so \
			Mlib/$(platform_dir)/Bin/libMlibRender.so \
			Mlib/$(platform_dir)/Bin/libMlibScene.so \
			Mlib/$(platform_dir)/Bin/libMlibSceneGraph.so \
			Mlib/$(platform_dir)/Bin/libMlibStbImage.so \
			Mlib/$(platform_dir)/Bin/libMlibStrings.so \
			Mlib/$(platform_dir)/Bin/libMlibThreads.so \
			/mingw64/bin/libgcc_s_seh-1.dll \
			/mingw64/bin/libgomp-1.dll \
			/mingw64/bin/libstdc++-6.dll \
			/mingw64/bin/libvulkan-1.dll \
			/mingw64/bin/libwinpthread-1.dll \
			$(bin_dir)/; \
	else \
		rsync -avh --checksum \
			/usr/lib/x86_64-linux-gnu/libglfw.so.3 \
			/usr/lib/x86_64-linux-gnu/libglfw.so.3.3 \
			Mlib/$(platform_dir)/Bin/render_scene_file \
			Mlib/$(platform_dir)/Lib/ \
			$(bin_dir)/; \
	fi

run:
	LD_LIBRARY_PATH=$(bin_dir) \
		$(bin_dir)/render_scene_file \
		$(data_dir) \
		$(data_dir)/levels/main/main.scn \
		--print_render_residual_time \
		--nsamples_msaa 2 \
		--show_mouse_cursor \
		--screen_width 1500 \
		--screen_height 900

run_dev: build
	gdb -ex="catch throw" --ex=r --args Mlib/$(platform_dir)/Bin/render_scene_file \
		data \
		data/levels/main/main.scn \
		--print_render_residual_time \
		--print_physics_residual_time \
		--nsamples_msaa 2 \
		--show_mouse_cursor \
		--screen_width 1500 \
		--screen_height 900 \
		--devel_mode
