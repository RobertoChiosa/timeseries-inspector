FROM rocker/verse:4.1.1
# Set the used port, once deployed in CrownLabs this variable will be overrided with the value used by CrownLabs
ENV CROWNLABS_LISTEN_PORT=80
# Set the web-service basepath, once deployed in CrownLabs this variable will be overrided with the value used by CrownLabs
ENV CROWNLABS_BASE_PATH=/
# Install R packages
RUN apt-get update && apt-get install -y  git-core libcurl4-openssl-dev libgit2-dev libglpk-dev libgmp-dev libicu-dev libssl-dev libxml2-dev make pandoc zlib1g-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" | tee /usr/local/lib/R/etc/Rprofile.site | tee /usr/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("magrittr",upgrade="never", version = "2.0.3")'
RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "1.0.10")'
RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.7.2")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("shinycssloaders",upgrade="never", version = "1.0.0")'
RUN Rscript -e 'remotes::install_version("highcharter",upgrade="never", version = "0.9.4")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.3.4")'
RUN Rscript -e 'remotes::install_version("colourpicker",upgrade="never", version = "1.1.1")'
RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf /build_zone
# Create a user with UID 1010
RUN useradd -m myuser -u 1010
# Use the previously created user to run the container
USER myuser
EXPOSE ${CROWNLABS_LISTEN_PORT}
CMD R -e "options('shiny.port'=${CROWNLABS_LISTEN_PORT},shiny.host='0.0.0.0');TSinspector::run_app()"
