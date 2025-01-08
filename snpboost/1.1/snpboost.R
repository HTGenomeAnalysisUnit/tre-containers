# Load required packages (avoid visualization in shell)
suppressMessages({
  suppressWarnings({
    library(data.table)
    library(tidyverse)
    library(parallel)
    library(bigsnpr)
    library(ggplot2)
    library(cowplot)
    library(readr)
    library(dataPreparation)
    library(Rfast)
    library(RcppGSL)
    library(optparse)
    library(stringr)
    library(SNPBoost)
  })
})


# When running through RScript, get the folder where the script is located
# x <- commandArgs(trailingOnly=FALSE)
# script_folder <- dirname(normalizePath(gsub('--file=', '', x[str_detect(x, "snpboost\\.R")])))

# Define the list of arguments
option_list <- list(
  make_option(c("-g", "--genotype"), type = "character", default = NULL,
              help = "Path to genotype file [required]", metavar = "character"),
  make_option(c("-p", "--pheno_file"), type = "character", default = NULL,
              help = "Path to phenotype file [required]", metavar = "character"),
  make_option(c("-n", "--pheno_name"), type = "character", default = NULL,
              help = "Phenotype name [required]", metavar = "character"),
  make_option(c("-f", "--family"), type = "character", default = "gaussian",
              help = "Family of the model: gaussian, binomial, cox, or count [required]", metavar = "character"),
  make_option(c("-m", "--metric"), type = "character", default = "MSEP",
              help = "Metric to use depending on family type:\n  - gaussian: MSEP, quantilereg\n  - binomial: log_loss\n  - count: Poisson, negative_binomial\n  - cox: weightedL2, AFT-Weibull, AFT-logistic, AFT-normal, Cox, C (last two slow + memory issues)", metavar = "character"),
  make_option(c("-P", "--plot"), type = "logical", default = TRUE,
              help = "Whether to plot results (TRUE/FALSE)", metavar = "logical"),
  make_option(c("-c", "--covariates"), type = "character", default = NULL,
              help = "Comma-separated list of covariate names [optional]", metavar = "character"),
  make_option(c("-t", "--threads"), type = "integer", default = 8,
              help = "Number of parallel threads to use", metavar = "integer"),
  make_option(c("-r", "--memory"), type = "integer", default = 16000,
              help = "Memory to use in MB", metavar = "integer"),
  make_option(c("-o", "--output"), type = "character", default = "./",
              help = "Output folder [optional]", metavar = "character") 
)

# Create the parser object
parser <- OptionParser(option_list = option_list)

# Parse the arguments
opt <- parse_args(parser)

# Print help message if --help flag is provided
if (is.null(opt$genotype) || is.null(opt$pheno_file) || is.null(opt$pheno_name) || is.null(opt$family)) {
  print_help(parser)
  quit(status = 0)
}

# Check for required arguments and print error if missing
required_args <- c("genotype", "pheno_file", "pheno_name", "family")
missing_args <- required_args[!required_args %in% names(opt) | sapply(opt[required_args], is.null)]
if (length(missing_args) > 0) {
  print_help(parser)
  stop(paste("Missing required arguments:", paste(missing_args, collapse = ", ")))
}

# Validate family and metric arguments
valid_families <- c("gaussian", "binomial", "cox", "count")
valid_metrics <- list(
  gaussian = c("MSEP", "quantilereg"),
  binomial = c("log_loss"),
  count = c("Poisson", "negative_binomial"),
  cox = c("weightedL2", "AFT-Weibull", "AFT-logistic", "AFT-normal", "Cox", "C")
)

if (!opt$family %in% valid_families) {
  stop(paste("Invalid family type:", opt$family, "\nValid options are:", paste(valid_families, collapse = ", ")))
}

if (!opt$metric %in% valid_metrics[[opt$family]]) {
  stop(paste("Invalid metric type for family", opt$family, ":", opt$metric, "\nValid options are:", paste(valid_metrics[[opt$family]], collapse = ", ")))
}

# Extract covariates
if (!is.null(opt$covariates)) {
  covariates <- strsplit(opt$covariates, ",")[[1]]
} else {
  covariates <- NULL
}

# Assign arguments to variables
genotype.pfile <- opt$genotype
pheno_i <- opt$pheno_file
pheno_name <- opt$pheno_name
family_i <- opt$family
metric_i <- opt$metric
plot_i <- opt$plot
n_threads <- opt$threads
mem <- opt$memory
output_folder <- opt$output

# Print argument values for debugging
print("=== SNPBoost ===")
#print(paste("Script folder:", script_folder))

print("=== Arguments ===")
print(paste("Genotype file:", genotype.pfile))
print(paste("Phenotype file:", pheno_i))
print(paste("Phenotype name:", pheno_name))
print(paste("Family:", family_i))
print(paste("Metric:", metric_i))
print(paste("Plot:", plot_i))
print(paste("Covariates:", ifelse(is.null(covariates), "None", paste(covariates, collapse = ", "))))
print(paste("Threads:", n_threads))
print(paste("Memory:", mem))
print(paste("Output folder:", output_folder))

### Load snpboost functions
# source(file.path(script_folder, "Functions/lm_boost.R"))
# source(file.path(script_folder, "Functions/snpboost.R"))
# source(file.path(script_folder, "Functions/functions_snpboost.R"))
# source(file.path(script_folder, "Functions/functions_snpnet.R"))

# More variable assignments
phenotype.file = pheno_i
phenotype = pheno_name
family_type = family_i
metric_type = metric_i
plot_performance = plot_i

configs <- list(
  results.dir = file.path(output_folder, phenotype),  # Results folder
  save = FALSE,
  prevIter = 0,
  missing.rate = 0.1,
  MAF.thresh = 0.001,
  num.snps.batch = 1000,
  early.stopping = TRUE,
  stopping.lag = 2,
  verbose = TRUE,
  mem = mem,
  niter = 30000,
  nCores = n_threads,
  standardize.variant = TRUE
)

### Fit fit_snpboost
time_snpboost_start <- Sys.time()

fit_snpboost <- snpboost(
  genotype.pfile = genotype.pfile,
  phenotype.file = phenotype.file,
  phenotype = phenotype,
  covariates = covariates,
  configs = configs,
  split.col = "train_test",
  p_batch = 1000,
  m_batch = 1000,
  b_max = 20000,
  b_stop = 2,
  sl = 0.1,
  coeff_path_save = TRUE,
  give_residuals = FALSE,
  family = family_type,
  metric = metric_type
)

time_snpboost_end <- Sys.time()

# Predict PRS for all samples
pred_all_snpboost <- predict_snpboost(fit_snpboost, genotype.pfile, phenotype.file, phenotype)

# Extract coefficients and number of chosen SNPs
idx <- which.min(fit_snpboost$metric.val)
betas <- get_coefficients(fit_snpboost$beta, idx, covariates = fit_snpboost$configs[['covariates']])
intercept <- betas[1]

# Option 2: save complete beta vector including intercept
fwrite(list(rsID = str_split(names(betas), "_", simplify = TRUE)[, 1], 
            A1 = str_split(names(betas), "_", simplify = TRUE)[, 2], 
            beta = betas), file = paste0(fit_snpboost$configs[['results.dir']], "/betas.txt"), sep = "\t", row.names = FALSE)

# Optional plot
if (plot_performance) {
  sparsity <- sapply(1:nrow(fit_snpboost$beta), function(x) length(unique(fit_snpboost$beta$name[1:x])))

  df_plot <- data.frame(
    iteration = 1:length(sparsity), sparsity = sparsity - 1,
    metric.train = fit_snpboost$metric.train, metric.val = fit_snpboost$metric.val
  )

  # r2 defined as 1 - MSEP / MSEP(null model)
  df_plot$r2.train <- 1 - df_plot$metric.train / df_plot$metric.train[1]
  df_plot$r2.val <- 1 - df_plot$metric.val / df_plot$metric.val[1]

  fwrite(df_plot, file = paste0(fit_snpboost$configs[['results.dir']], "/df_plot.txt"), sep = "\t", row.names = FALSE)

  ggplot(df_plot, aes(x = iteration)) +
    geom_line(aes(y = sparsity, color = "sparsity")) +
    geom_line(aes(y = r2.val * max(sparsity) / max(df_plot$r2.val), color = "r2")) +
    scale_color_manual(name = "", values = c("sparsity" = "blue", "r2" = "red"), labels = c(expression(r^2), "sparsity")) +
    scale_y_continuous(name = "sparsity", sec.axis = sec_axis(~ . * max(df_plot$r2.val) / max(df_plot$sparsity), name = expression(r^2))) +
    theme_minimal() +
    theme(text = element_text(size = 18))

  ggsave(paste0(fit_snpboost$configs[['results.dir']], "/performance_plot.png"))
}

# Fit glm with PRS and covariates on train and val data and predict on test data
data <- fread(phenotype.file) %>% mutate(IID = as.character(IID))
pred <- data.table(IID = rownames(pred_all_snpboost$prediction), PRS = pred_all_snpboost$prediction)

data <- full_join(data, pred) %>% rename(PRS = PRS.V1) %>% filter(complete.cases(.))

# Construct formula with covariates
covariate_formula <- if (!is.null(covariates)) {
  paste(covariates, collapse = " + ")
} else {
  ""
}

# Define the full formula for the model
formula_model <- as.formula(paste0(phenotype, " ~ ", covariate_formula, " + PRS"))

# Fit glm model
full_model <- glm(formula_model, data = data %>% filter(train_test %in% c("train", "val")), family = "gaussian")

# Predict on test data
pred_full_model_test <- predict.glm(full_model, newdata = data %>% filter(train_test %in% c("test")))

# Compute MSEP
MSEP_test_full_model = mean((data[data$train_test %in% c("test"), ] %>% pull(all_of(phenotype)) - pred_full_model_test) ^ 2)

# Compute R-squared
cor_squared_test_full_model = cor(data[data$train_test %in% c("test"), ] %>% pull(all_of(phenotype)), pred_full_model_test) ^ 2

print(paste("MSEP on test data:", MSEP_test_full_model))
print(paste("R-squared on test data:", cor_squared_test_full_model))

