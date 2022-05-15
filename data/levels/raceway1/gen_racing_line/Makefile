.PHONY: racing_line_raceway1.m

all: optimize_raceway1 racing_line_raceway1.m

raceway1.csv: ../../../../Mlib/racing_line/osm_to_racing_line.py ../map_raceway1.osm Makefile
	../../../../Mlib/racing_line/osm_to_racing_line.py \
		../map_raceway1.osm \
		raceway1.csv \
		--translation raceway1_t.m \
		--rotation raceway1_R.m \
		--start_node_id -114585 \
		--street_width 20

optimize_raceway1: raceway1.csv Makefile
	docker run -dit --rm --name racing_line racing_line
	docker cp raceway1.csv racing_line:/global_racetrajectory_optimization/inputs/tracks/
	docker exec racing_line sed -i s/berlin_2018/raceway1/g /global_racetrajectory_optimization/main_globaltraj.py
	docker exec -t racing_line python3 /global_racetrajectory_optimization/main_globaltraj.py
	rm -rf outputs_raceway1
	docker cp racing_line:/global_racetrajectory_optimization/outputs outputs_raceway1
	docker stop racing_line

racing_line_raceway1.m:
	../../../../Mlib/racing_line/racing_line_to_mgame.py \
		outputs_raceway1 \
		racing_line_raceway1.m \
		--translation raceway1_t.m \
		--rotation raceway1_R.m
