FROM cgr.dev/chainguard/rstudio:latest-dev

LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
LABEL Description="RStudio Server with basic R packages"
LABEL version="2023.12.1"

USER root

# Install popular system dependencies
RUN apk add \
	cmake \
	fontconfig-dev \
	gmp \
	pkgconf \
	zlib \
	fribidi-dev \
	cairo-dev \
	freetype-dev \
	glib-dev

# Install Nlopt
WORKDIR /opt
RUN wget https://github.com/stevengj/nlopt/archive/v2.7.1.tar.gz && \
	tar -xvf v2.7.1.tar.gz && \
	rm v2.7.1.tar.gz && \
	cd nlopt-2.7.1 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	cd /opt && \
	rm -rf nlopt-2.7.1

# Install harfbuzz
WORKDIR /opt
RUN wget https://github.com/harfbuzz/harfbuzz/releases/download/10.0.1/harfbuzz-10.0.1.tar.xz && \
	tar -xvf harfbuzz-10.0.1.tar.xz && \
	rm harfbuzz-10.0.1.tar.xz && \
	cd harfbuzz-10.0.1 && \
	mkdir build && \
	cd build && \
	cmake .. && \
	make && \
	make install && \
	cd /opt && \
	rm -rf harfbuzz-10.0.1

USER rstudio-server

# Install remote/BiocManager to manage R packages
RUN R -e "install.packages(c('remotes','BiocManager'), repos='http://cran.rstudio.com/')"

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]