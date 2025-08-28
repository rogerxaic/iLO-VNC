# STAGE 1 : DOWNLOAD REQUIREMENTS
FROM public.ecr.aws/lts/ubuntu:22.04_stable AS requirements

WORKDIR /requirements

RUN apt-get update && apt-get install -y wget

RUN wget https://netcologne.dl.sourceforge.net/project/virtualgl/3.0.1/virtualgl_3.0.1_amd64.deb && \
    wget https://altushost-swe.dl.sourceforge.net/project/turbovnc/3.0.1/turbovnc_3.0.1_amd64.deb


# STAGE 2 : BUILD
FROM xnaveira/docker-javaws

USER root

ENV USER=root
ENV PASSWORD=password1
ENV DEBIAN_FRONTEND=noninteractive 
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ENV ILO_USER user
ENV ILO_PASSWORD password
ENV ILO_HOST=192.168.42.37
EXPOSE 80

RUN apt-get update && \
	echo "tzdata tzdata/Areas select Europe" > ~/tx.txt && \
	echo "tzdata tzdata/Zones/Europe select Paris" >> ~/tx.txt && \
	debconf-set-selections ~/tx.txt && \
	apt-get install -y gnupg apt-transport-https wget software-properties-common ratpoison novnc websockify libxv1 libglu1-mesa xauth x11-utils xorg tightvncserver ca-certificates

COPY --from=requirements /requirements/virtualgl_3.0.1_amd64.deb .
COPY --from=requirements /requirements/turbovnc_3.0.1_amd64.deb .

RUN	dpkg -i virtualgl_*.deb && \
	dpkg -i turbovnc_*.deb && \
	mkdir ~/.vnc/ && \
	mkdir ~/.dosbox && \
    rm -rf virtualgl_3.0.1_amd64.deb turbovnc_3.0.1_amd64.deb && \
	openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=US/ST=NY/L=NY/O=NY/OU=NY/CN=NY emailAddress=email@example.com"

RUN apt-get install -y tilda jq gettext-base

RUN echo "set border 1" > ~/.ratpoisonrc  && \
	echo 'exec tilda -c "bash -c \"jcontrol; javaws /iLO-jirc.jnlp; read -n 1 \""'>> ~/.ratpoisonrc

COPY iLO-jirc.jnlp.template .
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

COPY deployment.properties /deployment.properties

CMD /entrypoint.sh
