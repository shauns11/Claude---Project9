###############################
#CLAUDE.md (Project9)
###############################
  
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Execute R script. This R script will load the Stata dataset (survey_data.dta) that is in the data folder. 
It is converted into a data frame. The task involves opening and saving a new R script in the code folder.
The user will specify the variable to be treated as the outcome variable. The example script performs survey estimation for the `income` variable. 

## File Paths

- Working directory: `C:\CLAUDE\Projects\Project9`
- R executable path: `C:\Program Files (x86)\R\R-4.6.1\bin\Rscript.exe`
- R script: `code\`
- Log files, tables, figures: `output\`
- Dataset: `data\`

## Running a R script.

- Create a new R script.

## R script Template

Follow this structure in writing the R script: 
- Import the relevant libraries
- Set output paths. There is only one dataset (survey_data.dta) in the data folder. 
The log file and table file to be given the name of the outcome variable. 
- Start the log file.
- Load the "survey_data.dta" dataset 

- Confirm the outcome variable exists in the dataset before proceeding (e.g. `summary<varname>`). If it does not exist, stop and check with the user rather than guessing a variable name.

- Set user defined values as missing for the outcome variable. Missing values 
are negative values (e.g. -9, -8 and -1)

- Use the 'svydesign' command using the survey weight, primary sampling unit (PSU) and strata variables

- Estimate survey statistics for the outcome variable using complex survey commands (e.g. `svymean`)

- Extract the coefficients for the mean and the Standard Error (SE).

- Create a table using these coefficients and use `write.table` to save the output in a text file (.txt). 

- Capture date and time, display them, then close the log file.

Relevant R commands following this structure are (in this example, the outcome variable is "income"):

```r

#import relevant libraries.
library(survey)
library(srvyr)
library(dplyr)
library(haven)
# Set path for the dataset and the outputs 
data_file <- "data/survey_data.dta"
log_file <- "output/income.log"
table_file <- "/output/income.txt"
# Start log
sink(log_file, append = FALSE, split = TRUE)
# Load the survey dataset
data <- read_dta(data_file)
# Income is the outcome variable
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
# estimate the mean income accounting for complex survey design.
income_mean <- svymean(
  ~income,
  design = survey_design,
  na.rm = TRUE
)
# Publish the outputs in table form 
# Create table containing coefficient and standard error
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
```
## Enable CLAUDE to create / edit files in R

- Permission rules are configured in `.claude\settings.json`, allowing writes/edits under `code\`, `output\`, and `data\`, plus running `Rscript.exe` from the R-4.6.1 install without repeated prompts.

- Run the script from the command line since there is no interactive RStudio session available to this agent:
   ```
   Rscript.exe code\income.r *> output\income.log
   ```
- Redirect all output to a `.log` file in `output\` 

Please add any necessary changes in settings and add relevant instructions to CLAUDE.md.

Note: On this machine, `Rscript.exe` from R-4.6.1 returns a non-zero/crash exit code on shutdown (likely a DLL conflict with another R version, 4.5.3, also installed on PATH), even though the script itself completes and produces correct output. This does not affect the log file contents.

## Examples 

- See the income.R script in the examples folder for example of workflow.


### R Conventions

- Output files (logs, tables, figures) go to `output\`.
- Datasets are in `data\`.
- `haven` is the standard package for loading `.sas7bdat`, `.sav`, and `.dta` files.

## Git and GitHub

Remote: `https://github.com/shauns11/Claude---Project9.git` (branch `main`). The GitHub CLI (`gh`) is not installed, so use plain `git` and the GitHub website.

### First-time setup (new project)

1. Create `.gitignore` in the project root **before** the first commit, so ignored files are never committed:

```text
# Secondary logs created by batch mode (/e) in the project root
/*.log

# Stata datasets (anywhere in the project)
*.dta

# R datasets (anywhere in the project)
*.rds

# Claude Code local settings
.claude/settings.json
```

2. Initialise the repository, check what will and won't be committed, then commit:

```powershell
git init -b main
git add .
git status --short             # files to be committed
git status --short --ignored   # lines starting "!!" are ignored (e.g. 01.log)
git commit -m "Initial commit"
```

3. Create an **empty** repository on github.com (no README, .gitignore or licence) and choose Public or Private.
4. Before pushing, confirm the remote exists and is empty. `git ls-remote` returns nothing for an empty repo and "Repository not found" if the URL is wrong, deleted or private without access:

```powershell
git ls-remote https://github.com/shauns11/Claude---Project9.git
```

5. Add the remote and push `main`:

```powershell
git remote add origin https://github.com/shauns11/Claude---Project9.git
git push -u origin main
git status -sb                 # should show: ## main...origin/main
```

6. Update the `Remote:` line at the top of this section.

Notes:
- Never use `git push --force` against a repository that already has history unless you intend to permanently replace it.
- Warnings like "LF will be replaced by CRLF" are Windows line-ending notices and can be ignored.

### Day-to-day

```powershell
git status                 # see what changed
git add .                  # stage changes
git commit -m "Message"    # commit
git push                   # upload to GitHub
```

### What is tracked

- Tracked: `code\` (R scripts), `output\` (logs, tables, figures), `examples\` (R scripts), `CLAUDE.md`, `.gitignore`
- Ignored (see `.gitignore`):
  - `/*.log` — root-level logs created by batch mode
  - `*.dta` — Stata datasets, anywhere in the project
  - `*.rds` — R datasets, anywhere in the project
  - `.claude/settings.json` — Claude Code local permission settings (kept on disk, not uploaded)







