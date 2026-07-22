FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="Working env for Alice's analysis"
LABEL Author="Alice Flamigni"
LABEL Contact="alice.flamigni@fht.org"
# Match the version label to the container version tag
LABEL version="1.0" 

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
# DOWNLOAD_STATIC_LIBV8=1 tells the V8 R package to download a static libv8 build
# since the chainguard base image does not include libv8-dev system headers
ENV DOWNLOAD_STATIC_LIBV8=1
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]
