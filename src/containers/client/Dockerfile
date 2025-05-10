FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

COPY ./containers/client/behavior /behavior

WORKDIR /behavior

RUN chmod +x ./behavior.sh ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]