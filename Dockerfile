FROM dodasts/centos:7-grid
LABEL Version=1.0

RUN useradd -ms /bin/bash condor 

WORKDIR /home/condor

RUN wget https://raw.githubusercontent.com/glideinWMS/glideinwms/master/creation/web_base/glidein_startup.sh \
    && wget https://gist.githubusercontent.com/spigad/8e3a394392811a86bef6020cb7f1ab7e/raw/060f13ff82a3efbc0b53e3be148a1569696887b7/dodas-glidein_startup_wrapper3

RUN mkdir -p runjob \
    && mkdir -p /etc/cvmfs/SITECONF 

COPY dodas.sh /usr/local/bin/

RUN chown condor:condor glidein_startup.sh \
    && chown condor:condor dodas-glidein_startup_wrapper3 \
    && chown condor:condor runjob \
    && chmod +x glidein_startup.sh \
    && chmod +x dodas-glidein_startup_wrapper3 \
    && chmod +x /usr/local/bin/dodas.sh 
