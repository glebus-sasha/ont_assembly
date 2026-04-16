process FUNANNOTATE_FIX {
    tag "${meta.id}"
    
    conda 'bioconda::funannotate'
    container 'nextgenusfs/funannotate:v1.8.15'
    //errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(meta), path(gbk), path(tbl)

    output:
    tuple val(meta), path("*_fixed"), emit: fixed

    script:
    """
    funannotate fix \\
      --input $gbk \\
      --tbl $tbl \\
      --out ${meta.id}_fixed
    """
    }