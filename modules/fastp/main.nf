process FASTP {
    container 'nanozoo/fastp:0.23.1--9f2e255'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
//	  debug true
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(reads)

    output:
    tuple val(sid), path("*_R1_trimmed.fastq.gz"), path("*_R2_trimmed.fastq.gz"),     emit: trimmed_reads
    path '*.html',                                                              emit: html, optional: true
    path '*.json',                                                              emit: json, optional: true

    script:
    """
    fastp \
    --thread ${task.cpus} \
    --in1 ${reads[0]} \
    --in2 ${reads[1]}\
    --out1 "${sid}_R1_trimmed.fastq.gz" \
    --out2 "${sid}_R2_trimmed.fastq.gz" \
    --html ${sid}.fastp_stats.html \
    --json ${sid}.fastp_stats.json 
    """

    stub:
    """
    touch ${sid}.fastp_stats.html
    touch ${sid}.fastp_stats.json
    touch ${sid}_R1.fastq.gz
    touch ${sid}_R2.fastq.gz
    """
}