process FUNANNOTATE_CLEAN {
    tag "${meta.id}"
    
    conda 'bioconda::funannotate'
    container 'nextgenusfs/funannotate:v1.8.15'
    errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(meta), path(genome)
  
    output:
    tuple val(meta), path("*_cleaned.fa")

    script:
    """
    funannotate clean -i $genome --minlen 1000 -o ${meta.id}_cleaned.fa
    """
    }