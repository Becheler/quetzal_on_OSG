#!/bin/bash

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Generates a DAGMan workflow to organize the iDDC multiple jobs into a single workflow."
   echo
   echo "Syntax: scriptTemplate [-h|]"
   echo "positional parameters:"
   echo "<integer>   The number of demogenetic simulations."
   echo "<integer>   The number of repetitions if simulation failed."
   echo "options:"
   echo "h     Print this Help."
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

echo "JOB GBIF ../src/DAG/1-get-gbif.condor"
echo "JOB SDM ../src/DAG/2-sdm.condor"
echo "PARENT GBIF CHILD SDM"

for i in $(seq "$1")
do
   echo "JOB A$i ../src/DAG/A.condor NOOP"
   echo "VARS A$i i=\"$i\""
   echo "PARENT SDM CHILD A$i"

   echo "Retry A$i $2"

   echo "JOB B$i ../src/DAG/B.condor NOOP"
   echo "VARS B$i i=\"$i\""
   echo "PARENT A$i CHILD B$i"

done
