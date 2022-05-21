.PHONY: racing_line_raceway0.m

all: optimize_raceway0 racing_line_raceway0.m

raceway0.csv: ../../../../Mlib/racing_line/osm_to_racing_line.py ../map_raceway0.osm Makefile
	../../../../Mlib/racing_line/osm_to_racing_line.py \
		../map_raceway0.osm \
		raceway0.csv \
		--translation raceway0_t.m \
		--rotation raceway0_R.m \
		--start_node_id -114585 \
		--street_width 20

optimize_raceway0: raceway0.csv Makefile
	docker run -dit --rm --name racing_line racing_line
	docker cp raceway0.csv racing_line:/global_racetrajectory_optimization/inputs/tracks/
	docker exec racing_line sed -i s/berlin_2018/raceway0/g /global_racetrajectory_optimization/main_globaltraj.py
	docker exec -t racing_line python3 /global_racetrajectory_optimization/main_globaltraj.py
	rm -rf outputs_raceway0
	docker cp racing_line:/global_racetrajectory_optimization/outputs outputs_raceway0
	docker stop racing_line

racing_line_raceway0.m:
	../../../../Mlib/racing_line/racing_line_to_mgame.py \
		outputs_raceway0 \
		racing_line_raceway0.m \
		--translation raceway0_t.m \
		--rotation raceway0_R.m

stats:
	../../../../Mlib/racing_line/racing_line_stats.py \
		outputs_raceway0
