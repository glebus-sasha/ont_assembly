process FUNANNOTATE_BUSCO_INSTALL {
    tag "$busco_bd_name"
    conda 'bioconda::funannotate'
    container 'nextgenusfs/funannotate:v1.8.15'
    errorStrategy 'ignore'
    cpus params.cpus 

    input:
    val(busco_bd_name)
  
    output:
    path("*")

    script:
    """
    funannotate setup \\
        -b $busco_bd_name
    """
    }