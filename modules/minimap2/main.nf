process MAP_READS_TO_CONTIGS {

    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"

    input:
        tuple val(sample_id), path(contigs), path(reads)

    output:
        tuple val(sample_id), path("*.sam"), emit: mapping_result

    script:
    """
    minimap2 -ax map-ont ${contigs} ${reads} > ${sample_id}.sam 
    """
}
