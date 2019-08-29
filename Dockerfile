FROM coolersport/shell2http:1.13 as shell2http

FROM golang:1.11-alpine as builder

RUN apk add --no-cache git

RUN git clone https://github.com/square/go-jose.git $GOPATH/src/github.com/square/go-jose
WORKDIR $GOPATH/src/github.com/square/go-jose/jose-util
#RUN git checkout v2.3.1
# checkout particular commit for stable docker build
RUN git checkout 723929d55157d954c96cfd6d7d6fd1ff573b1010
ENV GO111MODULE=on
ENV CGO_ENABLED=0
RUN go get -v ./...
RUN go install -a -v -ldflags="-w -s" ./...

FROM alpine:3.10

COPY --from=builder /go/bin/jose-util /usr/bin/jose-util
COPY --from=shell2http /app/shell2http /usr/bin/shell2http

RUN addgroup alpine && adduser -S -D -G alpine alpine && \
    apk add --no-cache bash curl

USER alpine
ENTRYPOINT ["jose-util"]
