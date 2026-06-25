#!/usr/bin/env Rscript
# Set up local library paths for the cluster environment
print("LIBPATHS:")
print(.libPaths())

print("Current working directory:")
print(getwd())

print("List of things present in the working dir:")
print(system("ls -la"))


suppressPackageStartupMessages({
  library(Matrix)
  library(Seurat)
  library(readr)
  library(dplyr)
  library(SingleCellExperiment)
  library(nebula)
  library(optparse)
})

# Define command line options
option_list <- list(
  make_option(c("-d", "--disease"), type="character", default="T2D", help="Disease choice (e.g. T2D)"),
  make_option(c("-c", "--cpc"), type="numeric", default=0.01, help="Counts per cell threshold"),
  make_option(c("-n", "--ncells"), type="integer", default=30, help="Min cells per donor"),
  make_option(c("-a", "--attention"), type="character", default="attw_beforeSM", help="attw_afterSM or attw_beforeSM"),
  make_option(c("-f", "--covariates"), type = "character", default = "~ sex + age + bmi + smoking_status_numeric +", 
              help = "Covariates to use in Nebula"),
  make_option(c("-p", "--input_counts_att"), type = "character", default = "attw_beforeSM__sex", 
              help = "prefix used for genes, barcodes, counts")
)





opt <- parse_args(OptionParser(option_list=option_list))

# --- Variables ---
disease_choice <- opt$disease
cpc <- opt$cpc
N_CELLS <- opt$ncells
att_w_choiche <- opt$attention
covariates_string <- opt$covariates
input_counts_att <- opt$input_counts_att

ABS_COUNTS <- 'None'
cases_only <- FALSE

#source("/opt/notebooks/runNebula.r")
#### Helper ####
SampleTable <- function(sce, 
                        sample_col, 
                        condition_col){
  # Description #
  # Computes the number of samples in each condition; 
  # Useful to check nebula assumptions
  
  # membership matrix
  mm <- table(colData(sce)[[sample_col]], colData(sce)[[condition_col]]) > 0
  res <- colSums(mm)
  
  return(res)
  
}

# Many samples (30+ AND sample/ subject-level variables >= 10) ####
## nebula ####
RunNebula <- function(sce, # SCE obj
                      samples = 'sample', # column_of_colData specifying samples 
                      formula = '~X1', #~Descrete+... or ~Continous+; they can be mixed together
                      design = NULL, # output of model.matrix, not needed if formula is specified
                      reference = NULL, # list [column_of_colData, reference_level]
                      offset = NULL, # vec, default uses library size per cell
                      low_regiment_data = FALSE, # if less than 10 samples for  subject-level variables, set it to true and uses model='NBLMM',reml=1, 
                      adj_pval_method='BH', # p.adjust method 
                      ncore = 1, #int or NULL, NULL uses max cores - 2
                      counts_per_cells=0.01, # 1% to filter most of the lowly detected genes 
                      ...){ # nebula paramas
  
  ### Description ###
  # Runs nebula on a sce object, needs sample information and a formula.
  
  # publication: https://www.nature.com/articles/s42003-021-02146-6 
  
  # The best use case is on more than 30 samples (in total) with droplet-based
  # method. Notably, works well even with few cells (at least 500) per sample.
  
  # for the formula and design read: https://f1000research.com/articles/9-1444/v1
  
  # nebula specific info
  #NOTE: If the counts per sample value is <30, nebula will set method='HL' regardless of the user’s input. 
  
  # NOTE: sample-level prediction
  # When predicting sample-level conditions k should be set to 800 or higher! 
  # Another option is to use a Poisson Gamma Mixed Model, which is 50x faster. 
  
  # NOTE: cell-level prediction 
  # k higher than 200 should be fine for cell-level predictions. 
  # Do not use k lower than 200, it will result in poor statics
  
  # NOTE: QCs of results 
  # Convergance: if lower than 25, there is a problem!If 20, extend the epochs
  # Variability: 
  #     cell-level: higher than 100 for at least 50 cells x sample
  #     sample-level: higher than 1 
  #
  #   these are noisy and are not useful for differential expression
  #   these are the genes you want to use as HvGs for downstream processing 
  
  # NOTE: WHAT IF QCs ARE BAD?
  # test a different model depending on your data 
  
  # REGRESSION: can be used also for continous variables 
  
  message('--- Nebula Differential Expression Analysis---')
  # model matrix
  # setting the specified reference 
  if(!is.null(reference)){
      condition <- factor(colData(sce)[[reference[[1]]]]) # column 
      condition <- stats::relevel(condition, ref = reference[[2]]) # reference level
      message(paste0('Using ', levels(condition)[[1]], ' as reference (Intercept) for the model'))
      colData(sce)[[reference[[1]]]] <- condition
  }
  
  if(is.null(design)){
    design <- model.matrix(as.formula(formula), data = colData(sce))
  }
  
  # parallel computation
  if(is.null(ncore)){
    ncore <- parallel::detectCores() - 2
    message(paste0('    using ', ncore, '/', parallel::detectCores(), ' cores'))
  }
  
  # offset (library size)
  if(is.null(offset)){
    offset <- Matrix::colSums(counts(sce))
    if(any(offset == 0)){
      warning('    offset contains 0; please drop empty droplets or use a different offset!')
    }
  }
  
  # grouping data
  data_g = nebula::group_cell(count = counts(sce),
                      id = colData(sce)[[samples]],
                      pred = design, 
                      offset = offset)
  
  # Cell are already grouped! so data_g will be set to NULL
  # and will crash nebula::nebula
  if(is.null(data_g)){
      data_g <- list(
          'count' = counts(sce),
          'id' = colData(sce)[[samples]],
          'pred' = design,
          'offset' = offset
      )
  }
  
  # nebula fit
  if(!low_regiment_data){
  # best case scenario to run nebula
      res <- nebula::nebula(count = data_g[['count']], 
                    id = data_g[['id']],
                    pred = data_g[['pred']],
                    offset = data_g[['offset']], 
                    cpc = counts_per_cells, 
                    ncore = ncore, 
                    ...)
  } else if(low_regiment_data){
  # low number of samples per condition 
      message('Running in a low data regiment! using REML with NBLMM')
      res <- nebula::nebula(count = data_g[['count']], 
                    id = data_g[['id']],
                    pred = data_g[['pred']],
                    offset = data_g[['offset']], 
                    cpc = counts_per_cells, 
                    model = 'NBLMM', 
                    reml = 1,
                    ncore = ncore, 
                    ...)
  } else {
      warning('*** Bad model, please consider setting low_data_regiment to TRUE or FALSE depening on the number of samples x condition you have ***')
      return('')
  }
  
  # convergence quality
  bad_convergence <- any(!(names(table(res$convergence)) %in% c('-10', '1')))
  
  if(bad_convergence){
      warning('    Bad convergence found, please double check it using: table(res$convergence) \n check here for error codes: https://cran.r-project.org/web/packages/nebula/vignettes/nebula_example.html')
  }
  
  # Adjusted p-value 
  if(!is.null(adj_pval_method)){
      summary_stats <- res[['summary']]
      pval_columns <- grepl('p_', colnames(summary_stats))
      
      adj_p_colnames <- paste0('adj_', colnames(summary_stats)[pval_columns])
      summary_stats[, adj_p_colnames] <- apply(summary_stats[, pval_columns],
          MARGIN = 2, 
          FUN = stats::p.adjust, 
          method = adj_pval_method)
      
      res[['summary']] <- summary_stats
  }
  
  message('\n--- done ---')
  return(res)
}

GetNebulaResult <- function(res,
    adj_p_threshold = 0.05,
    logFC_threshold = 1,
    max_subj_overdispersion=1,
    min_convergence_code=-10){
    # Description 
    # Filters nebula results for adjusted p value and logFC. 
    # also removes poorly estimated genes based on overdispersion Subject
    # and convergence 
    
    if(!is.data.frame(res)){
        summary_stats <- res[['summary']]
    } else {
        summary_stats <- res
    }
    ## QC filters 
    # over dispersion by sample-level and convergence
    not_overdispersed_genes <- res[['overdispersion']][['Subject']] <= max_subj_overdispersion
    good_convergence <- res[['convergence']] > min_convergence_code
    keep <- not_overdispersed_genes + good_convergence > 1
    summary_stats <- summary_stats[keep, ]
    
    # removing intercept values 
    summary_stats <- summary_stats[, -which(colnames(summary_stats) %in% c('logFC_(Intercept)', 'se_(Intercept)', 'adj_p_(Intercept)', 'p_(Intercept)'))]
    
    ## filtering by adj.pval 
    # for a vector
    adj_pval <- summary_stats[, grepl('adj_', colnames(summary_stats))]
    single_comparison <- is.null(dim(adj_pval))
    if(single_comparison){
      keep <- adj_pval < adj_p_threshold
    } else {
      # for a matrix
      keep <- rowSums(adj_pval < adj_p_threshold) > 0
    }
    degs <- summary_stats[keep, ]
    
    ## filtering by logFC
    abs_logFC <- abs(degs[, grepl('log', colnames(degs))])
    # for a vector
    if(single_comparison){
    keep <- abs_logFC >= logFC_threshold
    } else {
    # for a matrix
    keep <- rowSums(abs_logFC >= logFC_threshold) > 0
    }
    degs <- degs[keep, ]
    
    # formatting the table 
    degs <- cbind(degs[, c('gene_id', 'gene')], degs[, -which(colnames(degs) %in% c('gene', 'gene_id'))])
    
    return(degs)
}


# Nebula 1vsALL 
NebulaBOGs <- function(sce,
                       condition,
                       samples, 
                       file_name=NULL,
                       file_path='', 
                       low_regiment_data=TRUE,
                       adj_p_threshold=0.01,
                       logFC_threshold=1,
                       ncore=1,
                       max_subj_overdispersion=1,
                       min_convergence_code=-10,
                       ...){
  
  # Description ####
  # Performs 1vsAll differential expression analysis and returns a list of tables, 
  # one for condition 
  
  # table of comparisons 1vsAll ####
  conditions_vec <- colData(sce)[[condition]]
  unique_conditions <- unique(conditions_vec)
  comparison_list <- lapply(unique_conditions, function(condition_i){
    comparison_i <- ifelse(conditions_vec == condition_i, 'Tested', 'Other')
    comparison_i <- factor(comparison_i, levels = c('Other', 'Tested'))
    return(comparison_i)
  }
  )
  
  # to avoid breaking nebula
  unique_conditions <- paste0(unique_conditions, '_')
  names(comparison_list) <- unique_conditions
  # add them to the sce for RunNebula
  colData(sce)[names(comparison_list)] <- DataFrame(comparison_list)
  
  # RunNebula ####
  result_list <- lapply(unique_conditions, function(condition_i){
    
    msg <- paste0('Testing: ',
                  condition_i,
                  '; ',
                  which(unique_conditions == condition_i),
                  ' out of ',
                  length(unique_conditions))
    
    message(msg)  
    
    #TODO: filter a priory the object for genes expressed less than 
    #    the threshold and then set the nebula threshold to 0
    res_i <- RunNebula(sce,
                       samples = samples, 
                       formula = paste0('~', condition_i), 
                       low_regiment_data = low_regiment_data, 
                       ncore = ncore)
    
    result_table_i <- GetNebulaResult(res_i, 
                                      adj_p_threshold = adj_p_threshold,
                                      logFC_threshold = logFC_threshold,
                                      max_subj_overdispersion = max_subj_overdispersion,
                                      min_convergence_code = min_convergence_code, 
                                      ...)
    
    print('')
    
    return(result_table_i)
  }
  )
  names(result_list) <- unique(conditions_vec)
  
  if(!is.null(file_name)){
    SaveDataFrameList(result_list, file_name, file_path)
  }
  
  return(result_list)
}

celltype_list <- c('T_CD4_prolif',
 'Monocyte_CD16',
 'cDC2',
 'Monocyte_CD14',
 'ASDC',
 'B_memory_IGHMlow',
 'T_CD4_EM',
 'T_CD4_CM',
 'T_CD4_naive',
 'B_memory_IGHMhigh',
 'pDC',
 'T_CD4_Treg',
 'NK_CD16',
 'Basophil',
 'T_CD8_EM',
 'T_CD8_EMRA',
 'T_CD8_CM',
 'B_naive',
 'B_exhausted',
 'T_CD8_naive',
 'T_CD4_CTL',
 'T_gd',
 'T_MAIT',
 'NK_prolif',
 'HSC_MPP',
 'cDC1',
 'ILC',
 'NK_CD56bright',
 'B_CD5',
 'Plasma_cell',
 'Plasmablast',
 'T_CD8_prolif',
 'Platelet')


library(BPCells)

# Construct paths
if (ABS_COUNTS == 'None') {
    continuous_att_column <- paste0(att_w_choiche, '__', disease_choice)
} else { 
    continuous_att_column <- paste0(att_w_choiche, '__b64__', disease_choice, '__', ABS_COUNTS)
}


print(paste0("Using covariates: ", covariates_string))

# --- Execution Loop ---
error_log <- list()

for (ct in celltype_list) {
    
    output_string <- if(cases_only == FALSE) {
            paste0("F3_v3_UKB__", continuous_att_column, 
                   "__",ct , "__cases_and_controls__abs_counts_", ABS_COUNTS, "__")
        } else {
            paste0("F3_v3_UKB__", continuous_att_column,
                   "__",ct , "__cases_only__abs_counts_", ABS_COUNTS, "__")
        }

    message("Processing Output String new version: ", output_string)

    output_string_4counts <- paste0("F3_v3_UKB__", input_counts_att, "__", 
                                    ct , "__cases_and_controls__abs_counts_", ABS_COUNTS, "__")
    
    # --- File Existence Check ---
    required_files <- c(
        paste0(output_string_4counts, "__counts.mtx"),
        paste0(output_string_4counts, "__genes.tsv"),
        paste0(output_string_4counts, "__barcodes.tsv"),
        paste0(output_string, "__metadata.tsv")
    )
    print(paste0("Required files: ", required_files))
    missing_files <- required_files[!file.exists(required_files)]
    if (length(missing_files) > 0) {
        message("Skipping ", ct, ": Missing file(s):\n  ", paste(missing_files, collapse = "\n  "))
        next
    }

    # --- Data Loading ---
    message("Loading data...")
    # --- Data Loading ---
    message("Loading count matrix with bpcell package")
    counts <- import_matrix_market(
        paste0(output_string_4counts,"__counts.mtx")
    ) #|> 
       #   write_matrix_dir(dir = paste0(output_string_4counts, 
                                     #   "__counts_bpc"))
    
    #counts <- open_matrix_dir(paste0(output_string_4counts,"__counts_bpc"))
    
    #counts <- readMM(paste0(output_string_4counts, "__counts_bpc"))
    counts <- t(counts)

    gene_names <- read_tsv(paste0(output_string_4counts, "__genes.tsv"), 
                           col_names = FALSE, show_col_types = FALSE)
    rownames(counts) <- gene_names$X1

    cell_bc <- read_tsv(paste0(output_string_4counts, "__barcodes.tsv"), 
                        col_names = FALSE, show_col_types = FALSE)[ , 'X2']
    # add cell names (cell barcodes) as colnames of count matrix
    colnames(counts) <- cell_bc$X2

    metadata_df <- read_tsv(paste0(output_string, "__metadata.tsv"), 
                            col_names = TRUE, show_col_types = FALSE)
    metadata_df <- as.data.frame(metadata_df)
    rownames(metadata_df) <- metadata_df[[1]] # Adjusted to use first column as index


    # Create list-like structure
    sample_data <- list(
      metadata = metadata_df,
      donor_ids = metadata_df$eid,   # or whatever column name in your metadata
      count = counts
    )
    sce <- SingleCellExperiment(assays = list('counts' = sample_data$count))
    colData(sce) <- DataFrame(sample_data$metadata)
    celltype_list <- unique(sce$celltype_2)


    message("\n--- Starting celltype: ", ct, " ---")
    subset_sce <- sce[ , sce$celltype_2 == ct]
    
    # Filtering donors
    tbl <- as.data.frame(table(subset_sce$eid, subset_sce$celltype_2))
    count_df <- tbl[tbl$Var2 == ct, c('Var1', 'Freq')]
    colnames(count_df) <- c('eid', ct)
    eid_test <- count_df[count_df[[ct]] > N_CELLS,][['eid']]
    subset_sce <- subset_sce[ , subset_sce$eid %in% eid_test]
    print(paste0("Dimension of the subset object after filtering for donors with at least ", 
                 N_CELLS, " in celltype ", ct))
    print(dim(subset_sce))
    print(Sys.time())
    
    if (ncol(subset_sce) == 0) {
        message("Skipping ", ct, ": No donors met the threshold.")
        next
    }

    results <- tryCatch({
        res <- RunNebula(subset_sce, 
                         samples = 'eid', 
                         formula = paste0(covariates_string, 
                                          continuous_att_column, '+ ', disease_choice),
                         ncore = 4, # Upped to 4 for HPC
                         counts_per_cells = cpc)
        
        prefix = paste0('nebula_results__biological_cov__continuous_attw__ct2_CPC',
                        cpc,
                     '_', ct, 
                     '_filtered_for_atleast_', N_CELLS, 'cells__',
                      output_string)
        
        for (name in names(res)) {
            write.table(res[[name]], 
                        file = paste0(prefix, name, ".tsv"), 
                        sep = "\t", 
                        quote = FALSE, 
                        row.names = FALSE)
        }
        message("Finished: ", ct)
        res
    }, error = function(e) {
        message("Error in ", ct, ": ", e$message)
        error_log[[ct]] <<- e$message
        return(NULL)
    })
    
    print(Sys.time())
    rm(subset_sce); gc()
}

# Review errors at the end
if(length(error_log) > 0) {
    print("Summary of errors encountered:")
    print(error_log)
}

saveRDS(error_log, paste0("error_log_", disease_choice, ".RDS"))
message("Script complete.")