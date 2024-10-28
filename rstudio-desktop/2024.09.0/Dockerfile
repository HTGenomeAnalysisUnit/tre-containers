FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG RSTUDIO_VERSION=2024.09.0-375-amd64

LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
LABEL Description="RStudio Desktop with basic R packages"
LABEL version="2024.09.0"

ENV PATH=/usr/lib/rstudio-server/bin:${PATH}
ENV LC_ALL=en_GB.UTF-8
ENV LANG=en_GB.UTF-8

RUN apt update \
   && apt install -y --no-install-recommends \
      autoconf \
      automake \
      build-essential \
      libcairo2-dev \
      libgdal-dev \
      libgl-dev \
      libpng-dev \
      libjpeg-dev \
      libtiff-dev \
      libc++-dev \
      libfreetype6-dev \
      libfontconfig1-dev \
      libharfbuzz-dev \
      libfribidi-dev \
      libhdf5-dev \
      libboost-all-dev \
      libxml2-dev \
      openjdk-8-jdk \
      libfftw3-dev \
      libgsl-dev \
      proj-bin \
      pkg-config \
      tzdata \
      locales \
      wget \
      git \
      gdebi-core \
      libxml2-dev \
      libssl-dev \
      libcurl4-openssl-dev \
      libgtk-3-0 \
      libxslt1-dev \
      qmake6 \
      qt6-base-dev \
      r-base \
      r-base-dev \
      python3 \
      python3-dev \
      python3-pip \
   && apt -y autoremove --purge \
   && apt -y clean

RUN echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen \
   && locale-gen en_GB.utf8 \
   && /usr/sbin/update-locale LANG=en_GB.UTF-8

# Install rstudio
WORKDIR /opt
RUN wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-${RSTUDIO_VERSION}.deb \
   && gdebi -n rstudio-${RSTUDIO_VERSION}.deb \
   && rm rstudio-${RSTUDIO_VERSION}.deb      

# Install remotes to manage R packages
RUN R -e "install.packages(c('remotes','BiocManager'), repos='http://cran.rstudio.com/')"

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rstudio"]