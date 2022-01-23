# syntax=docker/dockerfile:1

##
## Build
##
FROM golang:1.16-buster AS build

LABEL maintainer="Adam Siegel <adam.siegel@slalom.com>"

COPY go.mod go.sum /go/src/github.com/adam-siegel-b/geo-org-chart/
WORKDIR /go/src/github.com/adam-siegel-b/geo-org-chart/server
RUN go mod download
COPY . /go/src/github.com/adam-siegel-b/geo-org-chart

RUN go build -o /geo-org-chart

##
## React
##
FROM node:17.4-buster AS node-build
WORKDIR /go/src/github.com/adam-siegel-b/geo-org-chart/react-app

##
## Deploy
##
FROM gcr.io/distroless/base-debian10

WORKDIR /

COPY --from=build /geo-org-chart /geo-org-chart
ADD . /static
COPY --from=build /go/src/github.com/adam-siegel-b/geo-org-chart/static/ /static/
## Todo fix
## Below is static but it's not working correctly for nested files
# USER root:root
# RUN chmod 755 /static
# RUN 'chown -R nonroot:nonroot /static/'

EXPOSE 1337

USER nonroot:nonroot

ENTRYPOINT ["/geo-org-chart"]