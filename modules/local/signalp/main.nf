process SIGNALP {
    tag "${meta.id}"
    conda 'bioconda::signalp'
    container 'doejgi/signalp:v5'
    errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(meta), path(proteins)

    output:
    tuple val(meta), path("*.signalp5")

    script:
    """
    signalp -fasta $proteins -org euk -format short
    """
}

