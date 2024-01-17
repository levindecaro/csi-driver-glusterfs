FROM golang:1.20 as builder

WORKDIR /go/src/app

ADD cmd /go/src/app/cmd
ADD pkg /go/src/app/pkg
ADD vendor /go/src/app/vendor
ADD go.mod /go/src/app/go.mod

RUN go mod tidy && \
    go mod vendor

RUN ls /go/src/app

RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags "-X github.com/levindeccaro/csi-driver-glusterfs/pkg/glusterfs.driverVersion=1.0.0 -s -w -extldflags "-static"" -mod vendor -o bin/glusterfsplugin ./cmd/glusterfsplugin

FROM centos:stream8

# Copy glusterfsplugin from build _output directory
#COPY bin/glusterfsplugin /glusterfsplugin

COPY --from=builder bin/glusterfsplugin /glusterfsplugin

RUN dnf update -y && \
    dnf install glusterfs glusterfs-fuse -y 

ENTRYPOINT ["/glusterfsplugin"]
