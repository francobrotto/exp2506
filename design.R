
############################################################
# 
#    DESIGN EFFICIENCY AND POWER ANALYSIS (SEM)
#
#    Author: Tie Franco Brotto
#    Date: 2025 July
#
############################################################

# Delete all objects in the environment (clean memory)
rm(list = ls())

# Prevent scientific notation i.e. using e powers
options(scipen = 999)

# Set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(AlgDesign)
library(lavaan)
library(future.apply)
library(MASS)
library(semPlot)


N <- 1000 # Total sample
e <- 0.10 # Main effect size

alpha <- 0.05 # Significance threshold
n_iter <- 1000 # Number of iterations of the simulation loop

# Current design
design_current <- data.frame(
  tactic_radical     = c(-1, 1, 1, 1, -1, 1),
  protest_size       = c(-1, -1, 1, -1, 1, 1),
  behav_implication  = c(-1, -1, -1, 1, 1, 1)
)

# Factors
factors <- list(
  tactic_radical    = c(-1, 1),  # No (-1), Yes (1)
  protest_size      = c(-1, 1),  # Small (-1), Large (1)
  behav_implication = c(-1, 1)   # Palestine (-1), Climate (1),
)

# Factors
factors_grid <- expand.grid(factors)

# Effects of interest (factors, linear version)
model_formula <- ~ protest_size + tactic_radical + behav_implication + tactic_radical:behav_implication 

### Step 1 = Generate D-optimal design, then compare it current design ----
opt_design <- optFederov(
  frml = model_formula,
  data = factors_grid,
  nTrials = 6,
  criterion = "D",
  nRepeats = 100   
)
design_federov <- opt_design$design
# model.matrix(model_formula, data = factors_grid)

compute_d_from_matrix_scaled <- function(X) {
  n <- nrow(X)
  k <- ncol(X)
  XtX_scaled <- t(X) %*% X / n      # Scale by number of runs
  det_XtX_scaled <- det(XtX_scaled)
  D_value <- det_XtX_scaled^(1 / k)
  return(list(D = D_value, det_scaled = det_XtX_scaled))
}

# Generate the model matrix from your design
X_manual <- model.matrix(model_formula, data = design_current)
# Compute D for your design matrix
res_manual_scaled <- compute_d_from_matrix_scaled(X_manual)

format_design_for_copy <- function(design_df) {
  cols <- names(design_df)
  cat("# Current design\n")
  cat("design_current <- data.frame(\n")
  for (i in seq_along(cols)) {
    col_vals <- paste(design_df[[i]], collapse = ", ")
    comma <- if (i < length(cols)) "," else ""
    cat(sprintf("  %-18s = c(%s)%s\n", cols[i], col_vals, comma))
  }
  cat(")\n")
}

cat("D-criterion from current design:", res_manual_scaled$D, "\n")
cat("D-criterion from optFederov:", opt_design$D, "\n")
cat("Design from optFederov:\n")
format_design_for_copy(design_federov)

### Step 2 = Simulation-Based Power for SEM Fit ----

set.seed(123)
sig_counts <- list()  # List to collect per-path significance counts

# ------------------------------------------
# 1. Experimental design matrix
# ------------------------------------------
N <- nrow(design_current)*round(N/nrow(design_current)) # Fix so that all groups have the same whole numbers
n_per_cell <- N/nrow(design_current)
# Expand to full participant-level dataset
design <- design_current[rep(1:nrow(design_current), each = n_per_cell), ]
rownames(design) <- NULL

for (i in 1:n_iter) {
  
  # ------------------------------------------
  # 2. Simulate latent variables
  # ------------------------------------------
  
  # Option 1, more realistic
  
  # Set mean cause_affinity depending on behav_implication
  cause_mu <- ifelse(design$behav_implication == 1, 4, 3)
  # Set mean activist_id depending on behav_implication
  activist_mu <- ifelse(design$behav_implication == 1, 2, 3)
  # Now simulate cause_affinity and activist_id as correlated continuous variables 1–5 scale
  Sigma <- matrix(c(1, 0.5, 0.5, 1), nrow=2)  # Covariance matrix with correlation 0.5
  latent <- data.frame(
    cause_affinity = numeric(N),
    activist_id = numeric(N)
  )
  for(i in 1:N) {
    # Simulate one bivariate normal vector with means cause_mu[i], activist_mu[i]
    sim <- mvrnorm(1, mu = c(cause_mu[i], activist_mu[i]), Sigma = Sigma)
    # Truncate between 1 and 5
    latent$cause_affinity[i] <- min(max(sim[1], 1), 5)
    latent$activist_id[i] <- min(max(sim[2], 1), 5)
  }
  # Calculate means of each DV based on regression model (linear predictors)
  mu <- cbind(
    e * latent$activist_id,
    e * latent$activist_id + -e * design$tactic_radical + e * design$protest_size,
    -e * design$behav_implication + -e * latent$cause_affinity + -e * design$tactic_radical + e * design$protest_size,
    -2*e * latent$cause_affinity + e * design$tactic_radical
  )
  # Create a matrix filled with the off-diagonal value
  Sigma_resid <- matrix(0.7, nrow = ncol(mu), ncol = ncol(mu))
  diag(Sigma_resid) <- 1
  # Simulate residual errors jointly for each case
  residuals <- mvrnorm(n = N, mu = rep(0, 4), Sigma = Sigma_resid)
  # Combine means + residuals to get observed DVs
  outcomes <- mu + residuals
  # Put in dataframe with meaningful names
  latent$env_norms_ingroup = outcomes[,1]
  latent$env_norms_outgroup = outcomes[,2]
  latent$efficacy_norms = outcomes[,3]
  latent$opposition_norms = outcomes[,4]
  
  # Option 2, more simple

  # Simulate and correlate activist_id ~~ cause_affinity
  # latent <- as.data.frame(mvrnorm(N, mu = c(0, 0), Sigma = matrix(c(1, 0.5, 0.5, 1), 2)))
  # names(latent) <- c("activist_id", "cause_affinity")
  
  # Simulate endogenous latent variables
  # latent$env_norms_ingroup <- 
  #   e * latent$activist_id + 
  #   rnorm(N, 0, 1)
  # latent$env_norms_outgroup <- 
  #   e * latent$activist_id +
  #   -e * design$tactic_radical +
  #   e * design$protest_size +
  #   rnorm(N, 0, 1)
  # latent$efficacy_norms <- 
  #   -e * design$behav_implication +
  #   -e * latent$cause_affinity +
  #   -e * design$tactic_radical +
  #   e * design$protest_size +
  #   rnorm(N, 0, 1)
  # latent$opposition_norms <- 
  #   -2 * e * latent$cause_affinity +
  #   e * design$tactic_radical +
  #   rnorm(N, 0, 1)
  
  # ------------------------------------------
  # 3. Simulate indicators for latent variables
  # ------------------------------------------
  
  # Helper to simulate 2 or 3 indicators per latent variable
  simulate_indicators <- function(latent_score, n_indicators = 3, lambda = c(0.8, 0.7, 0.6)) {
    if (length(lambda) == 1) {
      lambda <- rep(lambda, n_indicators)
    }
    indicators <- lapply(1:n_indicators, function(j) {
      lambda[j] * latent_score + rnorm(length(latent_score), 0, sqrt(1 - lambda[j]^2))
    })
    indicators <- as.data.frame(indicators)
    names(indicators) <- paste0("item", 1:n_indicators)
    
    return(indicators)
  }
  
  # For each latent variable
  ai_items <- simulate_indicators(latent$activist_id, 3)
  ca_items <- simulate_indicators(latent$cause_affinity, 3)
  ei_items <- simulate_indicators(latent$env_norms_ingroup, 3)
  eo_items <- simulate_indicators(latent$env_norms_outgroup, 3)
  en_items <- simulate_indicators(latent$efficacy_norms, 3)
  on_items <- simulate_indicators(latent$opposition_norms, 3)
  
  # Rename variables to match model
  names(ai_items) <- c("ai1", "ai2", "ai3")
  names(ca_items) <- c("ca1", "ca2", "ca3")
  names(ei_items) <- c("ei1", "ei2", "ei3")
  names(eo_items) <- c("eo1", "eo2", "eo3")
  names(en_items) <- c("en1", "en2", "en3")
  names(on_items) <- c("on1", "on2", "on3")
  
  # ------------------------------------------
  # 4. Combine into full dataset
  # ------------------------------------------
  sim_data <- cbind(
    design,
    ai_items,
    ca_items,
    ei_items,
    eo_items,
    en_items,
    on_items
  )
  sim_data$tactic_radical    <- factor(sim_data$tactic_radical)
  sim_data$protest_size      <- factor(sim_data$protest_size)
  sim_data$behav_implication <- factor(sim_data$behav_implication)
  
  # ------------------------------------------
  # 5. Fit SEM to simulated data
  # ------------------------------------------
  
  model <- '
  activist_id	       =~ ai1 + ai2 + ai3
  cause_affinity	   =~ ca1 + ca2 + ca3
  env_norms_ingroup  =~ ei1 + ei2 + ei3
  env_norms_outgroup =~ eo1 + eo2 + eo3
  efficacy_norms     =~ en1 + en2 + en3
  opposition_norms   =~ on1 + on2 + on3

  env_norms_ingroup  ~ activist_id
  env_norms_outgroup ~ activist_id + tactic_radical + protest_size
  efficacy_norms     ~ behav_implication + cause_affinity + tactic_radical + protest_size
  opposition_norms   ~ cause_affinity + tactic_radical

  cause_affinity ~~ activist_id

  env_norms_ingroup ~~ env_norms_outgroup + efficacy_norms + opposition_norms
  env_norms_outgroup ~~ efficacy_norms + opposition_norms
  efficacy_norms ~~ opposition_norms
'
  
  fit <- tryCatch({
    sem(model, data = sim_data)
  }, error = function(e) NULL)
  
  if (!is.null(fit) && lavInspect(fit, "converged")) {
    est <- parameterEstimates(fit)
    regressions <- est %>% filter(op == "~")
    
    for (i in seq_len(nrow(regressions))) {
      path_name <- paste(regressions$lhs[i], "~", regressions$rhs[i])
      if (!is.null(sig_counts[[path_name]])) {
        sig_counts[[path_name]] <- sig_counts[[path_name]] + as.integer(regressions$pvalue[i] < alpha)
      } else {
        sig_counts[[path_name]] <- as.integer(regressions$pvalue[i] < alpha)
      }
    }
  }
  
}

# STEP 5: Estimate power
empirical_power <- sapply(sig_counts, function(x) x / n_iter)
print(empirical_power)

fit <- sem(model, data = sim_data)
sem_model <- semPlot::semPlotModel(fit)

# Extract Pars dataframe
pars_df <- sem_model@Pars
# Extract Pars dataframe
vars_df <- sem_model@Vars

# Construct path labels
path_labels <- paste(pars_df$rhs, "~", pars_df$lhs)

# Initialize all estimates to zero
pars_df$est <- 0

# Identify regression edges ("->")
regression_idx <- which(pars_df$edge == "~>")

# Match regression paths to empirical_power names
match_idx <- match(path_labels[regression_idx], names(empirical_power))

# Replace only matched regression paths
pars_df$est[regression_idx[!is.na(match_idx)]] <- empirical_power[na.omit(match_idx)]

pars_df <- filter(pars_df, est > 0)
vars_df <- filter(vars_df, nchar(name) > 5)
# Reassign modified Pars data frame back into sem_model
sem_model@Pars <- pars_df
sem_model@Vars <- vars_df

# Define a custom gradient function with your breakpoints
custom_gradient <- colorRampPalette(c(
  "#d73027",  # red at 0.6
  "#fdae61",  # orange/yellow at 0.7
  "#a6d96a",  # light green at 0.8
  "#1a9850",   # dark green at 0.9
  "#1a9850"   # dark green at 1.0
))

# Create a 100-point gradient (or however fine you want it)
gradient_colors <- custom_gradient(100)

# Now map each power value to a gradient index based on fixed range [0.6, 1.0]
power_fixed <- pmin(pmax(pars_df$est, 0.6), 1.0)  # clamp to [0.6, 1.0]
power_scaled <- (power_fixed - 0.6) / (1.0 - 0.6)  # scale to [0, 1]
color_indices <- ceiling(power_scaled * 99) + 1

# Assign colors (gray fallback for NAs)
edge_colors <- ifelse(is.na(pars_df$est), "grey80", gradient_colors[color_indices])

# Manually set coordinates:
nodes <- sem_model@Vars$name
layout_coords <- matrix(NA, nrow = length(nodes), ncol = 2)
colnames(layout_coords) <- c("x", "y")
# IVs (bottom, y=1), spaced horizontally (x=1 to 5)
layout_coords[match("activist_id", nodes), ] <- c(1, 1)
layout_coords[match("tactic_radical", nodes), ] <- c(2, 1)
layout_coords[match("protest_size", nodes), ] <- c(3, 1)
layout_coords[match("cause_affinity", nodes), ] <- c(4, 1)
layout_coords[match("behav_implication", nodes), ] <- c(5, 1)
# DVs (top, y=9), spaced horizontally (x=1 to 4)
layout_coords[match("env_norms_ingroup", nodes), ] <- c(1, 9)
layout_coords[match("env_norms_outgroup", nodes), ] <- c(2.33, 9)
layout_coords[match("opposition_norms", nodes), ] <- c(3.66, 9)
layout_coords[match("efficacy_norms", nodes), ] <- c(5, 9)

n_edges <- length(sem_model@Pars$est)  # or use edge list length
label_positions <- rep(0.5, n_edges)
label_positions[c(7, 8, 10)] <- 0.7  # just examples

pretty_labels <- c(
  "Tactic",
  "Size",
  "Moral cost",
  "Identity",
  "Affinity",
  "Support (In)",
  "Support (Out)",
  "Efficacy",
  "Opposition"
)

# Set filename
filename <- paste0("semPlot_N=", N, "_e=", e, "_n_iter=", n_iter, ".pdf")

# Open PDF device with landscape 7x5 inches (width x height)
pdf(file = filename, width = 7, height = 5, paper = "special")

# Plot the model with power estimates as edge labels and widths
semPlot::semPaths(sem_model,
                  what = "est",
                  layout = layout_coords,
                  edge.label.cex = 1.1,
                  edge.label.position = label_positions,
                  nodeLabels = pretty_labels,
                  font = 2,
                  color = c(rep("#E6ECF3", 5), 
                            #rep("#EBE7F2", 3), 
                            rep("#FAF2D4", 4)),
                  edge.label.bg = "white",
                  sizeMan = 12,
                  sizeLat = 12,
                  nCharNodes = 12,
                  mar = c(4,4,4,4),
                  edge.color = edge_colors,
                  residuals = FALSE,
                  intercepts = FALSE)

dev.off()