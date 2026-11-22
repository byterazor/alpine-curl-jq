FROM alpine:latest
RUN apk update && apk add --no-cache tini bash curl jq
