#!/bin/bash

dir=/usr/local/deepMirCut
cd $dir
prepareData=$dir"/prepareData.pl"
bpRNA=/usr/local/deepMirCut/bpRNA
sed -i '3s|.*|do "'$bpRNA'";|g' $prepareData

seqBPRNAList=$dir'/seqBPRNA_ensemble_list.txt' 
sed -E -i 's|^.*ensemble_models\/model_([0-9]*)_([0-9]*).model|'$dir'\/ensemble_models\/model_\1_\2.model|' $seqBPRNAList


