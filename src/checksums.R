#checksums.R
# R script to check md5sums
# Arguments from command line:
# 1) Directory of md5sums generated in cluster
# 2) Directory of md5sums provided by core facility

#load libraries
library(stringr)

# Getting arguments from command line
args <- commandArgs(trailingOnly = TRUE)

# Variables for md5sums from cluster and core facility
md5_cluster <- args[1]
md5_core <- args[2]

#output file name containing the links of failed fq files (incorrect and missing).
out_file <- "failmd5.txt"

# Check Arguments
if (!file.exists(md5_cluster)) {
  stop(paste(md5_cluster, "directory was not found"))
} else if (!file.exists(md5_core)) {
    stop(paste(md5_core, "directory was not found"))
} else if (!(length(list.files(md5_cluster)>0))) {
    stop(paste(md5_cluster, "directory is empty"))
} else if (!(length(list.files(md5_core)>0))) {
    stop(paste(md5_core, "directory is empty"))
} else {
  cat("comparing md5sums", "\n")
  cat("From cluster in directory:", md5_cluster, "\n")
  cat("From core facility in directory:", md5_core, "\n")
}

cat("---------------------------", "\n")
cat("\n")

##################################
# FUNCTION TO PREPROCESS MD5SUMS FILE

prep_md5 <- function(md5_dir){
  # List the files in the directory
  md5files <- list.files(md5_dir, "md5sums$", full.names = TRUE)

  # Empty data frame
  md5_df <- NULL

  # Add each md5sums data to rows in the data frame
  for (file in md5files) {
    md5_tmp <- read.table(file, stringsAsFactors = FALSE)
    md5_df <- rbind(md5_df, md5_tmp)
  }

  # Rename colnames
  colnames(md5_df) <- c("md5", "path")

  #obtain details from the file name such as lane and ID to include it in the table:
  #substitite the extension by "" (i.e. get rid of it)
  md5_df$basename <- sub(".fq.gz", "", basename(md5_df$path))

  #split the file names into their components separated by underscore (e.g. batch.lane.barcode.read)
  file_parts <- str_match(md5_df$basename, "(.*)_(L[0][0-4])_([0-9]{1,3})_([0-9])")
  md5_df$batch <- file_parts[,2]
  md5_df$lane <- file_parts[,3]
  md5_df$barcode <- file_parts[,4]
  md5_df$read <- file_parts[,5]

  return(md5_df)
}

##################################

# Data frame of generated md5sums
cluster_df <- prep_md5(md5_cluster)

# Data frame of generated md5sums
core_df <- prep_md5(md5_core)


##################################

#COMPARE MD5 VALUES OF CLUSTER VS CORE

#merge md5sums from both sources
md5_merge <- merge(core_df, cluster_df,
                   by = c("batch", "lane", "barcode", "read"),
                   all = TRUE, sort = TRUE, suffixes = c(".core", ".cluster"))
#The number of rows of the merged table must be equal to the number of rows of the core_df table
stopifnot(nrow(md5_merge) == nrow(core_df))

#Identify the md5 that do not match and get the file names
nomatch <- md5_merge$md5.core != md5_merge$md5.cluster & !is.na(md5_merge$md5.cluster)
nomatch_num <- sum(nomatch, na.rm = TRUE)
nomatch_files <-md5_merge$path.core[nomatch]

#Identify the missing md5 (fq files that did not download)
missmd5 <- is.na(md5_merge$md5.cluster)
missmd5_num <- sum(missmd5)
missmd5_files <- md5_merge$path.core[missmd5]


#All failed files
allfailed <- c(nomatch_files, missmd5_files)

# If there are failed files, save the names in a txt file.
# If not, then
if (length(allfailed)>0){
  for (i in allfailed){
    cat(i, sep = "\n", file = out_file, append = TRUE)
  }
  cat("Number of incorrect files:", nomatch_num, "\n")
  cat("Incorrect files:", nomatch_files, sep ="\n")
  cat("---------------------------", "\n")
  cat("Number of missing files:", missmd5_num, "\n")
  cat("Missing files:", missmd5_files, sep ="\n")
  cat("The name of failed fq file names were saved in", out_file, "\n")
} else {
  cat("All files passed md5sums check")
}
