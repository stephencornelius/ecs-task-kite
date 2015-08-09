# Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
# 	http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

GOPATH := $(GOPATH):$(shell pwd)/vendor

all: static-go-binary ./misc/ca-bundle.crt
	docker build -q -t amazon/ecs-task-kite:latest .

static-go-binary:
	@echo $$GOPATH
	@mkdir -p bin
	CGO_ENABLED=0 go build -a -installsuffix cgo -o ./bin/ecs-task-kite github.com/awslabs/ecs-task-kite/

./misc/ca-bundle.crt:
	@mkdir -p misc
	curl -s https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt > ./misc/ca-bundle.crt

generate:
	go generate ./...

test:
	go test ./...

clean:
	rm -rf ./bin ./pkg ./vendor/pkg ./misc/ca-bundle.crt
	-rmdir ./misc/

lint:
	go vet ./...
	for pkg in $(shell go list -f "{{.Dir}}" ./... | grep -v "/mocks/"); do golint $$pkg; done
