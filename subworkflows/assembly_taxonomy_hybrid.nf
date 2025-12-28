include { FASTQC                             } from '../modules/nf-core/fastqc/'
include { FASTQC as FASTQC_TRIMMED           } from '../modules/nf-core/fastqc/'
include { NANOFILT                           } from '../modules/nf-core/nanofilt/'
include { FASTP                              } from '../modules/nf-core/fastp/'
include { UNICYCLER                          } from '../modules/nf-core/unicycler/'

workflow assembly_taxonomy_hybrid {
    take:
    reads
    
    main:
    ch_multiqc_files = channel.empty()
    ch_versions      = channel.empty()
    //
    // MODULE: Quality Control with FastQC
    //
    FASTQC(
        reads
        )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.map { it -> it[1]})
    ch_versions      = ch_versions.mix(FASTQC.out.versions_fastqc)
    //
    // MODULE: Read Trimming with NanoFilt
    //
    ch_long_reads = reads.filter { meta, _reads -> meta.single_end }
/*     NANOFILT(
        ch_long_reads,
        []
    )
    ch_long_reads = NANOFILT.out.filtreads 
    ch_versions      = ch_versions.mix(NANOFILT.out.versions)*/
    //
    // MODULE: Read Trimming with Fastp
    //
    ch_short_reads = reads.filter { meta, _fastq -> !meta.single_end}
    ch_fastp_inputs = ch_short_reads.map { meta, fastq -> [ meta, fastq, [] ] }
    FASTP(
        ch_fastp_inputs,
        false,
        false,
        false
    )
    ch_versions      = ch_versions.mix(FASTP.out.versions)
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json.map { it -> it[1]})
    //
    // MODULE: Quality Control with FastQC on Trimmed Reads
    //
    ch_short_reads_keyed = FASTP.out.reads.map { meta, fastq -> [ meta.id, [meta, fastq] ] }
    ch_long_reads_keyed  = ch_long_reads.map  { meta, fastq -> [ meta.id, [meta, fastq] ] }
    ch_merged = ch_short_reads_keyed
        .join(ch_long_reads_keyed)
        .map { _id, short_tuple, long_tuple ->
            def meta = short_tuple[0]
            def short_reads = short_tuple[1]
            def long_reads  = long_tuple[1]
            def reads_flat = [short_reads, long_reads].flatten()
            return [meta, reads_flat]
        }
    FASTQC_TRIMMED(
        ch_merged
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.map { it -> it[1]})
    ch_versions      = ch_versions.mix(FASTQC_TRIMMED.out.versions_fastqc)
    //
    // MODULE: Hybrid Assembly with Unicycler
    //
    ch_unicycler_input = ch_merged
        .map { meta, all_reads ->
            [ meta, [ all_reads[0], all_reads[1] ],  all_reads[2]]
        }
    UNICYCLER(
        ch_unicycler_input
    )
    ch_genome = UNICYCLER.out.scaffolds

    emit:
    genome              = ch_genome
    multiqc_files       = ch_multiqc_files

}