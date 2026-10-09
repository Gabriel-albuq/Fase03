FROM golang:1.26.5-alpine3.24 AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

RUN go build -v -o /usr/local/bin/app ./...


FROM alpine:3.24

COPY --from=builder /usr/local/bin/app /usr/local/bin/app

RUN adduser -D -u 1000 appuser
USER appuser

EXPOSE 8001

CMD ["app"]