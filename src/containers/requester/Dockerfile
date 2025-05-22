FROM alpine:latest

RUN apk add --no-cache curl jq

COPY ./containers/requester/behavior/requester.sh /requester.sh
RUN chmod +x /requester.sh

CMD ["/requester.sh"]