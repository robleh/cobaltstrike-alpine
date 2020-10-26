DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
COMMIT := $(shell git rev-parse HEAD)

build: 
	docker build --build-arg BUILD_DATE=$(DATE) --build-arg VCS_REF=$(COMMIT) -t cobaltstrike .
	docker image prune -f --filter label=stage=build
run:
	docker run -it --rm --name cobalt -p 50050:50050 -p 443:443 -p 80:80 cobaltstrike
shell:
	docker run -it --rm --name cobalt -p 50050:50050 -p 443:443 -p 80:80 --entrypoint /bin/sh cobaltstrike
clean:
	docker image rm -f cobaltstrike
