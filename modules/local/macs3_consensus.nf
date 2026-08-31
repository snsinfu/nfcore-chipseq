/*
 * Consensus peaks across samples, create boolean filtering file, SAF file for featureCounts
 */
process MACS3_CONSENSUS {
    tag "$meta.id"
    label 'process_long'

    conda "conda-forge::biopython conda-forge::r-optparse=1.7.1 conda-forge::r-upsetr=1.4.0 bioconda::bedtools=2.30.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-2f48cc59b03027e31ead6d383fe1b8057785dd24:5d182f583f4696f4c4d9f3be93052811b383341f-0':
        'biocontainers/mulled-v2-2f48cc59b03027e31ead6d383fe1b8057785dd24:5d182f583f4696f4c4d9f3be93052811b383341f-0' }"

    input:
    tuple val(meta), path(peaks)
    val is_narrow_peak

    output:
    tuple val(meta), path("*.bed")          , emit: bed
    tuple val(meta), path("*.saf")          , emit: saf
    tuple val(meta), path("*.pdf")          , optional: true, emit: pdf
    tuple val(meta), path("*.antibody.txt") , emit: txt
    tuple val(meta), path("*.boolean.txt")  , emit: boolean_txt
    tuple val(meta), path("*.intersect.txt"), optional: true, emit: intersect_txt
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/chipseq/bin/
    def args         = task.ext.args   ?: ''
    def prefix       = task.ext.prefix ?: "${meta.id}"
    def peak_type    = is_narrow_peak  ? 'narrowPeak' : 'broadPeak'
    def mergecols    = is_narrow_peak  ? (2..10).join(',') : (2..9).join(',')
    def collapsecols = is_narrow_peak  ? (['collapse']*9).join(',') : (['collapse']*8).join(',')
    def expandparam  = is_narrow_peak  ? '--is_narrow_peak' : ''
    def peaks_list   = peaks.collect { it.toString() }.sort()
    // UpSetR requires at least two sets; a single peak file has no intersection to plot
    def intersect_cmd = peaks_list.size() > 1 ? "plot_peak_intersect.r -i ${prefix}.boolean.intersect.txt -o ${prefix}.boolean.intersect.plot.pdf" : "# single peak set: no intersection plot generated"
    """
    sort -T '.' -k1,1 -k2,2n ${peaks_list.join(' ')} \\
        | mergeBed -c $mergecols -o $collapsecols > ${prefix}.txt

    macs3_merged_expand.py \\
        ${prefix}.txt \\
        ${peaks_list.join(',').replaceAll("_peaks.${peak_type}","")} \\
        ${prefix}.boolean.txt \\
        --min_replicates $params.min_reps_consensus \\
        $args \\
        $expandparam

    awk -v FS='\t' -v OFS='\t' 'FNR > 1 { print \$1, \$2, \$3, \$4, "0", "+" }' ${prefix}.boolean.txt > ${prefix}.bed

    echo -e "GeneID\tChr\tStart\tEnd\tStrand" > ${prefix}.saf
    awk -v FS='\t' -v OFS='\t' 'FNR > 1 { print \$4, \$1, \$2, \$3,  "+" }' ${prefix}.boolean.txt >> ${prefix}.saf

    $intersect_cmd

    echo "${prefix}.bed\t${meta.id}/${prefix}.bed" > ${prefix}.antibody.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
    END_VERSIONS
    """

}
