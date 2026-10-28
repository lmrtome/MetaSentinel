#!/usr/bin/env Rscript

# --- loading packages ---

library(dplyr)
library(readr)
library(ggplot2)
library(svglite)
library(tidyr)

# --- input args from comand line ---
args <- commandArgs(trailingOnly = TRUE)

results_diamond_path <- args[1]
names_dmp_path       <- args[2]
salmon_quant_path    <- args[3]
output_plot_path     <- args[4]
output_combined_path <- args[5]

# --- setting DIAMOND matches and taxon names in a dataframe ---

results_diamond <- read_tsv(
  results_diamond_path, 
  col_names = c("qseqid", "qlen", "sseqid", "tax_id", 
                "pident", "alignment_length", "evalue"),
  col_types = cols(
    qseqid           = col_character(),
    qlen             = col_double(),
    sseqid           = col_character(),
    tax_id           = col_character(),
    pident           = col_double(),
    alignment_length = col_double(),
    evalue           = col_double()
    )) %>%

# --- Separing taxonomy identifications (a row for a taxid) ---

  mutate(hit_id = row_number())    %>%
  separate_rows(tax_id, sep =";") %>%
  mutate(tax_id = trimws(tax_id)) %>%
  filter(!is.na(tax_id), tax_id != "", tax_id != "0")

# --- Filtering scientific name and taxonomy identification
taxon_names <- read_delim(
  names_dmp_path, 
    delim = "|", 
    col_names = c("tax_id", "name_txt", 
                  "unique_name", "name_class"),
    col_types = cols(
      tax_id      = col_character(),
      name_txt    = col_character(),
      unique_name = col_character(),
      name_class  = col_character(),
      X5          =col_skip()
    ),
    trim_ws = TRUE,
    ) %>%
    filter(name_class == "scientific name") %>%
    select(tax_id, name_txt)

# --- Merging matches and taxonomy identification ---
results_diamond_with_names <- results_diamond %>%
  left_join(taxon_names, by = "tax_id")

# --- 
salmon_abundance <- read_tsv(salmon_quant_path)

combined_results <- merge(results_diamond_with_names, salmon_abundance, by.x = "qseqid", by.y = "Name")
write_tsv(combined_results, output_combined_path)

combined_results <- combined_results %>%
  mutate(label = paste(qseqid, name_txt, sep = " - "))

ggplot(combined_results, aes(x = reorder(label, TPM), y = TPM, fill = TPM)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "white", high = "darkgreen") +
  coord_flip() +
  labs(x = "Contigs/Espécie", y = "TPM") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))

ggsave(output_plot_path, width = 8, height = 6)
