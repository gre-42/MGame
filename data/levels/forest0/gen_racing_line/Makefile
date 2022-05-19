.PHONY: racing_line_forest0.m

all: optimize_forest0 racing_line_forest0.m

forest0.csv: ../../../../Mlib/racing_line/osm_to_racing_line.py ../map_forest0.osm Makefile
	../../../../Mlib/racing_line/osm_to_racing_line.py \
		../map_forest0.osm \
		forest0.csv \
		--translation forest0_t.m \
		--rotation forest0_R.m \
		--start_node_id -117364 \
		--street_width 11.2

optimize_forest0: forest0.csv Makefile
	docker run -dit --rm --name racing_line racing_line
	docker cp forest0.csv racing_line:/global_racetrajectory_optimization/inputs/tracks/
	docker exec racing_line sed -i s/berlin_2018/forest0/g /global_racetrajectory_optimization/main_globaltraj.py
	docker exec -t racing_line python3 /global_racetrajectory_optimization/main_globaltraj.py
	rm -rf outputs_forest0
	docker cp racing_line:/global_racetrajectory_optimization/outputs outputs_forest0
	docker stop racing_line

racing_line_forest0.m:
	../../../../Mlib/racing_line/racing_line_to_mgame.py \
		outputs_forest0 \
		racing_line_forest0.m \
		--translation forest0_t.m \
		--rotation forest0_R.m
