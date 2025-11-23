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