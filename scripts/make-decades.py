#!/usr/bin/env python3
import os, sys

if len(sys.argv) < 3: path = "/data/clambert"
else: path = sys.argv[1]

year_split = int(sys.argv[-1])
if year_split == 10:
    suffix = "-decades"
elif year_split == 100:
    suffix = "-centuries"
else:
    print("Input 10 or 100.")
    exit(0)

# Collect tsv files
files = [os.path.join(path, file) for file in os.listdir(path) if file[-4:] == ".tsv"]

for file in files:
    with open(file, 'r') as f:
        lines = f.read().split("\n")
        out_lines = []
        idx = 0
        start_year = int(lines[0].split("\t")[1])
        for line in lines:
            id, year, text = line.split("\t")
            if int(year) - start_year >= year_split:
                start_year = int(year)
                idx += 1
            new_line = "\t".join([id, str(idx), text])
            out_lines.append(new_line)
    with open(file + suffix, 'w') as f:
        f.write("\n".join(out_lines))
