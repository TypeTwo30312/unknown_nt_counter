# countNs WDL workflows

This repository contains two WDL workflows for counting unknown nucleotides (`N`/`n`) in a FASTA file:

- `countNs_slow` – processes the whole file linearly in a single task.
- `countNs_fast` – splits a multi-FASTA into individual sequences and counts Ns per sequence in parallel.
