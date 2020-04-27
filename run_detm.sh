#!/bin/bash

set -e

# First run scripts/make_data.sh


# Possible alternative options:
# --rho_size 300 (that's the default)

data_path=${1:-sessionsAndOrdinarys-txt-tok.tsv-centuries}
echo STARTING: "$(date)"
if [ "$data_path" != "sessionsAndOrdinarys-txt-tok.tsv-centuries" ]
then
echo ++ Training embeddings for Old Bailey.
CUDA_DEVICES=3 python3 skipgram.py \
  --data_file /data/clambert/$data_path-proc \
  --emb_file data/$data_path-embed \
  --dim_rho 100 --iters 50 --window_size 4
echo Done with embeddings: "$(date)"
else
echo ++ Not training embeddings, already done
fi

echo ++ Learning topics for Old Bailey.

mkdir -p results/$data_path

###

# This results in running out of memory.

# echo ++ min_df 1 max_df 1.0

# export CKPT_PATH=./results/sessionsAndOrdinarys-txt-tok/etm_min_df_0_max_df_1.0_K_30_Htheta_800_Optim_adam_Clip_0.0_ThetaAct_relu_Lr_0.005_Bsz_1000_RhoSize_300_trainEmbeddings_1

# python3 main.py \
#   --mode train \
#   --dataset ob \
#   --data_path data/old-bailey-split-clambert.tsv/min_df_1_max_df_1.0 \
#   --num_topics 30 \
#   --emb_path data/old-bailey-embed \
#   --epochs 10 \
#   --min_df 1 \
#   --emb_size 100 \
#   --rho_size 100 \
#   --lr 0.0001 \
#   > results/old-bailey-split-clambert.tsv/min_df_1_max_df_1.0.log

# python3 main.py \
#   --mode eval \
#   --dataset ob \
#   --data_path data/old-bailey-split-clambert.tsv/min_df_1_max_df_.10 \
#   --num_topics 30 \
#   --emb_path data/old-bailey-embed \
#   --tc 1 \
#   --load_from $CKPT_PATH


###

# echo ++ min_df 1 max_df 0.9

# python3 main.py \
#   --mode train \
#   --dataset ob \
#   --data_path data/old-bailey-split-clambert.tsv/min_df_1_max_df_0.9 \
#   --num_topics 30 \
#   --emb_path data/old-bailey-embed \
#   --epochs 10 \
#   --min_df 1 \
#   --emb_size 100 \
#   --rho_size 100 \
#   --lr 0.0001 \
#   > results/old-bailey-split-clambert.tsv/min_df_1_max_df_0.9.log


### CHANGE EVERYTHING BELOW THIS TO MATCH WITH THE PATHS I HAVE!

#echo ++ min_df 10 max_df 0.9
#
#python3 main.py \
#  --mode train \
#  --dataset ob \
#  --data_path data/old-bailey-split-clambert.tsv/min_df_10_max_df_0.9 \
#  --num_topics 30 \
#  --emb_path data/old-bailey-embed \
#  --epochs 10 \
#  --min_df 1 \
#  --emb_size 100 \
#  --rho_size 300 \
#  --lr 0.00001 \
#  > results/old-bailey-split-clambert.tsv/min_df_10_max_df_0.9.log
#
#
###

echo ++ min_df 50 max_df 0.9

CUDA_DEVICES=3 python3 main.py \
  --mode train \
  --dataset ob \
  --data_path scripts/$data_path/min_df_50_max_df_0.9 \
  --num_topics 30 \
  --emb_path data/$data_path-embed \
  --epochs 100 \
  --min_df 50 \
  --emb_size 100 \
  --rho_size 100 \
  --lr 0.004 \
  --tc 1 \
  > results/$data_path/min_df_50_max_df_0.9_t_30_epochs_100_lr_0.004.log

echo ++ Done with training on $data_path: "$(date)"

###

#echo ++ min_df 100 max_df 0.8
#
#python3 main.py \
#  --mode train \
#  --dataset ob \
#  --data_path data/old-bailey-split-clambert.tsv/min_df_100_max_df_0.8 \
#  --num_topics 30 \
#  --emb_path data/old-bailey-embed \
#  --epochs 10 \
#  --min_df 100 \
#  --emb_size 100 \
#  --rho_size 100 \
#  --lr 0.0001 \
#  > results/old-bailey-split-clambert.tsv/min_df_100_max_df_0.8.log
#
#
#echo ++ Training embeddings for Old Bailey + London Lives.
#
#python3 skipgram.py \
#  --data_file /data/jgordon/old-bailey/old-bailey+ll.tsv-proc \
#  --emb_file data/old-bailey+ll-embed \
#  --dim_rho 100 --iters 50 --window_size 4
#
#
#echo ++ Learning topics for Old Bailey using OBLL embeddings.
#
#python3 main.py \
#  --mode train \
#  --dataset ob \
#  --data_path data/old-bailey-split-clambert.tsv/min_df_100_max_df_0.8 \
#  --num_topics 50 \
#  --emb_path data/old-bailey+ll-embed \
#  --epochs 10 \
#  --min_df 100 \
#  --emb_size 100 \
#  --rho_size 300 \
#  --lr 0.00001 \
#  > results/old-bailey+ll-100-0.8-300-0.00001
