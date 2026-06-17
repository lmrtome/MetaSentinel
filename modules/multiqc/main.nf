process MULTIQC_REPORT {
    
    tag "multiqc"

    conda "${moduleDir}/environment.yml"

    input:
    path (qc_all_dirs)

    output:
    path("multiqc_report.html"), emit : report

    script:
    """
    multiqc ${qc_all_dirs.join(' ')}  -o ./ --dirs -n multiqc_report.html
    """
}