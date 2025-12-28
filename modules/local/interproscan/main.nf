process INTERPROSCAN {
    tag "$sid"
    label 'process_medium'
    label 'process_long'

    conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/interproscan:5.59_91.0--hec16e2b_1' :
    //    'quay.io/biocontainers/interproscan:5.59_91.0--hec16e2b_1' }"

    input:
    tuple val(sid), path(fasta)
    path(interproscan_database, stageAs: 'data')

    output:
    tuple val(sid), path('*.xml') , optional: true, emit: xml   

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${sid}"
    """
    interproscan.sh \\
        --cpu ${task.cpus} \\
        --input ${fasta} \\
        ${args} \\
        --output-file-base ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        interproscan: \$( interproscan.sh --version | sed '1!d; s/.*version //' )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${sid}"
    """
    touch ${prefix}.{tsv,xml,json,gff3}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        interproscan: \$( interproscan.sh --version | sed '1!d; s/.*version //' )
    END_VERSIONS
    """
}

