process DOWNSAMPLE_BAM {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::samtools=1.20"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.20--h50ea8bc_0' :
        'biocontainers/samtools:1.20--h50ea8bc_0' }"

    input:
    tuple val(meta), path(ip_bam), path(control_bam), path(ip_flagstat)
    val   target_fragments
    val   seed

    output:
    tuple val(meta), path("*.ds.bam"), path(control_bam), optional: true, emit: bam
    tuple val(meta), path("*.downsample_summary.txt"), emit: summary
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args     = task.ext.args ?: ''
    def prefix   = task.ext.prefix ?: "${meta.id}"
    def se       = meta.single_end ? 1 : 0
    def seed_opt = seed != null ? "--subsample-seed ${seed}" : ''
    """
    # Fragment (template) count: single-end -> mapped reads; paired-end -> read1.
    # One read1 = one fragment (template); samtools --subsample keeps mates together.
    if [ ${se} -eq 1 ]; then
        TOTAL=\$(grep -E '^[0-9]+ \\+ [0-9]+ mapped ' ${ip_flagstat} | head -n1 | awk '{print \$1}')
    else
        TOTAL=\$(grep -E '^[0-9]+ \\+ [0-9]+ read1\$' ${ip_flagstat} | head -n1 | awk '{print \$1}')
    fi
    TOTAL=\${TOTAL:-0}

    if [ "\$TOTAL" -eq 0 ] || [ ${target_fragments} -ge "\$TOTAL" ]; then
        FRACTION="1.0000000000"
        DOWNSAMPLED="false"
        cp ${ip_bam} ${prefix}.ds.bam
    else
        # Fixed decimal notation only: awk's default print can emit scientific notation.
        FRACTION=\$(awk -v t='${target_fragments}' -v n="\$TOTAL" 'BEGIN { printf "%.10f", t/n }')
        DOWNSAMPLED="true"
        samtools view $args -@ $task.cpus $seed_opt --subsample "\$FRACTION" -b -o ${prefix}.ds.bam ${ip_bam}
    fi
    samtools index -@ $task.cpus ${prefix}.ds.bam

    RETAINED=\$(samtools view -c -@ $task.cpus ${prefix}.ds.bam)
    if [ ${se} -eq 0 ]; then RETAINED=\$(( RETAINED / 2 )); fi

    # Control-depth diagnostic. MACS3 default --scale-to small downscales the deeper of
    # treatment/control to the shallower one, so a control shallower than the target caps
    # the effective depth. Controls are NOT downsampled.
    CTRL_TOTAL="NA"
    DEPTH_LIMITED="NA"
    if [ -s "${control_bam}" ]; then
        CTRL_FS=\$(samtools flagstat -@ $task.cpus ${control_bam})
        CTRL_READ1=\$(echo "\$CTRL_FS" | grep -E '^[0-9]+ \\+ [0-9]+ read1\$' | head -n1 | awk '{print \$1}')
        CTRL_MAPPED=\$(echo "\$CTRL_FS" | grep -E '^[0-9]+ \\+ [0-9]+ mapped ' | head -n1 | awk '{print \$1}')
        if [ "\${CTRL_READ1:-0}" -gt 0 ]; then CTRL_TOTAL="\$CTRL_READ1"; else CTRL_TOTAL="\${CTRL_MAPPED:-0}"; fi
        if [ "\$CTRL_TOTAL" -lt ${target_fragments} ]; then DEPTH_LIMITED="true"; else DEPTH_LIMITED="false"; fi
    fi

    printf "sample\ttotal_fragments\ttarget_fragments\tfraction\tretained_fragments\tdownsampled\tcontrol_fragments\tdepth_limited\n" > ${prefix}.downsample_summary.txt
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "${prefix}" "\$TOTAL" "${target_fragments}" "\$FRACTION" "\$RETAINED" "\$DOWNSAMPLED" "\$CTRL_TOTAL" "\$DEPTH_LIMITED" >> ${prefix}.downsample_summary.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.ds.bam
    printf "sample\ttotal_fragments\ttarget_fragments\tfraction\tretained_fragments\tdownsampled\tcontrol_fragments\tdepth_limited\n" > ${prefix}.downsample_summary.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
