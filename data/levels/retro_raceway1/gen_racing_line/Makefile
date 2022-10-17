.PHONY: retro_raceway1.1.csv optimize_retro_raceway1.1 racing_line_retro_raceway1.1.m stats stats.1

CONTAINER ?= racing_line
RETRO_RACEWAY1 ?= retro_raceway1
OUTPUTS_RETRO_RACEWAY1 ?= outputs_retro_raceway1

all: optimize_retro_raceway1 optimize_retro_raceway1.1 racing_line_retro_raceway1.1.m deploy

retro_raceway1.csv: ../../../../Mlib/racing_line/osm_to_race_track.py ../map_retro_raceway1.osm Makefile
	../../../../Mlib/racing_line/osm_to_race_track.py \
		../map_retro_raceway1.osm \
		retro_raceway1.csv \
		--translation retro_raceway1_t.m \
		--rotation retro_raceway1_R.m \
		--start_node_id -137778 \
		--street_width 5

retro_raceway1.1.csv:
	../../../../Mlib/racing_line/racing_line_to_race_track.py \
		outputs_retro_raceway1 \
		retro_raceway1.1.csv \
		--down_sampling 10 \
		--street_width 5

optimize_retro_raceway1.1:
	make optimize_retro_raceway1 \
		CONTAINER=$(CONTAINER) \
		RETRO_RACEWAY1=retro_raceway1.1 \
		OUTPUTS_RETRO_RACEWAY1=outputs_retro_raceway1.1

racing_line_retro_raceway1.1.m:
	../../../../Mlib/racing_line/racing_line_to_mgame.py \
		outputs_retro_raceway1.1 \
		racing_line_retro_raceway1.1.m \
		--translation retro_raceway1_t.m \
		--rotation retro_raceway1_R.m

deploy:
	cp racing_line_retro_raceway1.1.m ../racing_line_retro_raceway1.m

stats:
	../../../../Mlib/racing_line/racing_line_stats.py \
		outputs_retro_raceway1

stats.1:
	../../../../Mlib/racing_line/racing_line_stats.py \
		outputs_retro_raceway1.1

optimize_retro_raceway1: $(RETRO_RACEWAY1).csv Makefile
	docker run -dit --rm --name $(CONTAINER) racing_line
	docker cp $(RETRO_RACEWAY1).csv $(CONTAINER):/global_racetrajectory_optimization/inputs/tracks/
	docker exec $(CONTAINER) sed -i s/berlin_2018/$(RETRO_RACEWAY1)/g /global_racetrajectory_optimization/main_globaltraj.py

	# Enable plotting
	docker exec $(CONTAINER) sed -i 's/"mincurv_curv_lin": False/"mincurv_curv_lin": True/g' /global_racetrajectory_optimization/main_globaltraj.py
	docker exec $(CONTAINER) sed -i 's/"imported_bounds": False/"imported_bounds": True/g' /global_racetrajectory_optimization/main_globaltraj.py
	docker exec $(CONTAINER) sed -i 's/"racetraj_vel_3d": False/"racetraj_vel_3d": True/g' /global_racetrajectory_optimization/main_globaltraj.py
	docker exec $(CONTAINER) sed -i 's/"spline_normals": False/"spline_normals": True/g' /global_racetrajectory_optimization/main_globaltraj.py
	docker exec $(CONTAINER) sed -i 's/"mintime_plots": False/"mintime_plots": True/g' /global_racetrajectory_optimization/main_globaltraj.py

	# Increase step size by a factor of 2.
	docker exec $(CONTAINER) sed -i 's/"stepsize_prep": 1.0/"stepsize_prep": 2.0/g' /global_racetrajectory_optimization/params/racecar.ini
	docker exec $(CONTAINER) sed -i 's/"stepsize_reg": 3.0/"stepsize_reg": 6.0/g' /global_racetrajectory_optimization/params/racecar.ini
	docker exec $(CONTAINER) sed -i 's/"stepsize_interp_after_opt": 2.0/"stepsize_interp_after_opt": 4.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# # Increase smoothness of controls
	# docker exec $(CONTAINER) sed -i 's/"penalty_delta": 10.0/"penalty_delta": 40.0/g' /global_racetrajectory_optimization/params/racecar.ini
	# docker exec $(CONTAINER) sed -i 's/"penalty_F": 0.01/"penalty_F": 0.04/g' /global_racetrajectory_optimization/params/racecar.ini

	# Set maximum velocity to 288kph
	docker exec $(CONTAINER) sed -i 's/"v_max": 70.0/"v_max": 80.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# Set power to 400PS.
	docker exec $(CONTAINER) sed -i 's/"power_max": 230000.0/"power_max": 294200.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# Set moment of inertia to 2000kg*m²
	docker exec $(CONTAINER) sed -i 's/"I_z": 1200.0/"I_z": 2000.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# Increase maximum driving force to maximum inside friction bounds (vehicle mass is 1200kg).
	docker exec $(CONTAINER) sed -i 's/"f_drive_max": 7000.0/"f_drive_max": 11760.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# Decrease maximum break force to maximum inside friction bounds (vehicle mass is 1200kg).
	docker exec $(CONTAINER) sed -i 's/"f_brake_max": 20000.0/"f_brake_max": 11760.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# Move COM to origin
	# docker exec $(CONTAINER) sed -i 's/"cog_z": 0.38/"cog_z": 0.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# Enable 4 wheel drive
	docker exec $(CONTAINER) sed -i 's/"k_brake_front": 0.6/"k_brake_front": 0.5/g' /global_racetrajectory_optimization/params/racecar.ini
	docker exec $(CONTAINER) sed -i 's/"k_drive_front": 0.0/"k_drive_front": 0.5/g' /global_racetrajectory_optimization/params/racecar.ini

	# # Set f_z0 to 1/4*(vehicle mass=1200kg)*9.8.
	# docker exec $(CONTAINER) sed -i 's/"f_z0": 3000.0/"f_z0": 2940.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# # Set mue=0.5.
	# docker exec $(CONTAINER) sed -i 's/"mue": 1.0/"mue": 0.5/g' /global_racetrajectory_optimization/params/racecar.ini

	# Set gravity=9.8.
	docker exec $(CONTAINER) sed -i 's/"g": 9.81/"g": 9.8/g' /global_racetrajectory_optimization/params/racecar.ini

	# Deactivate lift coefficients.
	docker exec $(CONTAINER) sed -i 's/"liftcoeff_front": 0.45/"liftcoeff_front": 0.0/g' /global_racetrajectory_optimization/params/racecar.ini
	docker exec $(CONTAINER) sed -i 's/"liftcoeff_rear": 0.75/"liftcoeff_rear": 0.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# Deactive drag coefficient.
	docker exec $(CONTAINER) sed -i 's/"dragcoeff": 0.75/"dragcoeff": 0.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# Enable limitation of accelerations.
	docker exec $(CONTAINER) sed -i 's/"safe_traj": false/"safe_traj": true/g' /global_racetrajectory_optimization/params/racecar.ini
	docker exec $(CONTAINER) sed -i 's/"ax_pos_safe": null/"ax_pos_safe": 9.0/g' /global_racetrajectory_optimization/params/racecar.ini
	docker exec $(CONTAINER) sed -i 's/"ax_neg_safe": null/"ax_neg_safe": -9.0/g' /global_racetrajectory_optimization/params/racecar.ini
	docker exec $(CONTAINER) sed -i 's/"ay_safe": null/"ay_safe": 9.0/g' /global_racetrajectory_optimization/params/racecar.ini

	# # Retain only static forces
	# docker exec $(CONTAINER) sed -i 's/f_z_fl = f_zstat_fl + f_zlift_fl + f_zdyn_fl/f_z_fl = f_zstat_fl/g' /global_racetrajectory_optimization/params/racecar.ini
	# docker exec $(CONTAINER) sed -i 's/f_z_fr = f_zstat_fr + f_zlift_fr + f_zdyn_fr/f_z_fr = f_zstat_fr/g' /global_racetrajectory_optimization/params/racecar.ini
	# docker exec $(CONTAINER) sed -i 's/f_z_rl = f_zstat_rl + f_zlift_rl + f_zdyn_rl/f_z_rl = f_zstat_rl/g' /global_racetrajectory_optimization/params/racecar.ini
	# docker exec $(CONTAINER) sed -i 's/f_z_rr = f_zstat_rr + f_zlift_rr + f_zdyn_rr/f_z_rr = f_zstat_rr/g' /global_racetrajectory_optimization/params/racecar.ini

	# Copy and apply patch to simplify acceleration ellipse.
	docker cp ../../../../Mlib/racing_line/opt_mintime.py.patch $(CONTAINER):/global_racetrajectory_optimization/opt_mintime_traj/src/
	docker exec -w /global_racetrajectory_optimization/opt_mintime_traj/src $(CONTAINER) bash -c "patch < opt_mintime.py.patch"

	# Copy and apply patch to plot to SVG.
	docker cp ../../../../Mlib/racing_line/result_plots_mintime.py.patch $(CONTAINER):/global_racetrajectory_optimization/opt_mintime_traj/src/
	docker exec -w /global_racetrajectory_optimization/opt_mintime_traj/src $(CONTAINER) bash -c "patch < result_plots_mintime.py.patch"

	# # Reoptimize curvature
	# docker exec $(CONTAINER) sed -i 's/"reopt_mintime_solution": False/"reopt_mintime_solution": True/g' /global_racetrajectory_optimization/main_globaltraj.py

	# # Patch min-curvature script to plot to SVG
	# docker cp ../../../../Mlib/racing_line/opt_min_curv.py.patch $(CONTAINER):/tmp/
	# docker exec $(CONTAINER) bash -c "cd /usr/local/lib/python*/dist-packages/trajectory_planning_helpers && mv /tmp/opt_min_curv.py.patch . && patch < opt_min_curv.py.patch"

	docker exec -t $(CONTAINER) python3 /global_racetrajectory_optimization/main_globaltraj.py
	rm -rf $(OUTPUTS_RETRO_RACEWAY1)
	docker cp $(CONTAINER):/global_racetrajectory_optimization/outputs $(OUTPUTS_RETRO_RACEWAY1)
	docker stop $(CONTAINER)
