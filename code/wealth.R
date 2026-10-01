#=============================================================.
#title: "wealth"
#layout: "R Script"
#author: "Shaun Scholes"
#input: survey data set in Stata format
#location of script: "C:\CLAUDE\Projects\Project9\code\wealth.R"
#=============================================================.

#Purpose: Estimating mean wealth using complex survey design features

#import relevant libraries.
library(survey)
library(srvyr)
library(dplyr)
library(haven)

#===========================================.
# Set output paths
#===========================================.

#log file in output folder with name of outcome variable (wealth.log).
#table file in output folder with name of outcome variable (wealth.txt).

data_file <- "C:/CLAUDE/Projects/Project9/data/survey_data.dta"
log_file <- "C:/CLAUDE/Projects/Project9/output/wealth.log"
table_file <- "C:/CLAUDE/Projects/Project9/output/wealth.txt"


# Start log
sink(log_file, append = FALSE, split = TRUE)

cat("--------------------------------------------------\n")
cat("Wealth survey analysis\n")
cat("--------------------------------------------------\n\n")

# Load the survey dataset
data <- read_dta(data_file)

# Confirm the outcome variable exists before proceeding
if (!"wealth" %in% names(data)) {
  sink()
  stop("Variable 'wealth' not found in dataset.")
}

# Wealth is the outcome variable
cat("Summary of wealth:\n")
print(summary(data$wealth))

# Treat -9 through -1 as missing to exclude from summary statistics
data$wealth[data$wealth >= -9 & data$wealth <= -1] <- NA

cat("\nSummary of wealth (negative codes set to missing):\n")
print(summary(data$wealth))

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
# estimate the mean wealth accounting for complex survey design.

wealth_mean <- svymean(
  ~wealth,
  design = survey_design,
  na.rm = TRUE
)

cat("\nSurvey mean of wealth:\n")
print(wealth_mean)


# ------------------------------------------------------------
# Publish the outputs in table form
# Create table containing coefficient and standard error
# ------------------------------------------------------------

wealth_estimate <- as.numeric(coef(wealth_mean)[1])
wealth_se <- as.numeric(SE(wealth_mean)[1])

wealth_table <- data.frame(
  Estimate = wealth_estimate,
  SE = wealth_se
)

# Format estimate and SE to 2 decimal places
wealth_table$Estimate <- sprintf("%.2f", wealth_table$Estimate)
wealth_table$SE <- sprintf("%.2f", wealth_table$SE)

# Write table to wealth.txt
write.table(
  wealth_table,
  file = table_file,
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)

cat("\nResults table:\n")
print(wealth_table)

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
