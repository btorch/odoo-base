FROM ubuntu:18.04

ARG TERM=xterm
ARG DEBIAN_FRONTEND=noninteractive

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d


WORKDIR /opt/sources/

# Installing some initial tools
RUN apt-get update && \
  apt-get install -y locales \
  apt-utils curl wget debconf \
  ca-certificates gnupg 


# Setting up Locales
RUN locale-gen en_US en_US.UTF-8 pt_BR pt_BR.UTF-8 && \
  dpkg-reconfigure locales
ENV LC_ALL pt_BR.UTF-8


# Setting up TzData
ENV TZ=America/Fortaleza
RUN echo $TZ > /etc/timezone && \
  apt-get update && apt-get install -y tzdata && \
  rm /etc/localtime && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  apt-get clean


# Node.js LTS (v12.x) repo setup
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -

# Install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - 


# Tools 
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install -y unzip chrony xsltproc \
  git gcc build-essential postgresql-client-12=12.4-1.pgdg18.04+2 \
  libpq5=12.4-1.pgdg18.04+2 \
  software-properties-common nodejs gettext-base \
  openssh-client \
  && rm -rf /var/lib/apt/lists/*


# Python3 Installs
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install -y python3-dbus python3-pip \
  python3-setuptools python3-wheel python3-pypdf2 \
  python3-psycopg2 python3-suds python3-debconf \
  python3-greenlet python3.6 python3.6-minimal \
  python-openssl python-cffi \
  && rm -rf /var/lib/apt/lists/*

  
# Development tools and native dependencies 
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  apt-get install -y python3-dev libxml2-dev \
  libxslt1-dev libldap2-dev libsasl2-dev \
  libtiff5-dev libjpeg8-dev libopenjp2-7-dev \
  zlib1g-dev libfreetype6-dev libssl-dev \
  liblcms2-dev libwebp-dev libharfbuzz-dev \
  libfribidi-dev libxcb1-dev libpq-dev=12.4-1.pgdg18.04+2 \
  libzip-dev libxslt-dev libjpeg-dev \
  python3.6-dev libxmlsec1-dev libevent-dev \
  && rm -rf /var/lib/apt/lists/*


# PIP Upgrade
RUN pip3 install --no-cache-dir --upgrade pip


# Setting up Python3 as default
# RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1 && \
RUN  update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
  update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1


# Installing wkhtmltox
ADD https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb /opt/sources/wkhtmltox.deb
RUN apt-get update && \
  apt-get install -y fontconfig libx11-6 libxext6 \
  libxrender1 xfonts-base xfonts-75dpi \
  && dpkg -i /opt/sources/wkhtmltox.deb \
  && rm -rf /var/lib/apt/lists/* 


WORKDIR /opt/

