FROM golang:latest AS builder

WORKDIR /k8-rest-api2redis

COPY . /k8-rest-api2redis

RUN go mod init && \
    go mod vendor && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server -a -tags netgo

FROM scratch

COPY --from=builder /k8-rest-api2redis/server /

CMD ["/server"]
