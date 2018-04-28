FROM node:latest
MAINTAINER Rich Irwin <rich.irwin@wwt.com>

RUN npm install -g json-server

EXPOSE 80
COPY run.sh /run.sh
COPY db.json /db.json
ENTRYPOINT ["bash", "/run.sh"]
CMD []
