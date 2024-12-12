FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="snpboost container for tWAS"
LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
# Match the version label to the container version tag
LABEL version="1.0"
LABEL help="snpboost.R is in /opt/snpboost" 

USER root
RUN apk add zlib-dev zstd-dev glibc gsl-dev

# WORKDIR /opt
# RUN wget ftp://ftp.gnu.org/gnu/gsl/gsl-2.8.tar.gz && \
# 	tar -xvzf gsl-2.8.tar.gz && \
# 	rm gsl-2.8.tar.gz && \
# 	cd gsl-2.8 && \
# 	./configure && \
# 	make && \
# 	make install && \
# 	cd /opt && \
# 	rm -rf gsl-2.8

USER rstudio-server

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

WORKDIR /opt
COPY snpboost.tar.gz .
RUN tar -xvzf snpboost.tar.gz

ENTRYPOINT ["rserver"]