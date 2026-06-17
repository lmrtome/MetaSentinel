process ESTIMATE_ABUNDANCE {

    conda "${moduleDir}/environment.yml"

    tag "${sample_id}"

    input:
        tuple val(sample_id), path(contigs), path(mapped_sam)

    output:
        tuple val(sample_id), path("${sample_id}_salmon_quant/quant.sf"), emit: salmon_quant

    script:
    """
    salmon quant -t ${contigs} -l U -a ${mapped_sam}  -o ${sample_id}_salmon_quant --ont --meta -p ${params.threads}
    """
}
