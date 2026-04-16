process EGGNOG_MAPPER {
    tag "${meta.id}"
    conda 'bioconda::eggnog-mapper'
    container 'dataspott/eggnog-mapper:2.1.8--2022-07-11'
    //errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(meta), path(proteins)
    path eggnog_proteins

    output:
    tuple val(meta), path("*.emapper.annotations"), emit: emapper_annotations
   
    script:
    """
    emapper.py \
        -i $proteins \
        -o $meta.id \
        --data_dir $eggnog_proteins \
        --cpu ${task.cpus}
    """
}

