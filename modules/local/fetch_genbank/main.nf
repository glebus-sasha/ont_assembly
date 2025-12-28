process FETCH_GENBANK {
    tag "${meta.id}_${meta.gene}"
    label 'process_small'
    label 'error_retry'
    conda "${moduleDir}/environment.yml"
    container "biocontainers/ncbi-entrez-direct:v10.9.20190219ds-1b10-deb_cv1"

    input:
    val(meta)

    output:
    tuple val(meta), path("*.fasta"), emit: fasta

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def outfile = "${meta.species}_${meta.strain}_${meta.gene}.fasta".replaceAll(/\s/, '_')

    """
    efetch -db nucleotide -id ${meta.id} -format fasta ${args} > ${outfile}  

    if ! grep -q '^>' "${outfile}"; then
        echo "ERROR: Invalid or empty FASTA for ${meta.id}" >&2
        exit 1
    fi
    """

    stub:
    """
    touch ${meta.species}_${meta.strain}_${meta.gene}.fasta
    """
}
