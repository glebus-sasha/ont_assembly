include { assembly_taxonomy_hybrid           } from './subworkflows/assembly_taxonomy_hybrid.nf'
include { BAKTA                              } from './modules/bakta'
include { QUAST                              } from './modules/quast'
include { BUSCO                              } from './modules/busco'
include { NCBITOOLS_VECSCREEN                } from './modules/ncbitools/vecscreen'
include { MULTIQC                            } from './modules/multiqc/'

workflow {
    ch_multiqc = channel.empty()
    
    //short_reads = channel.fromFilePairs("${params.reads}/*R{1,2}*").view()

    ch_reads = channel.fromPath("${params.reads}/*.fastq*")
        .branch { it ->
            paired: it.simpleName.contains("_R1") || it.simpleName.contains("_R2")
            single: true
        }

    ch_paired_reads = ch_reads.paired
        .map { file -> 
            def sid = file.simpleName.replaceAll(/_R[12]/, "")
            [sid, file.simpleName.contains("_R1") ? 'R1' : 'R2', file] 
        }
        .groupTuple(by: 0)
        .map { sid, types, files ->
            // Сортируем, чтобы гарантировать порядок R1, R2
            def r1 = files[types.indexOf('R1')]
            def r2 = files[types.indexOf('R2')]
            [sid, r1, r2]
        }

    // Для одиночных (long) ридов
    ch_single_reads = ch_reads.single
        .map { file -> [file.simpleName, file] }

    // Объединяем с правильным порядком: sid, R1, R2, long
    ch_reads = ch_paired_reads
        .join(ch_single_reads)

    assembly_taxonomy_hybrid(ch_reads)
    busco_db                 = channel.fromPath(params.busco_db).collect()
    ch_genome = assembly_taxonomy_hybrid.out.genome
    BAKTA(ch_genome, params.bakta_db)
    QUAST(ch_genome.join(BAKTA.out.gff3))
    BUSCO(
        ch_genome, 
        busco_db
        )
    /*ch_multiqc = assembly_taxonomy_long.out.fastqc.map {it[1]}
        .mix(assembly_taxonomy_long.out.fastqc_trimmed.map {it[1]})
        .mix(assembly_taxonomy_long.out.samtools_flagstat.map {it[1]})
        .mix(assembly_taxonomy_long.out.mosdepth_global_dist.map {it[1]})
        .mix(assembly_taxonomy_long.out.mosdepth_summary.map {it[1]})
        .mix(BAKTA.out.txt.map {it[1]})
        .mix(BUSCO.out.txt.map {it[1]})
        .mix(QUAST.out.map {it[1]})
        .collect()*/
    
    MULTIQC(ch_multiqc)
}

