FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

COPY ../behavior.sh /behavior/behavior.sh
COPY ../entrypoint.sh /behavior/entrypoint.sh

RUN chmod +x /behavior/behavior.sh /behavior/entrypoint.sh

ENTRYPOINT ["/behavior/entrypoint.sh"]