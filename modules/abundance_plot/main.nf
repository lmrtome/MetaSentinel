process PLOT_TRANSCRIPT_ABUNDANCE {

    tag "${sample_id}"

    label 'process_low'

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(sample_id), path(diamond_results), path(taxa_names), path(salmon_quant)

    output:
    tuple val(sample_id), path("${sample_id}_combined_results.tsv"), emit: combined_results
    tuple val(sample_id), path("${sample_id}_abundance_plot.svg"), emit: abundance_plots

    script:
    """
    plot_abudance.R ${diamond_results} ${taxa_names} ${salmon_quant} ${sample_id}_abundance_plot.svg ${sample_id}_combined_results.tsv
    """
}