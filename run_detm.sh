#!/bin/bash
set -e

# First run scripts/make_data.sh

# Possible alternative options:
# --rho_size 300 (that's the default)

data_path=${1:-sessionsAndOrdinarys-txt-tok.tsv-decades}
echo STARTING: "$(date)"
echo ++ Training embeddings for Old Bailey.
CUDA_DEVICES=3 python3 skipgram.py \
  --data_file /data/clambert/$data_path-proc \
  --emb_file data/$data_path-embed \
  --dim_rho 100 --iters 50 --window_size 4
echo Done with embeddings: "$(date)"

echo ++ Learning topics for Old Bailey.

mkdir -p results/$data_path

# Initialize values for training:
min_df=50
max_df=0.9
num_topics=70
epochs=100
lr=0.004
echo ++ min_df $min_df max_df $max_df

CUDA_DEVICES=3 python3 main.py \
  --mode train \
  --dataset ob \
  --data_path scripts/$data_path/min_df_$min_df\_max_df_$max_df \
  --num_topics $num_topics \
  --emb_path data/$data_path-embed \
  --epochs $epochs \
  --min_df $min_df \
  --emb_size 100 \
  --rho_size 100 \
  --lr $lr \
  --tc 1 \
  > results/$data_path/min_df_$min_df\_max_df_$max_df\_t_$num_topics\_epochs_$epochs\_lr_$lr.log

echo ++ Done with training on $data_path: "$(date)"
