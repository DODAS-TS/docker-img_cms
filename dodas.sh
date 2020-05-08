#!/bin/bash

echo "Executing dodas manual "

chown condor:condor /tmp/proxy/gwms_proxy

su condor "/home/condor/dodas-glidein_startup_wrapper3"
