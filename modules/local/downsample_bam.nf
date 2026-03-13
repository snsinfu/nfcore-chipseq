process DOWNSAMPLE_BAM {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::samtools=1.20"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.20--h50ea8bc_0' :
        'biocontainers/samtools:1.20--h50ea8bc_0' }"

    input:
    tuple val(meta), path(bam), path(bai), path(flagstat)
    val target_reads

    output:
    tuple val(meta), path("*.downsampled.bam"), path("*.downsampled.bam.bai"), emit: bam
    path "versions.yml", emit: versions

    script:
    def seed = 0
    def prefix = "${meta.id}.downsampled"

    """
    total_reads=\$(awk '/mapped \\(/ { print \$1; exit }' ${flagstat})

    fraction=\$(
        awk -v target=${target_reads} \\
            -v total=\$total_reads \\
            'BEGIN { print (total > target ? target / total : 1) }'
    )

    if [ "\$fraction" != "1" ]; then
        samtools view -@ ${task.cpus} -s ${seed}.\${fraction#0.} -b -o ${prefix}.bam ${bam}
        samtools index -@ ${task.cpus} ${prefix}.bam
    else
        ln -s ${bam} ${prefix}.bam
        ln -s ${bai} ${prefix}.bam.bai
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
