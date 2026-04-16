process ANTISMASH {
    tag "${meta.id}"
    conda 'bioconda::antismash'
    container 'antismash/standalone:8.0.1'
    //errorStrategy 'ignore'
    cpus params.cpus
       
    input:
    tuple val(meta), path(genome), path(gbk)
    
    output:
    tuple val(meta), path("*_antismash"), emit: antismash_folder
    tuple val(meta), path("*_antismash/${meta.id}.gbk"), emit: gbk

    script:
    """
    antismash \
        --taxon fungi \
        --genefinding-too none \
        --cpus ${task.cpus} \
        --output-dir ${meta.id}_antismash \
        --output-basename ${meta.id} \
        --clusterhmmer \
        --pfam2go \
        --cb-general \
        --cc-mibig \
        $gbk
    """
}