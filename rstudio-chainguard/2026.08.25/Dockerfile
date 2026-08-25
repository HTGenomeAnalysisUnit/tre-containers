FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
LABEL Description="RStudio Server with basic R packages"
LABEL version="2026.08.25"

USER root

# Install graphical system dependencies
RUN apk add \
	font-dejavu \
	libpng-dev \
	pango-dev \
	libxt-dev

USER rstudio-server

# Install R packages
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]