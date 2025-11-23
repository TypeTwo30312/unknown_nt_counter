version 1.0

task count_Ns {
    input {
        File fasta
    }

    command <<<
        grep '^>' ~{fasta} \
        > header.txt
        grep -v '^>' ~{fasta} \
        | tr -d '\n' \
        | grep -o 'N' \ 
        | wc -l > n_count.txt
    >>>

    output {
    Int Ns = read_int("n_count.txt")
    String header = read_string("header.txt")
    }

    runtime {
      docker: "ubuntu:22.04"
      memory: "1 GB"
      cpu: 1
    }
}

task split_fasta {
    input {
        File fasta
    }

    command <<<
        awk 'BEGIN{RS=">";FS="\n"} NR>1{fnme = sprintf("seq_%d.fa", ((NR - 1))); print ">" $0 > fnme; close(fnme);}' ~{fasta}
    >>>
    output {
        Array[File] split_fastas = glob("seq_*.fa")
    }

    runtime {
      docker: "ubuntu:22.04"
      memory: "1 GB"
      cpu: 1
    }
}

task sum_ints {
  input {
    Array[Int] ints
  }

  command <<<
    tot = 0
    for i in ~{ints}; do:
      tot = ((tot + i))
    end
    echo $tot > total.txt
  >>>

  output {
    Int total = read_int("total.txt")
  }

  runtime {
    docker: "ubuntu:22.04"
    memory: "1 GB"
    cpu: 1
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
    Int total_unknown_Ns = sum_ints.total
    Array[String] sequence_headers = count_Ns_per_seq.header
    Array[Int] per_sequence_Ns = count_Ns_per_seq.Ns
    Array[File] per_sequence_fastas = split_fasta.split_fastas
  }
}

