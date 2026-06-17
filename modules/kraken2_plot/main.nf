process PLOT_TAXONOMY {

    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(sample_id), path(taxonmy_assignment_reports)

    output:
    tuple val(sample_id), path("${sample_id}_top20_plot.pdf"), emit: taxonomy_plots

    // Define o caminho do script R no bin
    
    script:
    """
    plot_kraken2_top20.R ${sample_id} ${taxonmy_assignment_reports}
    """
}