#!/bin/bash

set -e

DATA_OB=/data/clambert/sessionsAndOrdinarys-txt-tok.tsv-decades
#DATA_OBLL=/data/clambert/OB_LL-txt-tok.tsv-centuries
DATA_OB_BI=/data/clambert/sessionsAndOrdinarys-txt-tok-bi.tsv-decades
#DATA_OBLL_BI=/data/clambert/OB_LL-txt-tok-bi.tsv-centuries./data_ob.py 

# Baseline
./data_ob.py $DATA_OB 0.8 100
./data_ob.py $DATA_OB 0.9 50
# With London Lives
#./data_ob.py $DATA_OBLL 0.9 50

# Baseline
./data_ob.py $DATA_OB_BI 0.8 100
./data_ob.py $DATA_OB_BI 0.9 50
# With London Lives
#./data_ob.py $DATA_OBLL_BI 0.9 50
