/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Loaded from modules/local/
//
include { IGV                                 } from '../modules/local/igv'
include { MULTIQC                             } from '../modules/local/multiqc'
include { MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS as MERGED_LIBRARY_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS   } from '../modules/local/multiqc_custom_phantompeakqualtools'
include { MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS as MERGED_REPLICATE_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS } from '../modules/local/multiqc_custom_phantompeakqualtools'

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_chipseq_pipeline'
include { INPUT_CHECK            } from '../subworkflows/local/input_check'
include { ALIGN_STAR             } from '../subworkflows/local/align_star'
include { BAM_FILTER_BAMTOOLS as MERGED_LIBRARY_FILTER_BAM                    } from '../subworkflows/local/bam_filter_bamtools'
include { BAM_BEDGRAPH_BIGWIG_BEDTOOLS_UCSC as MERGED_LIBRARY_BAM_TO_BIGWIG   } from '../subworkflows/local/bam_bedgraph_bigwig_bedtools_ucsc'
include { BAM_BEDGRAPH_BIGWIG_BEDTOOLS_UCSC as MERGED_REPLICATE_BAM_TO_BIGWIG } from '../subworkflows/local/bam_bedgraph_bigwig_bedtools_ucsc'
include { BAM_PEAKS_CALL_QC_ANNOTATE_MACS3_HOMER as MERGED_LIBRARY_CALL_ANNOTATE_PEAKS   } from '../subworkflows/local/bam_peaks_call_qc_annotate_macs3_homer.nf'
include { BAM_PEAKS_CALL_QC_ANNOTATE_MACS3_HOMER as MERGED_REPLICATE_CALL_ANNOTATE_PEAKS } from '../subworkflows/local/bam_peaks_call_qc_annotate_macs3_homer.nf'
include { BED_CONSENSUS_QUANTIFY_QC_BEDTOOLS_FEATURECOUNTS_DESEQ2 as MERGED_LIBRARY_CONSENSUS_PEAKS   } from '../subworkflows/local/bed_consensus_quantify_qc_bedtools_featurecounts_deseq2.nf'
include { BED_CONSENSUS_QUANTIFY_QC_BEDTOOLS_FEATURECOUNTS_DESEQ2 as MERGED_REPLICATE_CONSENSUS_PEAKS } from '../subworkflows/local/bed_consensus_quantify_qc_bedtools_featurecounts_deseq2.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//

include { PICARD_MERGESAMFILES as PICARD_MERGESAMFILES_LIBRARY   } from '../modules/nf-core/picard/mergesamfiles/main'
include { PICARD_MERGESAMFILES as PICARD_MERGESAMFILES_REPLICATE } from '../modules/nf-core/picard/mergesamfiles/main'
include { PICARD_COLLECTMULTIPLEMETRICS as MERGED_LIBRARY_PICARD_COLLECTMULTIPLEMETRICS   } from '../modules/nf-core/picard/collectmultiplemetrics/main'
include { PICARD_COLLECTMULTIPLEMETRICS as MERGED_REPLICATE_PICARD_COLLECTMULTIPLEMETRICS } from '../modules/nf-core/picard/collectmultiplemetrics/main'
include { PRESEQ_LCEXTRAP               } from '../modules/nf-core/preseq/lcextrap/main'
include { PHANTOMPEAKQUALTOOLS as MERGED_LIBRARY_PHANTOMPEAKQUALTOOLS   } from '../modules/nf-core/phantompeakqualtools/main'
include { PHANTOMPEAKQUALTOOLS as MERGED_REPLICATE_PHANTOMPEAKQUALTOOLS } from '../modules/nf-core/phantompeakqualtools/main'
include { DEEPTOOLS_COMPUTEMATRIX as MERGED_LIBRARY_DEEPTOOLS_COMPUTEMATRIX   } from '../modules/nf-core/deeptools/computematrix/main'
include { DEEPTOOLS_COMPUTEMATRIX as MERGED_REPLICATE_DEEPTOOLS_COMPUTEMATRIX } from '../modules/nf-core/deeptools/computematrix/main'
include { DEEPTOOLS_PLOTPROFILE as MERGED_LIBRARY_DEEPTOOLS_PLOTPROFILE   } from '../modules/nf-core/deeptools/plotprofile/main'
include { DEEPTOOLS_PLOTPROFILE as MERGED_REPLICATE_DEEPTOOLS_PLOTPROFILE } from '../modules/nf-core/deeptools/plotprofile/main'
include { DEEPTOOLS_PLOTHEATMAP as MERGED_LIBRARY_DEEPTOOLS_PLOTHEATMAP   } from '../modules/nf-core/deeptools/plotheatmap/main'
include { DEEPTOOLS_PLOTHEATMAP as MERGED_REPLICATE_DEEPTOOLS_PLOTHEATMAP } from '../modules/nf-core/deeptools/plotheatmap/main'
include { DEEPTOOLS_PLOTFINGERPRINT as MERGED_LIBRARY_DEEPTOOLS_PLOTFINGERPRINT   } from '../modules/nf-core/deeptools/plotfingerprint/main'
include { DEEPTOOLS_PLOTFINGERPRINT as MERGED_REPLICATE_DEEPTOOLS_PLOTFINGERPRINT } from '../modules/nf-core/deeptools/plotfingerprint/main'
include { KHMER_UNIQUEKMERS             } from '../modules/nf-core/khmer/uniquekmers/main'

//
// SUBWORKFLOW: Consisting entirely of nf-core/modules
//

include { FASTQ_FASTQC_UMITOOLS_TRIMGALORE } from '../subworkflows/nf-core/fastq_fastqc_umitools_trimgalore/main'
include { FASTQ_ALIGN_BWA                  } from '../subworkflows/nf-core/fastq_align_bwa/main'
include { FASTQ_ALIGN_BOWTIE2              } from '../subworkflows/nf-core/fastq_align_bowtie2/main'
include { FASTQ_ALIGN_CHROMAP              } from '../subworkflows/nf-core/fastq_align_chromap/main'
include { BAM_MARKDUPLICATES_PICARD as MERGED_LIBRARY_MARKDUPLICATES_PICARD   } from '../subworkflows/nf-core/bam_markduplicates_picard/main'
include { BAM_MARKDUPLICATES_PICARD as MERGED_REPLICATE_MARKDUPLICATES_PICARD } from '../subworkflows/nf-core/bam_markduplicates_picard/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// JSON files required by BAMTools for alignment filtering
ch_bamtools_filter_se_config = file(params.bamtools_filter_se_config)
ch_bamtools_filter_pe_config = file(params.bamtools_filter_pe_config)

// Header files for MultiQC
ch_spp_nsc_header                  = file("$projectDir/assets/multiqc/merged_library_spp_nsc_header.txt", checkIfExists: true)
ch_spp_rsc_header                  = file("$projectDir/assets/multiqc/merged_library_spp_rsc_header.txt", checkIfExists: true)
ch_spp_correlation_header          = file("$projectDir/assets/multiqc/merged_library_spp_correlation_header.txt", checkIfExists: true)
ch_peak_count_header               = file("$projectDir/assets/multiqc/merged_library_peak_count_header.txt", checkIfExists: true)
ch_frip_score_header               = file("$projectDir/assets/multiqc/merged_library_frip_score_header.txt", checkIfExists: true)
ch_peak_annotation_header          = file("$projectDir/assets/multiqc/merged_library_peak_annotation_header.txt", checkIfExists: true)
ch_deseq2_pca_header               = Channel.value(file("$projectDir/assets/multiqc/merged_library_deseq2_pca_header.txt", checkIfExists: true))
ch_deseq2_clustering_header        = Channel.value(file("$projectDir/assets/multiqc/merged_library_deseq2_clustering_header.txt", checkIfExists: true))

ch_spp_nsc_header_replicate        = file("$projectDir/assets/multiqc/merged_replicate_spp_nsc_header.txt", checkIfExists: true)
ch_spp_rsc_header_replicate        = file("$projectDir/assets/multiqc/merged_replicate_spp_rsc_header.txt", checkIfExists: true)
ch_spp_correlation_header_replicate = file("$projectDir/assets/multiqc/merged_replicate_spp_correlation_header.txt", checkIfExists: true)
ch_peak_count_header_replicate     = file("$projectDir/assets/multiqc/merged_replicate_peak_count_header.txt", checkIfExists: true)
ch_frip_score_header_replicate     = file("$projectDir/assets/multiqc/merged_replicate_frip_score_header.txt", checkIfExists: true)
ch_peak_annotation_header_replicate = file("$projectDir/assets/multiqc/merged_replicate_peak_annotation_header.txt", checkIfExists: true)
ch_deseq2_pca_header_replicate     = Channel.value(file("$projectDir/assets/multiqc/merged_replicate_deseq2_pca_header.txt", checkIfExists: true))
ch_deseq2_clustering_header_replicate = Channel.value(file("$projectDir/assets/multiqc/merged_replicate_deseq2_clustering_header.txt", checkIfExists: true))

// Save AWS IGenomes file containing annotation version
def anno_readme = params.genomes[ params.genome ]?.readme
if (anno_readme && file(anno_readme).exists()) {
    file("${params.outdir}/genome/").mkdirs()
    file(anno_readme).copyTo("${params.outdir}/genome/")
}


// // Info required for completion email and summary
// def multiqc_report = []

workflow CHIPSEQ {

    take:
    ch_samplesheet   // channel: path(sample_sheet.csv)
    ch_versions      // channel: [ path(versions.yml) ]
    ch_fasta         // channel: path(genome.fa)
    ch_fai           // channel: path(genome.fai)
    ch_gtf           // channel: path(genome.gtf)
    ch_gene_bed      // channel: path(gene.beds)
    ch_chrom_sizes   // channel: path(chrom.sizes)
    ch_filtered_bed  // channel: path(filtered.bed)
    ch_bwa_index     // channel: path(bwa/index/)
    ch_bowtie2_index // channel: path(bowtie2/index)
    ch_chromap_index // channel: path(chromap.index)
    ch_star_index    // channel: path(star/index/)

    main:
    ch_multiqc_files = channel.empty()
    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        ch_samplesheet,
        params.seq_center
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    // TODO: OPTIONAL, you can use nf-validation plugin to create an input channel from the samplesheet with Channel.fromSamplesheet("input")
    // See the documentation https://nextflow-io.github.io/nf-validation/samplesheets/fromSamplesheet/
    // ! There is currently no tooling to help you write a sample sheet schema

    //
    // SUBWORKFLOW: Read QC and trim adapters
    //
    FASTQ_FASTQC_UMITOOLS_TRIMGALORE (
        INPUT_CHECK.out.reads,
        params.skip_fastqc || params.skip_qc,
        false,
        false,
        params.skip_trimming,
        0,
        10000
    )
    ch_versions = ch_versions.mix(FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.versions)

    //
    // SUBWORKFLOW: Alignment with BWA & BAM QC
    //
    ch_genome_bam        = Channel.empty()
    ch_genome_bam_index  = Channel.empty()
    ch_samtools_stats    = Channel.empty()
    ch_samtools_flagstat = Channel.empty()
    ch_samtools_idxstats = Channel.empty()
    if (params.aligner == 'bwa') {
        FASTQ_ALIGN_BWA (
            FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.reads,
            ch_bwa_index,
            false,
            ch_fasta
                .map {
                    [ [:], it ]
                }
        )
        ch_genome_bam        = FASTQ_ALIGN_BWA.out.bam
        ch_genome_bam_index  = FASTQ_ALIGN_BWA.out.bai
        ch_samtools_stats    = FASTQ_ALIGN_BWA.out.stats
        ch_samtools_flagstat = FASTQ_ALIGN_BWA.out.flagstat
        ch_samtools_idxstats = FASTQ_ALIGN_BWA.out.idxstats
        ch_versions = ch_versions.mix(FASTQ_ALIGN_BWA.out.versions)
    }

    //
    // SUBWORKFLOW: Alignment with Bowtie2 & BAM QC
    //
    if (params.aligner == 'bowtie2') {
        FASTQ_ALIGN_BOWTIE2 (
            FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.reads,
            ch_bowtie2_index,
            params.save_unaligned,
            false,
            ch_fasta
                .map {
                    [ [:], it ]
                }
        )
        ch_genome_bam        = FASTQ_ALIGN_BOWTIE2.out.bam
        ch_genome_bam_index  = FASTQ_ALIGN_BOWTIE2.out.bai
        ch_samtools_stats    = FASTQ_ALIGN_BOWTIE2.out.stats
        ch_samtools_flagstat = FASTQ_ALIGN_BOWTIE2.out.flagstat
        ch_samtools_idxstats = FASTQ_ALIGN_BOWTIE2.out.idxstats
        ch_versions = ch_versions.mix(FASTQ_ALIGN_BOWTIE2.out.versions)
    }

    //
    // SUBWORKFLOW: Alignment with Chromap & BAM QC
    //
    if (params.aligner == 'chromap') {
        FASTQ_ALIGN_CHROMAP (
            FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.reads,
            ch_chromap_index,
            ch_fasta
                .map {
                    [ [:], it ]
                },
            [],
            [],
            [],
            []
        )
        ch_genome_bam        = FASTQ_ALIGN_CHROMAP.out.bam
        ch_genome_bam_index  = FASTQ_ALIGN_CHROMAP.out.bai
        ch_samtools_stats    = FASTQ_ALIGN_CHROMAP.out.stats
        ch_samtools_flagstat = FASTQ_ALIGN_CHROMAP.out.flagstat
        ch_samtools_idxstats = FASTQ_ALIGN_CHROMAP.out.idxstats
        ch_versions = ch_versions.mix(FASTQ_ALIGN_CHROMAP.out.versions)
    }

    //
    // SUBWORKFLOW: Alignment with STAR & BAM QC
    //
    if (params.aligner == 'star') {
        ALIGN_STAR (
            FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.reads,
            ch_star_index,
            ch_fasta
                .map {
                        [ [:], it ]
                },
            params.seq_center ?: ''
        )
        ch_genome_bam        = ALIGN_STAR.out.bam
        ch_genome_bam_index  = ALIGN_STAR.out.bai
        ch_transcriptome_bam = ALIGN_STAR.out.bam_transcript
        ch_samtools_stats    = ALIGN_STAR.out.stats
        ch_samtools_flagstat = ALIGN_STAR.out.flagstat
        ch_samtools_idxstats = ALIGN_STAR.out.idxstats
        ch_star_multiqc      = ALIGN_STAR.out.log_final

        ch_versions = ch_versions.mix(ALIGN_STAR.out.versions)
    }

    //
    // MODULE: Merge resequenced BAM files
    //
    ch_genome_bam
        .map {
            meta, bam ->
                def meta_clone = meta.clone()
                meta_clone.remove('read_group')
                meta_clone.id = meta_clone.id - ~/_T\d+$/
                [ meta_clone, bam ]
        }
        .groupTuple(by: [0])
        .map {
            meta, bam ->
                [ meta, bam.flatten() ]
        }
        .set { ch_sort_bam }

    PICARD_MERGESAMFILES_LIBRARY (
        ch_sort_bam
    )
    ch_versions = ch_versions.mix(PICARD_MERGESAMFILES_LIBRARY.out.versions.first())

    //
    // SUBWORKFLOW: Mark duplicates & filter BAM files after merging
    //
    MERGED_LIBRARY_MARKDUPLICATES_PICARD (
        PICARD_MERGESAMFILES_LIBRARY.out.bam,
        ch_fasta
            .map {
                [ [:], it ]
            },
        ch_fai
            .map {
                [ [:], it ]
            }
    )
    ch_versions = ch_versions.mix(MERGED_LIBRARY_MARKDUPLICATES_PICARD.out.versions)

    //
    // SUBWORKFLOW: Filter BAM file with BamTools
    //
    MERGED_LIBRARY_FILTER_BAM (
        MERGED_LIBRARY_MARKDUPLICATES_PICARD.out.bam.join(MERGED_LIBRARY_MARKDUPLICATES_PICARD.out.bai, by: [0]),
        ch_filtered_bed.first(),
        ch_fasta
            .map {
                [ [:], it ]
            },
        ch_bamtools_filter_se_config,
        ch_bamtools_filter_pe_config
    )
    ch_versions = ch_versions.mix(MERGED_LIBRARY_FILTER_BAM.out.versions)

    // Merged library-level filtered BAM channels used for all downstream analyses
    ch_merged_library_filter_bam      = MERGED_LIBRARY_FILTER_BAM.out.bam
    ch_merged_library_filter_bai      = MERGED_LIBRARY_FILTER_BAM.out.bai
    ch_merged_library_filter_flagstat = MERGED_LIBRARY_FILTER_BAM.out.flagstat
    ch_merged_library_filter_idxstats = MERGED_LIBRARY_FILTER_BAM.out.idxstats
    ch_merged_library_filter_stats    = MERGED_LIBRARY_FILTER_BAM.out.stats

    //
    // MODULE: Preseq coverage analysis
    //
    ch_preseq_multiqc = Channel.empty()
    if (!params.skip_preseq) {
        PRESEQ_LCEXTRAP (
            MERGED_LIBRARY_MARKDUPLICATES_PICARD.out.bam
        )
        ch_preseq_multiqc = PRESEQ_LCEXTRAP.out.lc_extrap
        ch_versions = ch_versions.mix(PRESEQ_LCEXTRAP.out.versions.first())
    }

    //
    // MODULE: Picard post alignment QC
    //
    ch_picardcollectmultiplemetrics_multiqc = Channel.empty()
    if (!params.skip_picard_metrics) {
        MERGED_LIBRARY_PICARD_COLLECTMULTIPLEMETRICS (
            ch_merged_library_filter_bam
                .map {
                    [ it[0], it[1], [] ]
                },
            ch_fasta
                .map {
                    [ [:], it ]
                },
            ch_fai
                .map {
                    [ [:], it ]
                }
        )
        ch_picardcollectmultiplemetrics_multiqc = MERGED_LIBRARY_PICARD_COLLECTMULTIPLEMETRICS.out.metrics
        ch_versions = ch_versions.mix(MERGED_LIBRARY_PICARD_COLLECTMULTIPLEMETRICS.out.versions.first())
    }

    //
    // MODULE: Phantompeaktools strand cross-correlation and QC metrics
    //
    ch_phantompeakqualtools_spp_multiqc                 = Channel.empty()
    ch_multiqc_phantompeakqualtools_nsc_multiqc         = Channel.empty()
    ch_multiqc_phantompeakqualtools_rsc_multiqc         = Channel.empty()
    ch_multiqc_phantompeakqualtools_correlation_multiqc = Channel.empty()
    if (!params.skip_spp) {
        MERGED_LIBRARY_PHANTOMPEAKQUALTOOLS (
            ch_merged_library_filter_bam
        )
        ch_phantompeakqualtools_spp_multiqc           = MERGED_LIBRARY_PHANTOMPEAKQUALTOOLS.out.spp
        ch_versions = ch_versions.mix(MERGED_LIBRARY_PHANTOMPEAKQUALTOOLS.out.versions.first())

        //
        // MODULE: MultiQC custom content for Phantompeaktools
        //
        MERGED_LIBRARY_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS (
            MERGED_LIBRARY_PHANTOMPEAKQUALTOOLS.out.spp.join(MERGED_LIBRARY_PHANTOMPEAKQUALTOOLS.out.rdata, by: [0]),
            ch_spp_nsc_header,
            ch_spp_rsc_header,
            ch_spp_correlation_header
        )
        ch_multiqc_phantompeakqualtools_nsc_multiqc         = MERGED_LIBRARY_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS.out.nsc
        ch_multiqc_phantompeakqualtools_rsc_multiqc         = MERGED_LIBRARY_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS.out.rsc
        ch_multiqc_phantompeakqualtools_correlation_multiqc = MERGED_LIBRARY_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS.out.correlation
    }

    //
    // SUBWORKFLOW: Normalised bigWig coverage tracks
    //
    MERGED_LIBRARY_BAM_TO_BIGWIG (
        ch_merged_library_filter_bam.join(ch_merged_library_filter_flagstat, by: [0]),
        ch_chrom_sizes
    )
    ch_versions = ch_versions.mix(MERGED_LIBRARY_BAM_TO_BIGWIG.out.versions)


    ch_deeptoolsplotprofile_multiqc = Channel.empty()
    if (!params.skip_plot_profile) {
        //
        // MODULE: deepTools matrix generation for plotting
        //
        MERGED_LIBRARY_DEEPTOOLS_COMPUTEMATRIX (
            MERGED_LIBRARY_BAM_TO_BIGWIG.out.bigwig,
            ch_gene_bed
        )
        ch_versions = ch_versions.mix(MERGED_LIBRARY_DEEPTOOLS_COMPUTEMATRIX.out.versions.first())

        //
        // MODULE: deepTools profile plots
        //
        MERGED_LIBRARY_DEEPTOOLS_PLOTPROFILE (
            MERGED_LIBRARY_DEEPTOOLS_COMPUTEMATRIX.out.matrix
        )
        ch_deeptoolsplotprofile_multiqc = MERGED_LIBRARY_DEEPTOOLS_PLOTPROFILE.out.table
        ch_versions = ch_versions.mix(MERGED_LIBRARY_DEEPTOOLS_PLOTPROFILE.out.versions.first())

        //
        // MODULE: deepTools heatmaps
        //
        MERGED_LIBRARY_DEEPTOOLS_PLOTHEATMAP (
            MERGED_LIBRARY_DEEPTOOLS_COMPUTEMATRIX.out.matrix
        )
        ch_versions = ch_versions.mix(MERGED_LIBRARY_DEEPTOOLS_PLOTHEATMAP.out.versions.first())
    }

    //
    // Create channels: [ meta, [ ip_bam, control_bam ] [ ip_bai, control_bai ] ]
    //
    ch_merged_library_filter_bam
        .join(ch_merged_library_filter_bai, by: [0])
        .set { ch_merged_library_bam_bai }

    ch_merged_library_bam_bai
        .map {
            meta, bam, bai ->
                meta.control ? null : [ meta.id, [ bam ] , [ bai ] ]
        }
        .set { ch_merged_library_control_bam_bai }

    ch_merged_library_bam_bai
        .map {
            meta, bam, bai ->
                meta.control ? [ meta.control, meta, [ bam ], [ bai ] ] : null
        }
        .combine(ch_merged_library_control_bam_bai, by: 0)
        .map { it -> [ it[1] , it[2] + it[4], it[3] + it[5] ] }
        .set { ch_merged_library_ip_control_bam_bai }

    //
    // MODULE: deepTools plotFingerprint joint QC for IP and control
    //
    ch_deeptoolsplotfingerprint_multiqc = Channel.empty()
    if (!params.skip_plot_fingerprint) {
        MERGED_LIBRARY_DEEPTOOLS_PLOTFINGERPRINT (
            ch_merged_library_ip_control_bam_bai
        )
        ch_deeptoolsplotfingerprint_multiqc = MERGED_LIBRARY_DEEPTOOLS_PLOTFINGERPRINT.out.matrix
        ch_versions = ch_versions.mix(MERGED_LIBRARY_DEEPTOOLS_PLOTFINGERPRINT.out.versions.first())
    }

    //
    // MODULE: Calculute genome size with khmer
    //
    ch_macs_gsize                     = Channel.empty()
    ch_subreadfeaturecounts_multiqc   = Channel.empty()
    ch_macs_gsize = params.macs_gsize
    if (!params.macs_gsize) {
        KHMER_UNIQUEKMERS (
            ch_fasta,
            params.read_length
        )
        ch_macs_gsize = KHMER_UNIQUEKMERS.out.kmers.map { it.text.trim() }
    }

    // Create channels: [ meta, ip_bam, control_bam ]
    ch_merged_library_ip_control_bam_bai
        .map {
            meta, bams, bais ->
                [ meta , bams[0], bams[1] ]
        }
        .set { ch_merged_library_ip_control_bam }

    //
    // SUBWORKFLOW: Call peaks with MACS3, annotate with HOMER and perform downstream QC
    //
    MERGED_LIBRARY_CALL_ANNOTATE_PEAKS (
        ch_merged_library_ip_control_bam,
        ch_fasta,
        ch_gtf,
        ch_macs_gsize,
        "_peaks.annotatePeaks.txt",
        ch_peak_count_header,
        ch_frip_score_header,
        ch_peak_annotation_header,
        params.narrow_peak,
        params.skip_peak_annotation,
        params.skip_peak_qc
    )
    ch_versions = ch_versions.mix(MERGED_LIBRARY_CALL_ANNOTATE_PEAKS.out.versions)

    //
    //  Consensus peaks analysis
    //
    ch_macs3_consensus_bed_lib   = Channel.empty()
    ch_macs3_consensus_txt_lib   = Channel.empty()
    ch_deseq2_pca_multiqc        = Channel.empty()
    ch_deseq2_clustering_multiqc = Channel.empty()
    if (!params.skip_consensus_peaks) {
        // Create channels: [ antibody, [ ip_bams ], single_end_map ]
        ch_merged_library_ip_control_bam
            .map {
                meta, ip_bam, control_bam ->
                    [ meta.antibody, meta.single_end, ip_bam ]
            }
            .groupTuple()
            .map {
                antibody, single_end, ip_bams ->
                    def single_end_map = single_end.unique().size() == 1 ? [single_end: single_end[0]] : false
                    [ antibody, ip_bams, single_end_map ]
            }
            .set { ch_antibody_bams }

        MERGED_LIBRARY_CONSENSUS_PEAKS (
            MERGED_LIBRARY_CALL_ANNOTATE_PEAKS.out.peaks,
            ch_antibody_bams,
            ch_fasta,
            ch_gtf,
            ch_deseq2_pca_header,
            ch_deseq2_clustering_header,
            params.narrow_peak,
            params.skip_peak_annotation,
            params.skip_deseq2_qc
        )
        ch_macs3_consensus_bed_lib       = MERGED_LIBRARY_CONSENSUS_PEAKS.out.consensus_bed
        ch_macs3_consensus_txt_lib       = MERGED_LIBRARY_CONSENSUS_PEAKS.out.consensus_txt
        ch_subreadfeaturecounts_multiqc  = MERGED_LIBRARY_CONSENSUS_PEAKS.out.featurecounts_summary
        ch_deseq2_pca_multiqc            = MERGED_LIBRARY_CONSENSUS_PEAKS.out.deseq2_qc_pca_multiqc
        ch_deseq2_clustering_multiqc     = MERGED_LIBRARY_CONSENSUS_PEAKS.out.deseq2_qc_dists_multiqc
        ch_versions = ch_versions.mix(MERGED_LIBRARY_CONSENSUS_PEAKS.out.versions)
    }

    //
    // Merged replicate analysis
    //
    ch_markduplicates_replicate_stats                   = Channel.empty()
    ch_markduplicates_replicate_flagstat                = Channel.empty()
    ch_markduplicates_replicate_idxstats                = Channel.empty()
    ch_markduplicates_replicate_metrics                 = Channel.empty()
    ch_picardcollectmultiplemetrics_replicate_multiqc   = Channel.empty()
    ch_phantompeakqualtools_replicate_spp_multiqc       = Channel.empty()
    ch_multiqc_phantompeakqualtools_replicate_nsc_multiqc         = Channel.empty()
    ch_multiqc_phantompeakqualtools_replicate_rsc_multiqc         = Channel.empty()
    ch_multiqc_phantompeakqualtools_replicate_correlation_multiqc = Channel.empty()
    ch_deeptoolsplotprofile_replicate_multiqc           = Channel.empty()
    ch_deeptoolsplotfingerprint_replicate_multiqc       = Channel.empty()
    ch_ucsc_bedgraphtobigwig_replicate_bigwig           = Channel.empty()
    ch_macs3_replicate_peaks                            = Channel.empty()
    ch_macs3_frip_replicate_multiqc                     = Channel.empty()
    ch_macs3_peak_count_replicate_multiqc               = Channel.empty()
    ch_macs3_plot_homer_annotatepeaks_replicate_multiqc = Channel.empty()
    ch_macs3_consensus_replicate_bed                    = Channel.empty()
    ch_macs3_consensus_replicate_txt                    = Channel.empty()
    ch_featurecounts_replicate_multiqc                  = Channel.empty()
    ch_deseq2_pca_replicate_multiqc                     = Channel.empty()
    ch_deseq2_clustering_replicate_multiqc              = Channel.empty()
    if (!params.skip_merge_replicates) {

        //
        // Check if we have multiple biological replicates and group them
        //
        ch_merged_library_filter_bam
            .map {
                meta, bam ->
                    [ meta.id - ~/_REP\d+$/, meta, bam ]
            }
            .groupTuple(by: 0)
            .filter {
                base_id, metas, bams ->
                    bams.size() > 1
            }
            .map {
                base_id, metas, bams ->
                    def meta_clone = metas[0].clone()
                    meta_clone.id = base_id

                    if (meta_clone.control) {
                        def unique_controls = metas.collect { it.control }.unique()
                        def unique_base_controls = unique_controls.collect { it.replaceAll(/_REP\d+$/, "") }.unique()
                        if (unique_base_controls.size() > 1) {
                            error("Replicates of sample '${base_id}' reference different control samples (${unique_base_controls.join(', ')}). All replicates of a sample must use the same control sample.")
                        }
                        if (unique_controls.size() == 1) {
                            // All IPs point to the exact same control replicate. Point to the singleton.
                            meta_clone.control = unique_controls[0]
                        } else {
                            // IPs point to different control replicates. The controls will be merged.
                            meta_clone.control = unique_base_controls[0]
                        }
                    }
                    [ meta_clone, bams.flatten() ]
            }
            .set { ch_merged_replicate_bam }

        //
        // MODULE: Merge replicate BAM files
        //
        PICARD_MERGESAMFILES_REPLICATE (
            ch_merged_replicate_bam
        )
        ch_versions = ch_versions.mix(PICARD_MERGESAMFILES_REPLICATE.out.versions.first())

        //
        // SUBWORKFLOW: Mark duplicates & run samtools stats on merged replicate BAMs
        //
        MERGED_REPLICATE_MARKDUPLICATES_PICARD (
            PICARD_MERGESAMFILES_REPLICATE.out.bam,
            ch_fasta
                .map {
                    [ [:], it ]
                },
            ch_fai
                .map {
                    [ [:], it ]
                }
        )
        ch_markduplicates_replicate_stats    = MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.stats
        ch_markduplicates_replicate_flagstat = MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.flagstat
        ch_markduplicates_replicate_idxstats = MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.idxstats
        ch_markduplicates_replicate_metrics  = MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.metrics
        ch_versions = ch_versions.mix(MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.versions)

        // Final merged replicate markduplicate BAM/index channels
        ch_merged_replicate_markdup_bam = MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.bam
        ch_merged_replicate_bam_bai = ch_merged_replicate_markdup_bam.join(MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.bai, by: [0])

        //
        // MODULE: Picard post alignment QC
        //
        if (!params.skip_picard_metrics) {
            MERGED_REPLICATE_PICARD_COLLECTMULTIPLEMETRICS (
                ch_merged_replicate_markdup_bam
                    .map {
                        [ it[0], it[1], [] ]
                    },
                ch_fasta
                    .map {
                        [ [:], it ]
                    },
                ch_fai
                    .map {
                        [ [:], it ]
                    }
            )
            ch_picardcollectmultiplemetrics_replicate_multiqc = MERGED_REPLICATE_PICARD_COLLECTMULTIPLEMETRICS.out.metrics
            ch_versions = ch_versions.mix(MERGED_REPLICATE_PICARD_COLLECTMULTIPLEMETRICS.out.versions.first())
        }

        //
        // MODULE: Phantompeaktools strand cross-correlation and QC metrics
        //
        if (!params.skip_spp) {
            MERGED_REPLICATE_PHANTOMPEAKQUALTOOLS (
                ch_merged_replicate_markdup_bam
            )
            ch_phantompeakqualtools_replicate_spp_multiqc = MERGED_REPLICATE_PHANTOMPEAKQUALTOOLS.out.spp
            ch_versions = ch_versions.mix(MERGED_REPLICATE_PHANTOMPEAKQUALTOOLS.out.versions.first())

            //
            // MODULE: MultiQC custom content for Phantompeaktools
            //
            MERGED_REPLICATE_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS (
                MERGED_REPLICATE_PHANTOMPEAKQUALTOOLS.out.spp.join(MERGED_REPLICATE_PHANTOMPEAKQUALTOOLS.out.rdata, by: [0]),
                ch_spp_nsc_header_replicate,
                ch_spp_rsc_header_replicate,
                ch_spp_correlation_header_replicate
            )
            ch_multiqc_phantompeakqualtools_replicate_nsc_multiqc         = MERGED_REPLICATE_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS.out.nsc
            ch_multiqc_phantompeakqualtools_replicate_rsc_multiqc         = MERGED_REPLICATE_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS.out.rsc
            ch_multiqc_phantompeakqualtools_replicate_correlation_multiqc = MERGED_REPLICATE_MULTIQC_CUSTOM_PHANTOMPEAKQUALTOOLS.out.correlation
        }

        //
        // SUBWORKFLOW: Normalised bigWig coverage tracks
        //
        if (!params.skip_merged_replicate_bigwig) {
            MERGED_REPLICATE_BAM_TO_BIGWIG (
                ch_merged_replicate_markdup_bam.join(MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.flagstat, by: [0]),
                ch_chrom_sizes
            )
            ch_ucsc_bedgraphtobigwig_replicate_bigwig = MERGED_REPLICATE_BAM_TO_BIGWIG.out.bigwig
            ch_versions = ch_versions.mix(MERGED_REPLICATE_BAM_TO_BIGWIG.out.versions)
        }

        //
        // MODULE: deepTools matrix generation and profile/heatmap plots
        //
        if (!params.skip_plot_profile && !params.skip_merged_replicate_bigwig) {
            MERGED_REPLICATE_DEEPTOOLS_COMPUTEMATRIX (
                ch_ucsc_bedgraphtobigwig_replicate_bigwig,
                ch_gene_bed
            )
            ch_versions = ch_versions.mix(MERGED_REPLICATE_DEEPTOOLS_COMPUTEMATRIX.out.versions.first())

            MERGED_REPLICATE_DEEPTOOLS_PLOTPROFILE (
                MERGED_REPLICATE_DEEPTOOLS_COMPUTEMATRIX.out.matrix
            )
            ch_deeptoolsplotprofile_replicate_multiqc = MERGED_REPLICATE_DEEPTOOLS_PLOTPROFILE.out.table
            ch_versions = ch_versions.mix(MERGED_REPLICATE_DEEPTOOLS_PLOTPROFILE.out.versions.first())

            MERGED_REPLICATE_DEEPTOOLS_PLOTHEATMAP (
                MERGED_REPLICATE_DEEPTOOLS_COMPUTEMATRIX.out.matrix
            )
            ch_versions = ch_versions.mix(MERGED_REPLICATE_DEEPTOOLS_PLOTHEATMAP.out.versions.first())
        }

        //
        // Create channels: [ meta, [ ip_bam, control_bam ], [ ip_bai, control_bai ] ]
        // Control pool contains merged replicate and individual merged-library BAMs
        //
        ch_merged_replicate_markdup_bam
            .mix(ch_merged_library_filter_bam)
            .filter { meta, bam -> !meta.control }
            .map { meta, bam -> [ meta.id, bam ] }
            .set { ch_replicate_control_bam }

        ch_merged_replicate_markdup_bam
            .filter { meta, bam -> meta.control ? true : false }
            .map { meta, bam -> [ meta.control, meta, bam ] }
            .combine(ch_replicate_control_bam, by: 0)
            .map { it -> [ it[1], it[2], it[3] ] }
            .set { ch_bam_replicate }

        ch_merged_replicate_markdup_bam
            .join(MERGED_REPLICATE_MARKDUPLICATES_PICARD.out.bai, by: [0])
            .mix(ch_merged_library_filter_bam.join(ch_merged_library_filter_bai, by: [0]))
            .map {
                meta, bam, bai ->
                    meta.control ? null : [ meta.id, [ bam ], [ bai ] ]
            }
            .set { ch_replicate_control_bam_bai }

        ch_merged_replicate_bam_bai
            .map {
                meta, bam, bai ->
                    meta.control ? [ meta.control, meta, [ bam ], [ bai ] ] : null
            }
            .combine(ch_replicate_control_bam_bai, by: 0)
            .map { it -> [ it[1], it[2] + it[4], it[3] + it[5] ] }
            .set { ch_replicate_ip_control_bam_bai }

        //
        // MODULE: deepTools plotFingerprint joint QC for IP and control
        //
        if (!params.skip_plot_fingerprint) {
            MERGED_REPLICATE_DEEPTOOLS_PLOTFINGERPRINT (
                ch_replicate_ip_control_bam_bai
            )
            ch_deeptoolsplotfingerprint_replicate_multiqc = MERGED_REPLICATE_DEEPTOOLS_PLOTFINGERPRINT.out.matrix
            ch_versions = ch_versions.mix(MERGED_REPLICATE_DEEPTOOLS_PLOTFINGERPRINT.out.versions.first())
        }

        //
        // SUBWORKFLOW: Call peaks with MACS3, annotate with HOMER and perform downstream QC
        //
        MERGED_REPLICATE_CALL_ANNOTATE_PEAKS (
            ch_bam_replicate,
            ch_fasta,
            ch_gtf,
            ch_macs_gsize,
            ".mRp.clN_peaks.annotatePeaks.txt",
            ch_peak_count_header_replicate,
            ch_frip_score_header_replicate,
            ch_peak_annotation_header_replicate,
            params.narrow_peak,
            params.skip_peak_annotation,
            params.skip_peak_qc
        )
        ch_macs3_replicate_peaks                            = MERGED_REPLICATE_CALL_ANNOTATE_PEAKS.out.peaks
        ch_macs3_frip_replicate_multiqc                     = MERGED_REPLICATE_CALL_ANNOTATE_PEAKS.out.frip_multiqc
        ch_macs3_peak_count_replicate_multiqc               = MERGED_REPLICATE_CALL_ANNOTATE_PEAKS.out.peak_count_multiqc
        ch_macs3_plot_homer_annotatepeaks_replicate_multiqc = MERGED_REPLICATE_CALL_ANNOTATE_PEAKS.out.plot_homer_annotatepeaks_tsv
        ch_versions = ch_versions.mix(MERGED_REPLICATE_CALL_ANNOTATE_PEAKS.out.versions)

        //
        // Create channel: [ antibody, [ ip_bams ], single_end_map ] for the
        // merged-replicate consensus quantification. Only the individual library
        // alignments of the eligible multi-replicate groups are used so that
        // singleton groups are not counted.
        //
        ch_merged_replicate_bam
            .filter { meta, bams -> meta.control }
            .map { meta, bams -> [ meta.antibody, meta.single_end, bams ] }
            .groupTuple()
            .map {
                antibody, single_end, bams ->
                    def single_end_map = single_end.unique().size() == 1 ? [single_end: single_end[0]] : false
                    [ antibody, bams.flatten(), single_end_map ]
            }
            .set { ch_merged_replicate_antibody_bams }

        //
        // SUBWORKFLOW: Consensus peaks analysis
        //
        if (!params.skip_consensus_peaks) {
            MERGED_REPLICATE_CONSENSUS_PEAKS (
                MERGED_REPLICATE_CALL_ANNOTATE_PEAKS.out.peaks,
                ch_merged_replicate_antibody_bams,
                ch_fasta,
                ch_gtf,
                ch_deseq2_pca_header_replicate,
                ch_deseq2_clustering_header_replicate,
                params.narrow_peak,
                params.skip_peak_annotation,
                params.skip_deseq2_qc
            )
            ch_macs3_consensus_replicate_bed       = MERGED_REPLICATE_CONSENSUS_PEAKS.out.consensus_bed
            ch_macs3_consensus_replicate_txt       = MERGED_REPLICATE_CONSENSUS_PEAKS.out.consensus_txt
            ch_featurecounts_replicate_multiqc     = MERGED_REPLICATE_CONSENSUS_PEAKS.out.featurecounts_summary
            ch_deseq2_pca_replicate_multiqc        = MERGED_REPLICATE_CONSENSUS_PEAKS.out.deseq2_qc_pca_multiqc
            ch_deseq2_clustering_replicate_multiqc = MERGED_REPLICATE_CONSENSUS_PEAKS.out.deseq2_qc_dists_multiqc
            ch_versions = ch_versions.mix(MERGED_REPLICATE_CONSENSUS_PEAKS.out.versions)
        }
    }

    //
    // MODULE: Create IGV session
    //
    if (!params.skip_igv) {
        IGV (
            params.aligner,
            params.narrow_peak ? 'narrow_peak' : 'broad_peak',
            ch_fasta,
            MERGED_LIBRARY_BAM_TO_BIGWIG.out.bigwig.collect{it[1]}.ifEmpty([]),
            ch_ucsc_bedgraphtobigwig_replicate_bigwig.collect{it[1]}.ifEmpty([]),
            MERGED_LIBRARY_CALL_ANNOTATE_PEAKS.out.peaks.collect{it[1]}.ifEmpty([]),
            ch_macs3_replicate_peaks.collect{it[1]}.ifEmpty([]),
            ch_macs3_consensus_bed_lib.collect{it[1]}.ifEmpty([]),
            ch_macs3_consensus_replicate_bed.collect{it[1]}.ifEmpty([]),
            ch_macs3_consensus_txt_lib.collect{it[1]}.ifEmpty([]),
            ch_macs3_consensus_replicate_txt.collect{it[1]}.ifEmpty([])
        )
        ch_versions = ch_versions.mix(IGV.out.versions)
    }

    //
    // Collate and save software versions
    //
    def topic_versions = Channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'chipseq_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    //
    // MODULE: MultiQC
    //
    ch_multiqc_report = Channel.empty()

    if (!params.skip_multiqc) {
        ch_multiqc_config        = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
        ch_multiqc_custom_config = params.multiqc_config ? Channel.fromPath( params.multiqc_config ): Channel.empty()
        ch_multiqc_logo          = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo )  : Channel.empty()
        summary_params           = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
        ch_workflow_summary      = Channel.value(paramsSummaryMultiqc(summary_params))
        ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
        ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)

        MULTIQC (
            ch_multiqc_files.collect(),
            ch_multiqc_config.toList(),
            ch_multiqc_custom_config.toList(),
            ch_multiqc_logo.toList(),

            FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.fastqc_zip.collect{it[1]}.ifEmpty([]),
            FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.trim_zip.collect{it[1]}.ifEmpty([]),
            FASTQ_FASTQC_UMITOOLS_TRIMGALORE.out.trim_log.collect{it[1]}.ifEmpty([]),

            ch_samtools_stats.collect{it[1]}.ifEmpty([]),
            ch_samtools_flagstat.collect{it[1]}.ifEmpty([]),
            ch_samtools_idxstats.collect{it[1]}.ifEmpty([]),

            MERGED_LIBRARY_MARKDUPLICATES_PICARD.out.stats.collect{it[1]}.ifEmpty([]),
            MERGED_LIBRARY_MARKDUPLICATES_PICARD.out.flagstat.collect{it[1]}.ifEmpty([]),
            MERGED_LIBRARY_MARKDUPLICATES_PICARD.out.idxstats.collect{it[1]}.ifEmpty([]),
            MERGED_LIBRARY_MARKDUPLICATES_PICARD.out.metrics.collect{it[1]}.ifEmpty([]),

            ch_merged_library_filter_stats.collect{it[1]}.ifEmpty([]),
            ch_merged_library_filter_flagstat.collect{it[1]}.ifEmpty([]),
            ch_merged_library_filter_idxstats.collect{it[1]}.ifEmpty([]),
            ch_picardcollectmultiplemetrics_multiqc.collect{it[1]}.ifEmpty([]),

            ch_preseq_multiqc.collect{it[1]}.ifEmpty([]),

            ch_deeptoolsplotprofile_multiqc.collect{it[1]}.ifEmpty([]),
            ch_deeptoolsplotfingerprint_multiqc.collect{it[1]}.ifEmpty([]),

            ch_phantompeakqualtools_spp_multiqc.collect{it[1]}.ifEmpty([]),
            ch_multiqc_phantompeakqualtools_nsc_multiqc.collect{it[1]}.ifEmpty([]),
            ch_multiqc_phantompeakqualtools_rsc_multiqc.collect{it[1]}.ifEmpty([]),
            ch_multiqc_phantompeakqualtools_correlation_multiqc.collect{it[1]}.ifEmpty([]),

            MERGED_LIBRARY_CALL_ANNOTATE_PEAKS.out.frip_multiqc.collect{it[1]}.ifEmpty([]),
            MERGED_LIBRARY_CALL_ANNOTATE_PEAKS.out.peak_count_multiqc.collect{it[1]}.ifEmpty([]),
            MERGED_LIBRARY_CALL_ANNOTATE_PEAKS.out.plot_homer_annotatepeaks_tsv.collect().ifEmpty([]),
            ch_subreadfeaturecounts_multiqc.collect{it[1]}.ifEmpty([]),

            ch_deseq2_pca_multiqc.collect().ifEmpty([]),
            ch_deseq2_clustering_multiqc.collect().ifEmpty([]),

            ch_markduplicates_replicate_stats.collect{it[1]}.ifEmpty([]),
            ch_markduplicates_replicate_flagstat.collect{it[1]}.ifEmpty([]),
            ch_markduplicates_replicate_idxstats.collect{it[1]}.ifEmpty([]),
            ch_markduplicates_replicate_metrics.collect{it[1]}.ifEmpty([]),
            ch_picardcollectmultiplemetrics_replicate_multiqc.collect{it[1]}.ifEmpty([]),

            ch_deeptoolsplotprofile_replicate_multiqc.collect{it[1]}.ifEmpty([]),
            ch_deeptoolsplotfingerprint_replicate_multiqc.collect{it[1]}.ifEmpty([]),

            ch_phantompeakqualtools_replicate_spp_multiqc.collect{it[1]}.ifEmpty([]),
            ch_multiqc_phantompeakqualtools_replicate_nsc_multiqc.collect{it[1]}.ifEmpty([]),
            ch_multiqc_phantompeakqualtools_replicate_rsc_multiqc.collect{it[1]}.ifEmpty([]),
            ch_multiqc_phantompeakqualtools_replicate_correlation_multiqc.collect{it[1]}.ifEmpty([]),

            ch_macs3_frip_replicate_multiqc.collect{it[1]}.ifEmpty([]),
            ch_macs3_peak_count_replicate_multiqc.collect{it[1]}.ifEmpty([]),
            ch_macs3_plot_homer_annotatepeaks_replicate_multiqc.collect().ifEmpty([]),
            ch_featurecounts_replicate_multiqc.collect{it[1]}.ifEmpty([]),

            ch_deseq2_pca_replicate_multiqc.collect().ifEmpty([]),
            ch_deseq2_clustering_replicate_multiqc.collect().ifEmpty([])
        )
        ch_multiqc_report = MULTIQC.out.report
    }

    emit:
    multiqc_report = ch_multiqc_report.toList()  // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
