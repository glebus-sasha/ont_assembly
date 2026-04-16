process FUNANNOTATE_SORT {
    tag "${meta.id}"
    
    conda 'bioconda::funannotate'
    container 'nextgenusfs/funannotate:v1.8.15'
    errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(meta), path(genome)
  
    output:
    tuple val(meta), path("*_sorted.fa")

    script:
    """
    funannotate sort -i $genome -b scaffold -o ${meta.id}_sorted.fa
    """
    }