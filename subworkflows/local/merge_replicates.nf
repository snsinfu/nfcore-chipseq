include { PICARD_MERGESAMFILES } from '../../modules/nf-core/picard/mergesamfiles/main'
include { SAMTOOLS_INDEX       } from '../../modules/nf-core/samtools/index/main'
include { BAM_STATS_SAMTOOLS   } from '../nf-core/bam_stats_samtools/main'

workflow MERGE_REPLICATES {
    take:
    ch_bam   // channel: [ val(meta), [ bam ] ]
    ch_fasta // channel: [ val(meta), path(fasta) ]

    main:
    ch_versions = Channel.empty()

    // Group biological replicates by stripping _REP\d from meta.id
    ch_bam
        .map { meta, bam ->
            def base_id = meta.id.replaceAll(/_REP\d+$/, "")
            [ base_id, meta, bam ]
        }
        .groupTuple(by: 0)
        .filter { base_id, meta, bam -> bam.size() > 1 }
        .map { base_id, meta, bam ->
            def meta_clone = meta[0].clone()
            meta_clone.id = base_id + "_MERGED"

            if (meta_clone.control) {
                def unique_controls = meta.collect { it.control }.unique()
                if (unique_controls.size() == 1) {
                    // All IPs point to the exact same input replicate. Point to the singleton.
                    meta_clone.control = unique_controls[0]
                } else {
                    // IPs point to different input replicates. The inputs will be merged.
                    def base_control = unique_controls[0].replaceAll(/_REP\d+$/, "")
                    meta_clone.control = base_control + "_MERGED"
                }
            }
            [ meta_clone, bam ]
        }
        .set { ch_merge_input }

    // Merge and index BAMs
    PICARD_MERGESAMFILES ( ch_merge_input )
    ch_versions = ch_versions.mix(PICARD_MERGESAMFILES.out.versions.first())

    SAMTOOLS_INDEX ( PICARD_MERGESAMFILES.out.bam )
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())

    // Generate QC Stats
    PICARD_MERGESAMFILES.out.bam
        .join(SAMTOOLS_INDEX.out.bai, by: [0])
        .set { ch_merge_bam_bai }

    BAM_STATS_SAMTOOLS ( ch_merge_bam_bai, ch_fasta )
    ch_versions = ch_versions.mix(BAM_STATS_SAMTOOLS.out.versions)

    emit:
    bam      = PICARD_MERGESAMFILES.out.bam    // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]

    stats    = BAM_STATS_SAMTOOLS.out.stats    // channel: [ val(meta), [ stats ] ]
    flagstat = BAM_STATS_SAMTOOLS.out.flagstat // channel: [ val(meta), [ flagstat ] ]
    idxstats = BAM_STATS_SAMTOOLS.out.idxstats // channel: [ val(meta), [ idxstats ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}
