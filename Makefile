build:
	docker build -t peterrosell/freeradius .

push:
	docker push peterrosell/freeradius

run:
	docker run -d --name freeradius -p 1812:1812 -p 1812:1812/udp peterrosell/freeradius

bash:
	docker run -it --rm --name freeradius-bash -p 1812:1812 peterrosell/freeradius bash

logs-run:
	docker logs --tail=200 -f freeradius

logs-bash:
	docker logs --tail=200 -f freeradius-bash
