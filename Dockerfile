FROM alpine:3.15

RUN apk add --no-cache openssh-client lftp 
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]