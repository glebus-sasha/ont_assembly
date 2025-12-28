process CONCATENATE_ALL_FASTA {
    tag "all_samples"
    //errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(gene), path(files)

    output:
    tuple val(gene), path("*.fasta"), emit: fasta
       
    script:
    """
    cat $files > ${gene}.fasta
    """
}