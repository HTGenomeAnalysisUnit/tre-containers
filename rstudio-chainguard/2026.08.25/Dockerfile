FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
LABEL Description="RStudio Server with basic R packages"
LABEL version="2026.08.25"

USER root

# Install graphical system dependencies
RUN apk add \
	harfbuzz-dev \
	freetype-dev \
	font-liberation \
	libjpeg-turbo-dev \
	libpng-dev \
	libwebp \
	libwebp-dev \
	pango-dev \
	tiff-dev \
	libxt-dev && \
	rm -f /usr/lib/libtiff.a /usr/lib64/libtiff.a && \
	ln -sf "$(ls -v /usr/lib/libwebp.so.[0-9]* | tail -n 1)" /usr/lib/libwebp.so && \
	ln -sf "$(ls -v /usr/lib/libwebpmux.so.[0-9]* | tail -n 1)" /usr/lib/libwebpmux.so

USER rstudio-server

# Install R packages
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]