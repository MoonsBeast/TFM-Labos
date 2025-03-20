FROM python:3.12

RUN mkdir -p /server
WORKDIR /server

RUN apt-get update && rm -rf /var/lib/apt/lists/* 

COPY ./server /server

RUN pip install --no-cache-dir --upgrade -r requirements.txt