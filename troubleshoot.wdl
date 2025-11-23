version 1.0

task milk {

    command <<<
    echo "What a beautiful face \n
I have found in this place \n
That is circling all 'round the sun \n
And when we meet on a cloud \n
I'll be laughing out loud \n
I'll be laughing with everyone I see \n
Can't believe \n
How strange it is to be anything at all" \
    > aeroplane.txt
    >>>

    output {
        File aeroplane = read_string("aeroplane.txt")
    }

}
workflow troubleshoot {

    call milk {}

}