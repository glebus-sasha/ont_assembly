process PHOBIUS {
    tag "${meta.id}"
    conda 'bioconda::phobius'
    container 'barbarahelena/phobius:1.01'
    errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(meta), path(proteins)

    output:
    tuple val(meta), path("*_phobius.txt")

    script:
    """
    phobius $proteins -short > ${meta.id}_phobius.txt
    """
}

