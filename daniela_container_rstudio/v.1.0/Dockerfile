FROM ghtrecontainers/rstudio-desktop:2024.09.0

ARG DEBIAN_FRONTEND=noninteractive

LABEL Author="Daniela Zanotti"
LABEL Contact="daniela.zanotti@fht.org"
LABEL Versuion="1.0"

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rstudio"]
