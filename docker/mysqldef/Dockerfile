FROM alpine:3.19
RUN apk add --no-cache curl && \
    curl -sL https://github.com/sqldef/sqldef/releases/latest/download/mysqldef_linux_amd64.tar.gz \
    | tar xz -C /usr/local/bin
ENTRYPOINT ["mysqldef"]
