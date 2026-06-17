process AMR_DETECTION {

    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"

    input:
        tuple val(sample_id), path(assembly_results)

    output:
        tuple val(sample_id), path("${sample_id}_amrfinder.txt"), emit: amr_results

    script:
    """
    amrfinder -n ${assembly_results} --database ${params.database_amrfinder} --threads ${params.threads} -o ${sample_id}_amrfinder.txt
    """
}
