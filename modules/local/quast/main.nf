process QUAST {
    tag "$meta.id"
    conda 'bioconda::quast'
    container 'staphb/quast:5.3.0'
    //errorStrategy 'ignore'
    cpus params.cpus
       
    input:
    tuple val(meta), path(genome)
    
    output:
    tuple val(meta), path("${meta.id}")
    
    script:
    """
    quast.py \
        ${genome} \
        -o ${meta.id} \
        --threads ${task.cpus}
    """
}