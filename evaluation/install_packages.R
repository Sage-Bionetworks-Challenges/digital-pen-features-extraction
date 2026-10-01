# R package dependencies for the evaluation scripts.
#
# optparse and jsonlite are used by score.R for CLI argument parsing and
# JSON output, respectively. ranger and glmnet are included to support
# submissions/models built with these packages.
packages <- c("optparse", "jsonlite", "ranger", "glmnet")
install.packages(packages, repos = "https://cloud.r-project.org")

# install.packages() does not raise on failure, so check explicitly to
# avoid a Docker build that reports success but ships a broken R install.
missing <- setdiff(packages, rownames(installed.packages()))
if (length(missing) > 0) {
  stop(sprintf("Failed to install package(s): %s", paste(missing, collapse = ", ")))
}
