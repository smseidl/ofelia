FROM golang:1.22-alpine AS builder

RUN apk --no-cache add gcc musl-dev

WORKDIR ${GOPATH}/src/github.com/smseidl/ofelia

COPY go.mod go.sum ${GOPATH}/src/github.com/smseidl/ofelia/
RUN go mod download

COPY . ${GOPATH}/src/github.com/smseidl/ofelia/

RUN go build -o /go/bin/ofelia .

FROM alpine:3.19

# this label is required to identify container with ofelia running
LABEL ofelia.service=true
LABEL ofelia.enabled=true

RUN apk --no-cache add ca-certificates tzdata

COPY --from=builder /go/bin/ofelia /usr/bin/ofelia

ENTRYPOINT ["/usr/bin/ofelia"]

CMD ["daemon", "--config", "/etc/ofelia/config.ini"]
