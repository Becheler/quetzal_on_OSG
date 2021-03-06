#!/bin/bash

############################################################
# Help                                                     #
############################################################
dislay_help()
{
   # Display Help
   echo "Generates a DAGMan workflow to organize the iDDC multiple jobs into a single workflow."
   echo
   echo "Syntax: scriptTemplate [-h|]"
   echo "positional parameters:"
   echo "<integer>   The number of demogenetic simulations."
   echo "<integer>   The number of repetitions if simulation failed."
   echo "<array>     The space delimited array of CHELSA timesID for SDM"
   echo "options:"
   echo "h     Print this Help."
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Help menu
if [ "$1" == "-h" ]; then
  dislay_help
  exit 0
fi

# Read parameters
nb_sim=$1
shift
nb_retry=$1
shift
timesID=("$@")

# DAG graph
echo "JOB GET-GBIF   ../src/DAG/1-get-gbif.condor"
echo "JOB VIS-GBIF   ../src/DAG/2-visualize-gbif.condor"

echo "PARENT GET-GBIF CHILD VIS-GBIF"

for t in "${timesID[@]}"
do
   echo "PARENT GET-GBIF CHILD GET-CHELSA$t"
   echo "SCRIPT PRE GET-CHELSA$t ../src/DAG/3-pre-script.sh output-files/3-get-chelsa"

   echo "JOB GET-CHELSA$t ../src/DAG/3-get-chelsa.condor"
   echo "VARS GET-CHELSA$t t=\"$t\""

   echo "SCRIPT POST GET-CHELSA$t ../src/DAG/3-post-script.sh output-files/3-get-chelsa"
   echo "PARENT GET-CHELSA$t CHILD SDM"
done

echo "JOB  SDM ../src/DAG/4-sdm.condor"

comma_separated_timesID=$(IFS=, ; echo "${timesID[*]}")
echo "VARS SDM timesID=\"${comma_separated_timesID[@]}\""

for i in $(seq "$nb_sim")
do
   echo "JOB A$i ../src/DAG/A.condor NOOP"
   echo "VARS A$i i=\"$i\""
   echo "PARENT SDM CHILD A$i"

   echo "Retry A$i $nb_retry"

   echo "JOB B$i ../src/DAG/B.condor NOOP"
   echo "VARS B$i i=\"$i\""
   echo "PARENT A$i CHILD B$i"
done

echo "DOT dag.dot"
