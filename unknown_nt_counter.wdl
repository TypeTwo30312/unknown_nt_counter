version 1.0

task count_Ns {
    input {
        File fasta
    }

    command <<<
        grep -v '^>' ~{fasta} \
        | tr -d '\n' \
        | grep -o 'N' \ 
        | wc -l > n_count.txt
    >>>

    output {
    Int Ns = read_int("n_count.txt")
    String header = read_string("header.txt")
    }
}

task split_fasta {
    input {
        File fasta
    }

    command <<<
        mkdir -p splits
        awk 'BEGIN { RS=">"; ORS="" }
          NR>1 {
           # NR-1: sequence index starting at 1
           fname = sprintf("splits/seq_%04d.fasta", NR-1);
           print ">" $0 > fname
         }' "~{fasta}"
    >>>
    output {
        Array[File] split_fastas = glob("splits/seq_*.fasta")
    }
}

task sum_ints {

  input {
    Array[Int] ints
  }

  command <<<
    printf "%s " ~{sep=' ' ints} \
    | awk '{for (i=1; i<=NF; i++) s += $i} END {print s}' \
    > total.txt
  >>>

  output {
    Int total = read_int("total.txt")
  }

}

workflow countNs_slow {
  input {
    File fasta
  }

  call count_Ns { input: fasta = fasta }

  output {
    Int total_unknown_Ns = count_Ns.Ns
  }
}

workflow countNs_fast {
  input {
    File fasta
  }

  # 1) Split multi-FASTA into individual FASTA files
  call split_fasta { input: fasta = fasta }

  # 2) Process each sequence file in parallel
  scatter (f in split_fasta.split_fastas) {
    call count_Ns as count_Ns_per_seq { input: fasta = f }
  }

  # 3) Sum over all sequences
  call sum_ints { input: ints = count_Ns_per_seq.Ns }

  output {
    Int total_unknown_Ns      = sum_ints.total
    Array[String] sequence_headers  = count_Ns_per_seq.header
    Array[Int] per_sequence_Ns = count_Ns_per_seq.Ns
    Array[File] per_sequence_fastas = split_fasta.split_fastas
  }
}

