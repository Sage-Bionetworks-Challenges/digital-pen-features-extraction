#!/usr/bin/env Rscript

# Placeholder scoring script for digital pen features extraction submissions.
#
# Expected metrics to return are:
# - rmse: Root Mean Squared Error (primary)
# - mae: Mean Absolute Error (secondary)
# - cor: Pearson correlation coefficient
# - ccc: Lin's concordance correlation coefficient

suppressPackageStartupMessages({
  library(optparse)
  library(jsonlite)
})

read_csv_by_id <- function(filepath, id_col = "id") {
  # Parses a file and returns a data.frame keyed by id_col (as row names).
  df <- tryCatch(
    read.csv(filepath, stringsAsFactors = FALSE),
    error = function(e) NULL
  )
  if (is.null(df) || !(id_col %in% colnames(df))) {
    return(NULL)
  }
  rownames(df) <- df[[id_col]]
  df
}

main <- function() {
  option_list <- list(
    make_option(c("-p", "--prediction_file"), type = "character",
                help = "Filepath to prediction CSV"),
    # make_option(c("-g", "--groundtruth_file"), type = "character",
    #             help = "Filepath to groundtruth/goldstandard CSV"),
    make_option(c("-o", "--output_file"), type = "character",
                default = "results.json",
                help = "Output JSON file for scores and results [default %default]")
  )
  opt <- parse_args(OptionParser(option_list = option_list))

#   if (is.null(opt$prediction_file) || is.null(opt$groundtruth_file)) {
#     stop("Both --prediction_file and --groundtruth_file are required.")
#   }

  id_col <- "filename"
  pred <- read_csv_by_id(opt$prediction_file, id_col = id_col)

  if (is.null(pred)) {
    scores <- list(rmse = NA, mae = NA, cor = NA, ccc = NA)
    status <- "INVALID"
    errors <- sprintf(
      "Cannot be evaluated; %s not found in the prediction file", id_col
    )
  } else {
    # TODO: replace with score_regression() once the groundtruth file is available.
    scores <- list(rmse = 0, mae = 0, cor = 1, ccc = 1)
    status <- "SCORED"
    errors <- ""
  }

  result <- list(
    rmse = scores$rmse,
    mae = scores$mae,
    cor = scores$cor,
    ccc = scores$ccc,
    submission_status = status,
    submission_errors = errors
  )

  write(toJSON(result, auto_unbox = TRUE, na = "null"), file = opt$output_file)
}

main()
