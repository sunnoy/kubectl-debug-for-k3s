.PHONY: build kubectl-debug-binary debug-agent-binary debug-agent-docker-image check
SHELL = /bin/bash
LDFLAGS = $(shell ./version.sh)
GOENV  := GO15VENDOREXPERIMENT="1" GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64
GO := $(GOENV) /root/.g/go/bin/go

VERSION := 2.6

default: build

build: kubectl-debug-binary debug-agent-docker-image

kubectl-debug-binary:
	GO111MODULE=on CGO_ENABLED=0 /root/.g/go/bin/go build -ldflags '$(LDFLAGS)' -o kubectl-debug cmd/kubectl-debug/main.go

#################################
debug-agent-docker-image: debug-agent-binary runver
	docker build . -t sunnoy/debug-agent:$(VERSION)
	docker push sunnoy/debug-agent:$(VERSION)

runver:
	bash ./confg.sh $(VERSION)



debug-agent-binary:
	rm -rf debug-agent
	$(GO) build -ldflags '$(LDFLAGS)' -o debug-agent cmd/debug-agent/main.go

check:
	find . -iname '*.go' -type f | grep -v /vendor/ | xargs gofmt -l
	GO111MODULE=on go test -v -race ./...
	$(GO) vet ./...
