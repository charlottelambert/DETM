#!/usr/bin/env python3
import pickle, argparse

import matplotlib.pyplot as plt
import numpy as np
import scipy.io

import data, os, re

# ./plot_word_evolution.py --data_dir=scripts/sessionsAndOrdinarys-txt-tok.tsv-decades/min_df_100_max_df_0.8/ --beta_file=results/sessionsAndOrdinarys-txt-tok.tsv-decades/detm_ob_K_30_Htheta_800_Optim_adam_Clip_0.0_ThetaAct_relu_Lr_0.004_Bsz_1000_RhoSize_100_L_3_minDF_100_trainEmbeddings_1_beta.mat

parser = argparse.ArgumentParser()
parser.add_argument('--beta_file', type=str, default='./beta_100.mat')
parser.add_argument('--data_dir', type=str, default='un/min_df_100')
parser.add_argument('--words_per_slice', type=int, default=3)
parser.add_argument('--print_topics', default=0, type=int, help='whether or not to print out topics')
args = parser.parse_args()


beta = scipy.io.loadmat(args.beta_file)["values"]  # K x T x V
print("beta: ", beta.shape)

with open(os.path.join(args.data_dir, "timestamps.pkl"), "rb") as f:
    timelist = pickle.load(f)

T = len(timelist)
ticks = [str(x) for x in timelist]
# print("ticks: ", ticks)
print("Number of time slices: ", T)

## get vocab
vocab, train, valid, test = data.get_data(args.data_dir, temporal=True)
vocab_size = len(vocab)

## plot topics
num_words = 10

if "decades" in args.data_dir:
    times = [0, 10, 20]
    timelist = [int(t)*10 for t in timelist]
    xlabel = "Decade"
elif "centuries" in args.data_dir:
    times = [0, 1, 2]
    timelist = [1674, 1774, 1874]
    xlabel = "Century"
else: times = [0]

# Get num topics from input filename
try:
    num_topics = int(re.search("K_[0-9]+", os.path.basename(args.beta_file)).group().split("_")[1])
except:
    num_topics = 50

print("Visualizing", num_topics, "topics...")

# {topic_id:[top, words, from, all, time, slices]}
word_list_dict = {}

# Build up dictionary mapping each topic number to the top n words in each time
# slice
for k in range(num_topics):
    word_list_dict[k] = set()
    for t in times:
        gamma = beta[k, t, :]
        top_words = list(gamma.argsort()[-num_words + 1 :][::-1])
        topic_words = [vocab[a] for a in top_words]
        if args.print_topics:
            print("Topic {} .. Time: {} ===> {}".format(k, t, topic_words))
        word_list_dict[k].update(set(topic_words[0:args.words_per_slice]))
    word_list_dict[k] = list(word_list_dict[k])


def plot_topic_words(args, k, word_list):
    """
        Plot the evolution of the top n words of each time slice in topic k
        and save the plot.

        inputs:
            args: input arguments
            k (int): topic id
            word_list (list): list of words to visualize
    """

    fig, (axis) = plt.subplots(
    # change nrows and ncols if more plots
        nrows=1, ncols=1, figsize=(18, 9), dpi=80, facecolor="w", edgecolor="k"
    )
    ticks = [str(x) for x in timelist]

    tokens = [vocab.index(w) for w in word_list]
    betas = [beta[k, :, x] for x in tokens]
    for i, comp in enumerate(betas):
        axis.plot(
            comp, label=word_list[i], lw=2, linestyle="--", marker="o", markersize=4
        )
    axis.legend(frameon=False, fontsize=14)
    axis.set_xticks(np.arange(T))
    axis.set_xticklabels(timelist, fontsize=14)
    axis.set_title('Topic: ' + str(k), fontsize=20)
    axis.set_xlabel(xlabel, fontsize=16)
    axis.set_ylabel("Word Probability", fontsize=16)
    fig.tight_layout()

    # Save plot to subdirectory in results directory
    sub_dir = os.path.join("word_evolutions", os.path.basename(args.beta_file).split("_beta.mat")[0])
    fig_path = os.path.join(os.path.dirname(args.beta_file), sub_dir, str(k) + "_word_evolution.png")
    # Make directory if it doesn't exist
    if not os.path.exists(os.path.dirname(fig_path)): os.makedirs(os.path.dirname(fig_path))
    plt.savefig(fig_path)
    plt.close()
    # plt.show()
    print("Figure saved to", fig_path)

for k, word_list in word_list_dict.items():
    plot_topic_words(args, k, word_list)
