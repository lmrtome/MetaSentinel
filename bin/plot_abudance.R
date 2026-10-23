#!/usr/bin/env Rscript

library(dplyr)
library(readr)
library(ggplot2)
library(svglite)

args <- commandArgs(trailingOnly = TRUE)

results_diamond_path <- args[1]
names_dmp_path <- args[2]
salmon_quant_path <- args[3]
output_plot_path <- args[4]
output_combined_path <- args[5]

results_diamond <- read_tsv(results_diamond_path, col_names = c("qseqid", "qlen", "sseqid", "tax_id", "pident", "alignment_length", "evalue"))

taxon_names <- read_delim(names_dmp_path, 
                          delim = "|", 
                          col_names = c("tax_id", "name_txt", "unique_name", "name_class"),
                          trim_ws = TRUE,
                          comment = "#") %>%
  filter(name_class == "scientific name") %>%
  select(tax_id, name_txt)

results_diamond_with_names <- results_diamond %>%
  left_join(taxon_names, by = "tax_id")

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
