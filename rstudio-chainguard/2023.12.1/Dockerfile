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
	glib-dev \
	autoconf \
	automake 

# Set environment variables for compiling
ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/local/lib/pkgconfig
ENV LD_LIBRARY_PATH=/usr/lib:/usr/local/lib
ENV C_INCLUDE_PATH=/usr/include:/usr/local/include
ENV CPATH=/usr/include:/usr/local/include

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

# Install libtools
WORKDIR /opt
RUN wget https://ftp.wayne.edu/gnu/libtool/libtool-2.5.3.tar.gz && \
	tar -zxvf libtool-2.5.3.tar.gz && \
	rm libtool-2.5.3.tar.gz && \
	cd libtool-2.5.3 && \
	./configure && \
	make && \
	make install && \
	cd /opt && \
	rm -rf libtool-2.5.3

# Install harfbuzz
WORKDIR /opt
RUN wget https://github.com/harfbuzz/harfbuzz/releases/download/10.0.1/harfbuzz-10.0.1.tar.xz && \
	tar -xvf harfbuzz-10.0.1.tar.xz && \
	rm harfbuzz-10.0.1.tar.xz && \
	cd harfbuzz-10.0.1 && \
	sed -i 's/fno-exceptions/fno-exceptions -fPIC/' CMakeLists.txt && \
	mkdir build && \
	cd build && \
	cmake -DHB_HAVE_FREETYPE=ON -DHB_HAVE_CAIRO=ON .. && \
	make && \
	make install

# Install gmp library and mpfr
WORKDIR /opt
RUN wget https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz && \
	tar -xvf gmp-6.3.0.tar.xz && \
	rm gmp-6.3.0.tar.xz && \
	cd gmp-6.3.0 && \
	./configure && \
	make && \
	make install && \
	cd /opt && \
	rm -rf gmp-6.3.0

WORKDIR /opt
RUN wget https://www.mpfr.org/mpfr-current/mpfr-4.2.1.tar.xz && \
	tar -xvf mpfr-4.2.1.tar.xz && \
	rm mpfr-4.2.1.tar.xz && \
	cd mpfr-4.2.1 && \
	./configure && \
	make && \
	make install && \
	cd /opt && \
	rm -rf mpfr-4.2.1

# Install libtiff and libjpeg required by many R packages
WORKDIR /opt
RUN wget https://download.osgeo.org/libtiff/tiff-4.7.0.tar.xz && \
	tar -xvf tiff-4.7.0.tar.xz && \
	rm tiff-4.7.0.tar.xz && \
	cd tiff-4.7.0 && \
	./configure && \
	make && \
	make install && \
	cd /opt && \
	rm -rf tiff-4.7.0

WORKDIR /opt
RUN wget https://www.ijg.org/files/jpegsrc.v9f.tar.gz && \
	tar -zxvf jpegsrc.v9f.tar.gz && \
	rm jpegsrc.v9f.tar.gz && \
	cd jpeg-9f && \
	./configure && \
	make && \
	make install && \
	cd /opt && \
	rm -rf jpeg-9f

USER rstudio-server

# Install remote/BiocManager to manage R packages
RUN R -e "install.packages(c('remotes','BiocManager'), repos='http://cran.rstudio.com/')"

# Install R packages
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]