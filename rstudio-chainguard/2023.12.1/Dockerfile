FROM cgr.dev/chainguard/rstudio

LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
LABEL Description="RStudio Server with basic R packages"
LABEL version="2023.12.1"

# Install remotes to manage R packages
RUN R -e "install.packages(c('remotes','BiocManager'), repos='http://cran.rstudio.com/')"

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]