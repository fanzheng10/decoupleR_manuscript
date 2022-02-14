library(decoupleRBench)
library(dplyr)
library(tibble)
source(file.path('R', 'process', 'methods_params.R'))

# Define data, metadata and network path
raw_path <- file.path('data', 'raw')
prc_path <- file.path('data', 'prc')
dir.create(prc_path, showWarnings = F, recursive = T)
expr_fname <- file.path(raw_path, "php_expr.rds")
meta_fname <- file.path(raw_path, "php_meta.rds")
netw_fname <- file.path(raw_path, 'KSN_weight.rds')

# Design
design <- tibble(
  set_name = 'unweighted', # name of the set resource
  bench_name = "beltrao", # name of the benchmark data
  stats_list = stats_list,
  opts_list = opts_list,
  bexpr_loc = expr_fname, # benchmark data location
  bmeta_loc = meta_fname, # metadata location
  source_loc = netw_fname, # set source location
  source_col = "source", # source name of the gene set source
  target_col = "target", # target name of the set source
  filter_col = "confidence", # column by which we wish to filter
  filter_crit = list(c('A')), # criteria by which we wish to filter,
  # weight_crit = list(list(.likelihood = "likelihood"))
  weight_crit = list(list(.mor = "mor"))
)

design <- bind_rows(
  design,
  design %>%
    mutate(set_name ="weighted", weight_crit = list(NA))
  )

# Run benchmark
result <- run_benchmark(
  .design = design, # provide input tibble
  .minsize = 5, # filter gene sets with size < 10
  .form = TRUE, # format the benchmark results
  .perform = TRUE, # evaluate benchmarking performance
  .silent = FALSE, # silently run the pipeline
  .downsample_pr = TRUE, # downsample TNs for precision-recall curve
  .downsample_roc = TRUE, # downsample TNs for ROC
  .downsample_times = 100, # downsampling iterations
  .url_bool = FALSE # whether to load from url
)

# Save result
if (opts_list[[1]][['mlmreg']]$alpha == 0) {
  saveRDS(result, file.path(prc_path, 'php_result_ridge_r2.rds'))
}
if (opts_list[[1]][['mlmreg']]$alpha == 1) {
  saveRDS(result, file.path(prc_path, 'php_result_lasso_r2.rds'))
}
result@summary$summary_table
