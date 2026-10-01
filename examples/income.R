#=============================================================.
#title: "income"
#layout: "R Script"
#author: "Shaun Scholes"
#input: survey data set in Stata format
#location of script: "C:\CLAUDE\Project9\examples\income.R"
#=============================================================.

#Purpose: Estimating mean income using complex survey design features

#import relevant libraries.
library(survey)
library(srvyr)
library(dplyr)
library(haven)

#===========================================.
# Set output paths
#===========================================.

#log file in output folder with name of outcome variable (e.g. income.log).
#table file in output folder with name of outcome variable (e.g. income.txt).

data_file <- "C:/CLAUDE/Project9/data/survey_data.dta"
log_file <- "C:/CLAUDE/Project9/output/income.log"
table_file <- "C:/CLAUDE/Project9/output/income.txt"


# Start log
sink(log_file, append = FALSE, split = TRUE)

cat("--------------------------------------------------\n")
cat("Income survey analysis\n")
cat("--------------------------------------------------\n\n")

# Load the survey dataset
data <- read_dta(data_file)

# Income is the outcome variable
cat("Summary of income:\n")
print(summary(data$income))

# Treat -9 through -1 as missing to exclude from summary statistics
data$income[data$income >= -9 & data$income <= -1] <- NA

# set the Survey design using 3 variables: 
# wt_int as the sampling weight.
# psu as the primary sampling unit.
# strata as the stratification variable.

survey_design <- svydesign(
  ids = ~psu,
  strata = ~strata,
  weights = ~wt_int,
  data = data,
  nest = TRUE
)

# perform survey estimation. 
# estimate the mean income accounting for complex survey design.

income_mean <- svymean(
  ~income,
  design = survey_design,
  na.rm = TRUE
)

cat("\nSurvey mean of income:\n")
print(income_mean)


# ------------------------------------------------------------
# Publish the outputs in table form 
# Create table containing coefficient and standard error
# ------------------------------------------------------------

income_estimate <- as.numeric(coef(income_mean)[1])
income_se <- as.numeric(SE(income_mean)[1])

income_table <- data.frame(
  Estimate = income_estimate,
  SE = income_se
)

# Format estimate and SE to 2 decimal places
income_table$Estimate <- sprintf("%.2f", income_table$Estimate)
income_table$SE <- sprintf("%.2f", income_table$SE)

# Write table to income.txt
write.table(
  income_table,
  file = table_file,
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)

cat("\nResults table:\n")
print(income_table)

# Display date and time
run_datetime <- Sys.time()

cat(
  "\nRun ",
  format(run_datetime, "%d %b %Y"),
  " at ",
  format(run_datetime, "%H:%M:%S"),
  "\n",
  sep = ""
)

# close log file.

sink()

#====================
#Finished
#===================.


































