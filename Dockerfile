FROM debian

RUN apt-get update && apt-get upgrade -y && apt-get install -y supervisor && apt-get autoremove -y

COPY install.sh panaf/
COPY supervisord.conf /etc

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
