/*
 * Map reads with bwa-mem3, sort, index BAM file and run samtools stats, flagstat and idxstats
 */

include { BWAMEM3_MEM              } from '../../modules/local/bwamem3_mem'
include { BAM_SORT_STATS_SAMTOOLS } from '../nf-core/bam_sort_stats_samtools/main'

workflow ALIGN_BWAMEM3 {
    take:
    ch_reads   // channel: [ val(meta), [ reads ] ]
    ch_index   // channel: /path/to/bwamem3/index/
    ch_fasta   // channel: /path/to/fasta

    main:
    ch_versions = Channel.empty()

    //
    // Map reads with bwa-mem3
    //
    BWAMEM3_MEM ( ch_reads, ch_index, ch_fasta, false )
    ch_versions = ch_versions.mix(BWAMEM3_MEM.out.versions.first())

    //
    // Sort, index BAM file and run samtools stats, flagstat and idxstats
    //
    BAM_SORT_STATS_SAMTOOLS ( BWAMEM3_MEM.out.bam, ch_fasta )
    ch_versions = ch_versions.mix(BAM_SORT_STATS_SAMTOOLS.out.versions)

    emit:
    bam_orig = BWAMEM3_MEM.out.bam                 // channel: [ val(meta), bam      ]

    bam      = BAM_SORT_STATS_SAMTOOLS.out.bam     // channel: [ val(meta), [ bam ] ]
    bai      = BAM_SORT_STATS_SAMTOOLS.out.bai     // channel: [ val(meta), [ bai ] ]
    csi      = BAM_SORT_STATS_SAMTOOLS.out.csi     // channel: [ val(meta), [ csi ] ]
    stats    = BAM_SORT_STATS_SAMTOOLS.out.stats   // channel: [ val(meta), [ stats ] ]
    flagstat = BAM_SORT_STATS_SAMTOOLS.out.flagstat // channel: [ val(meta), [ flagstat ] ]
    idxstats = BAM_SORT_STATS_SAMTOOLS.out.idxstats // channel: [ val(meta), [ idxstats ] ]

    versions = ch_versions                          // channel: [ versions.yml ]
}
