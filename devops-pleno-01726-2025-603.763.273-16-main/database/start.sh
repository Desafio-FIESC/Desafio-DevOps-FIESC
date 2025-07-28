#!/bin/sh

docker run --rm \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=secret \
    -e POSTGRES_DB=db_prova \
    -e TZ=America/Sao_Paulo \
    -p 5432:5432 \
    -v "$PWD/scripts":/docker-entrypoint-initdb.d \
    postgres:10