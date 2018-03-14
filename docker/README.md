# Dockerfiles

## Overview
Separated Dockerfile into two parts due to how excessively long numpy/scipy take to install. Any additional packages can be added to main requirements.txt, but the image base will always jsut pull from this Dockerfile. Yes it is cached but idk it still sucks.

## How it works
- tbh idk
- `cd docker/` to this folder
- Build this image (one-time only): `docker build -t dora:ml .`
- `cd ..` back to the main Mappening-Backend repo
- `make dev` as normal (or push? I think it'd work...)

