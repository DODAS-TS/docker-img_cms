#!/bin/bash

yum -y install ca-policy-egi-core
yum -y install ca-policy-lcg
/usr/sbin/fetch-crl -q

wget -O /etc/yum.repos.d/ca_CMS-TTS-CA.repo https://ci.cloud.cnaf.infn.it/job/cnaf-mw-devel-jobs/job/ca_CMS-TTS-CA/job/master/lastSuccessfulBuild/artifact/ca_CMS-TTS-CA.repo
yum -y install ca_CMS-TTS-CA

export X509_USER_PROXY=/root/proxy/gwms_proxy
export X509_CERT_DIR=/etc/grid-security/certificates
grid-proxy-info

GATKEEPER=$CMS_LOCAL_SITE:8443

if [ $? -eq 0 ]; then
    echo "proxy certificate is OK"

    ### Configure condor
    str1=$(grep "GLIDEIN_Site =" /etc/condor/config.d/99_DODAS_local)
    sed -i -e "s/$str1/GLIDEIN_Site = \"$CMS_LOCAL_SITE\"/g" /etc/condor/config.d/99_DODAS_local
    str2=$(grep "GLIDEIN_CMSSite =" /etc/condor/config.d/99_DODAS_local)
    sed -i -e "s/$str2/GLIDEIN_CMSSite = \"$CMS_LOCAL_SITE\"/g" /etc/condor/config.d/99_DODAS_local
    str3=$(grep "GLIDEIN_Gatekeeper =" /etc/condor/config.d/99_DODAS_local)
    sed -i -e "s/$str3/GLIDEIN_Gatekeeper = \"$GATKEEPER\"/g" /etc/condor/config.d/99_DODAS_local
    str4=$(grep "NUM_CPUS" /etc/condor/config.d/03_DODAS_Partitionable_Slots)
    sed -i -e "s/$str4/NUM_CPUS = ${NUM_CPUS%.*}/g" /etc/condor/config.d/03_DODAS_Partitionable_Slots


    COLLECTOR_PORT=`shuf -i 9621-9720 -n 1`
    sed -i -e "s/COLLECTOR_PORT/${COLLECTOR_PORT}/g" /etc/condor/config.d/99_DODAS_tweaks

    CCB_PORT=`shuf -i 9619-9720 -n 1`
    sed -i -e "s/CCB_PORT/${CCB_PORT}/g" /etc/condor/config.d/99_DODAS_tweaks

    export PATH=$PATH:/usr/libexec/condor

    #oneclient -i -o allow_other -H $CMS_ONEDATA_CACHE -t $ONEDATA_ACCESS_TOKEN /mnt/onedata/
else
    echo "proxy certificate is Failure"
    exit 9
fi
