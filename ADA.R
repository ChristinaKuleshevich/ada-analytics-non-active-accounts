library(tidyverse)
library(dplyr)
library(ggplot2)
library(lubridate)
install.packages("ggrepel")
library(ggrepel)   
install.packages('purr')
library(scales)
lostada <- read.csv("C:/Users/Christina/Desktop/Advanced Data Analytics R/lost-ada/lostAda-166724931.csv")

summary(lostada)
str(lostada)

#1.CHANGE SLOT TO REAL DATE

#add actual date columns to convert from seconds
#reference timestamp
reference_seconds <- 4492800
reference_datetime <- as.POSIXct("2020-07-29 15:44:51", tz = "America/Denver")
# Create new column converting seconds to datetime for laRegisteredAtSlotNo
lostada_t <- lostada |>
  add_column(
    laRegisteredAtDatetime = reference_datetime + 
      (lostada$laRegisteredAtSlotNo - reference_seconds),
    .after = "laRegisteredAtSlotNo"
  )

# Date/time conversion for laLastDelegationSlotNo
lostada_t <- lostada_t |>
  add_column(
    laLastDelegationDate = reference_datetime + 
      (lostada_t$laLastDelegationSlotNo - reference_seconds),
    .after = "laLastDelegationSlotNo"
  )
#Date/time conversion for laLastWithdrawalSlotNo
lostada_t <- lostada_t |>
  add_column(
    laLastWithdrawalDate = reference_datetime + 
      (lostada_t$laLastWithdrawalSlotNo - reference_seconds),
    .after = "laLastWithdrawalSlotNo"
  )
#Date/time conversion for laLastAddressOwnerActivitySlotNo
lostada_t <- lostada_t |>
  add_column(
    laLastAddressOwnerActivityDate = reference_datetime + 
      (lostada_t$laLastAddressOwnerActivitySlotNo - reference_seconds),
    .after = "laLastAddressOwnerActivitySlotNo"
  )
#Date/time conversion for laLastAddressActivitySlotNo
lostada_t <- lostada_t |>
  add_column(
    laLastAddressActivityDate = reference_datetime + 
      (lostada_t$laLastAddressActivitySlotNo - reference_seconds),
    .after = "laLastAddressActivitySlotNo"
  )

#Date/time conversion for laUnregisteredAtSlotNo
lostada_t <- lostada_t |>
  add_column(
    laUnregisteredAtDate = reference_datetime + 
      (lostada_t$laUnregisteredAtSlotNo - reference_seconds),
    .after = "laUnregisteredAtSlotNo"
  )

#2. Count NA values in each column
na_counts <- colSums(is.na(lostada))
print(na_counts)
# a lot NA in laUnregisteredAtSlotNo 

#3. COUNT NUMER OF REGISTERED AND UNREGISTARED ACCOUNTS
Registration_Count <- lostada_t |>
  summarise(laAccount = n())
print(Registration_Count)

Unregistration_Count <- lostada_t |>
  summarise(Unregistration_Count = sum(is.na(laCurrentBalance)))
print(Unregistration_Count)

#4. TIME PLOT: number of registrations by quarter and unregistrations accounts by quarter
#change datetype and create per quarter
lostada_t <- lostada_t |>
  mutate(
    reg_date = as.Date(laRegisteredAtDatetime),
    unreg_date = as.Date(laUnregisteredAtDate),  #unregistration date column
    reg_year = year(reg_date),
    reg_quarter = quarter(reg_date),
    unreg_year = year(unreg_date),
    unreg_quarter = quarter(unreg_date),
    reg_quarter_label = if_else(!is.na(reg_date), paste0(reg_year, "-Q", reg_quarter), NA_character_),
    unreg_quarter_label = if_else(!is.na(unreg_date), paste0(unreg_year, "-Q", unreg_quarter), NA_character_)
  )

# Count registered accounts per quarter
registered <- lostada_t |>
  filter(!is.na(reg_quarter_label)) |>
  count(reg_quarter_label) |>
  rename(quarter_label = reg_quarter_label, registered_n = n)

# Count unregistered accounts per quarter
unregistered <- lostada_t |>
  filter(!is.na(unreg_quarter_label)) |>
  count(unreg_quarter_label) |>
  rename(quarter_label = unreg_quarter_label, unregistered_n = n)

# Combine registered and unregistered counts by quarter
combined <- full_join(registered, unregistered, by = "quarter_label") |>
  replace_na(list(registered_n = 0, unregistered_n = 0)) |>
  arrange(quarter_label) |>
  mutate(quarter_label = factor(quarter_label, levels = unique(quarter_label)))

# Plot
ggplot(combined, aes(x = quarter_label)) +
  geom_col(aes(y = registered_n), fill = "steelblue") +
  geom_line(aes(y = unregistered_n, group = 1), color = "red", size = 1.2) +
  geom_point(aes(y = unregistered_n), color = "red", size = 2) +
  geom_text(aes(y = unregistered_n, label = unregistered_n), 
            color = "red", vjust = -0.5, size = 3) +  # add labels just above points
  labs(
    title = "Registered and Unregistered Accounts per Quarter",
    x = "Quarter",
    y = "Number of Accounts"
  ) +
  theme_minimal() +
  scale_y_continuous(labels = scales::comma) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#5. PIE DIAGRAM REGISTERED AND UNREGISTERED ACCOUNTS
 
# Prepare data: count and percentage for status
summary_data <- lostada_t |>
  filter(!is.na(laRegisteredAtDatetime)) |>
  mutate(
    status = if_else(is.na(laUnregisteredAtDate), "Still Registered", "Unregistered")
  ) |>
  count(status) |>
  mutate(
    total = sum(n),
    percent = n / total * 100,
    # Create label like in ADA pie chart
    label = paste0(status, "\n", comma(n), " (", round(percent, 1), "%)")
  )

# Plot 
ggplot(summary_data, aes(x = "", y = n, fill = factor(status))) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0) +
  
  # Labels inside pie slices
  geom_text(
    aes(label = label),
    position = position_stack(vjust = 0.5),
    size = 5,
    color = "black",
    fontface = "bold"
  ) +
  
  # Use Set2 color palette for fill, mapped by status
  scale_fill_brewer(palette = "Set2") +
  
  labs(
    title = "🔍 Account Registration Status",
    subtitle = paste0("📦 Total Registered Accounts: ", comma(sum(summary_data$n))),
    fill = "Status"
  ) +
  
  theme_void(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "none"
  )

#6. CALCULATE CURRENT TOTAL STAKE OF ADA BEFORE WE FILTER laLastDelegationSlotNo,laLastWithdrawalSlotNo
str(lostada_t)
#remove column laUnregisteredAtSlotNo b/c redundant to CurrentBalance data
#remove all other unnecessary any more columns for easy analysis 
lostada1 <- subset(lostada_t, select = -c(laUnregisteredAtSlotNo,laUnregisteredAtDate,
                                          reg_date,unreg_date,reg_year,reg_quarter,unreg_year,unreg_quarter,
                                          reg_quarter_label,unreg_quarter_label))

#remove all rows with NA in CurrentBalance data, NA means the accaunt is unregistered
lostada1 <- lostada1 |>
  filter(
    !is.na(laCurrentBalance))
#create a simpler Account ID - positioned right next to original account data for convenience
lostada1 <- lostada1 |>
  add_column(
    laAccountID = seq_len(nrow(lostada1)),
    .after = "laAccount"
  )
str(lostada1)  # clean data

#change NA current stake to 0
ada_with0stake <- lostada1
ada_with0stake$laCurrentStake[is.na(ada_with0stake$laCurrentStake)] <- 0

ada_with0stake <- ada_with0stake |>
  add_column(
    laTotalStake = ada_with0stake$laCurrentStake + ada_with0stake$laCurrentBalance
  )
sum(ada_with0stake$laTotalStake)

#plot the TOTAL stake on accounts
# Prepare data with quarter
total_stake_per_quarter <- ada_with0stake |>
  mutate(
    snapshot_date = as.Date(laRegisteredAtDatetime),  
    year = year(snapshot_date),
    quarter = quarter(snapshot_date),
    quarter_label = paste0(year, "-Q", quarter)
  ) |>
  group_by(quarter_label) |>
  summarise(total_stake = sum(laTotalStake, na.rm = TRUE)) |>
  ungroup() |>
  arrange(quarter_label) |>
  mutate(quarter_label = factor(quarter_label, levels = unique(quarter_label)))

# Plot
ggplot(total_stake_per_quarter, aes(x = quarter_label, y = total_stake)) +
  geom_col(fill = "#1f78b4") +
  geom_text(
    aes(label = scales::comma(round(total_stake))),
    hjust = 1.1, 
    vjust = 1.1,
    angle = 90,
    color = "white",     
    size = 2.7,
    fontface = "bold"
  ) +
  labs(
    title = "Total Stake of ADA per Quarter on Accounts",
    x = "Quarter",
    y = "Total Stake (ADA)"
  ) +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# plot
# Find the latest point for annotation
latest_point <- total_stake_per_quarter %>%
  slice_tail(n = 1)
# Line + point plot
ggplot(total_stake_per_quarter, aes(x = quarter_label, y = total_stake, group = 1)) +
  geom_area(fill = "#a6cee3", alpha = 0.6) +
  geom_line(color = "#1f78b4", size = 1.5) +
  geom_point(size = 3, color = "#1f78b4") +
  geom_point(data = latest_point, aes(x = quarter_label, y = total_stake), color = "red", size = 4) +
  geom_text(
    data = latest_point,
    aes(label = paste0("Latest: ", scales::comma(round(total_stake))), y = total_stake),
    vjust = -5,
    hjust = 1,
    color = "red",
    fontface = "bold",
    size = 4
  ) +
  labs(
    title = "Total Stake of ADA on Accounts Over Time",
    subtitle = "Each point represents the total stake in all accounts per quarter",
    x = "Quarter",
    y = "Total Stake (ADA)"
  ) +
  theme_minimal() +
  scale_y_continuous(labels = scales::comma) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#!!!!!HERE WE CAN plot the total grow of ADA Stake during the years 2020-2025 (every month)


#7. CORRELATION BETWEEN ADA STAKE AND THE AMOUNT OF ACCOUNTS

Stake_accounts <- ada_with0stake |>
  mutate(
    snapshot_date = as.Date(laRegisteredAtDatetime),  
    month = month(snapshot_date),
    year = year(snapshot_date),
    month_label = paste0(year, "-m", month)
  ) |>
  group_by(month_label) |>
  summarise(
    total_stake = sum(laTotalStake, na.rm = TRUE),
    num_accounts = n()  
  ) |>
  ungroup() |>
  arrange(month_label) |>
  mutate(
    month_label = factor(month_label, levels = unique(month_label)),
    cumulative_accounts = cumsum(num_accounts)  # this is your running total
  )

cor(Stake_accounts$total_stake, Stake_accounts$cumulative_accounts)

ggplot(Stake_accounts, aes(x = cumulative_accounts, y = total_stake)) +
  geom_point(size = 3, color = "steelblue") +
  geom_smooth(method = "lm", se = FALSE, color = "darkred") +
  labs(
    title = "Correlation between ADA Stake and Number of Accounts",
    x = "Number of Accounts",
    y = "Total ADA Stake"
  ) +
  scale_y_continuous(labels = scales::label_number(scale = 1e-9, suffix = "B")) +
  theme_minimal()

#Residual plot
lm_model_corel <- lm(total_stake ~ cumulative_accounts, data = Stake_accounts)
Stake_accounts <- Stake_accounts |>
  mutate(
    fitted = fitted(lm_model_corel),
    residuals = resid(lm_model_corel)
  )
ggplot(Stake_accounts, aes(x = fitted, y = residuals)) +
  geom_point(color = "darkorange", size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray30") +
  labs(
    title = "Residual Plot: Linear Model of Stake ADA vs Accounts",
    x = "Fitted Values (Predicted ADA Stake)",
    y = "Residuals"
  ) +
  theme_minimal()

#log transformation
Stake_accounts_log <- Stake_accounts |>
  mutate(
    log_stake = log(total_stake),
    log_accounts = log(cumulative_accounts)
  )

lm_log <- lm(log_stake ~ log_accounts, data = Stake_accounts_log)

# Check residuals again
Stake_accounts_log <- Stake_accounts_log |>
  mutate(
    fitted_log = fitted(lm_log),
    residuals_log = resid(lm_log)
  )

ggplot(Stake_accounts_log, aes(x = fitted_log, y = residuals_log)) +
  geom_point(color = "purple") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Residual Plot (Log-Transformed Model)",
    x = "Fitted Values (log scale)",
    y = "Residuals"
  ) +
  theme_minimal()


#8.TIME PLOT: How many accounts delegate ADA to SPO 
# Prepare delegation counts per month
delegation_per_month <- ada_with0stake |>
  filter(!is.na(laLastDelegationDate)) |>   # Only accounts that have delegated
  mutate(
    delegation_date = as.Date(laLastDelegationDate),
    year = year(delegation_date),
    month = month(delegation_date),
    month_label = paste0(year, "-m", month)
  ) |>
  group_by(month_label) |>
  summarise(
    num_delegating_accounts = n_distinct(laAccountID)
  ) |>
  ungroup() |>
  arrange(month_label) |>
  mutate(month_label = factor(month_label, levels = unique(month_label)))

# Plot
ggplot(delegation_per_month, aes(x = month_label, y = num_delegating_accounts, group = 1)) +
  geom_line(color = "steelblue", size = 1.2) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title = "Number of Accounts Delegating ADA to SPO per Month",
    x = "Monthes",
    y = "Number of Delegating Accounts"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

  
#9. CLEAN THE DATA AGAIN
#filter account who don't delegate ADA
lostada1 <- lostada1 |>
  filter(
    !is.na(laLastDelegationSlotNo),
    !is.na(laLastWithdrawalSlotNo)
  )

#Calculate Active Stake Again (this stake will grow because of APY%)
lostada1 <- lostada1 |>
  add_column(
    laActiveStake = lostada1$laCurrentStake + lostada1$laCurrentBalance
  )

#remove NA in CurrentStake
lostada1 <- lostada1 |>
  filter(
    !is.na(laCurrentStake)
  )

sum(lostada1$laActiveStake, na.rm = TRUE) #sum of Active ADA Stake that will growth in the future 
nrow(lostada1) #number of delegated accounts


#10.SHOW THE AMOUNT OF DELEGATED ADA ON THE ACCOUNTS IN 5 YEARS
five_years_ago <- 2020-07-29
delegation_summary <- lostada1 %>%
  filter(as.Date(laLastDelegationDate) >= five_years_ago) %>%
  mutate(
    delegation_year = year(as.Date(laLastDelegationDate))
  ) %>%
  group_by(delegation_year) %>%
  summarise(
    num_accounts = n_distinct(laAccountID),
    total_stake = sum(laActiveStake, na.rm = TRUE)
  ) %>%
  arrange(delegation_year)
print(delegation_summary)

# Find scaling factor between the two measures
scale_factor <- max(delegation_summary$num_accounts / 1000, na.rm = TRUE) / 
  max(delegation_summary$total_stake / 1e9, na.rm = TRUE)

ggplot(delegation_summary, aes(x = factor(delegation_year))) +
  geom_col(
    aes(y = num_accounts / 1000),
    fill = "steelblue", alpha = 0.7
  ) +
  geom_line(
    aes(y = (total_stake / 1e9) * scale_factor, group = 1),
    color = "darkred", size = 1.5
  ) +
  geom_point(
    aes(y = (total_stake / 1e9) * scale_factor),
    color = "darkred", size = 3
  ) +
  scale_y_continuous(
    name = "Number of Accounts (thousands)",
    sec.axis = sec_axis(~ . / scale_factor, name = "Total Active Stake (Billions ADA)")
  ) +
  labs(
    x = "Year",
    title = "Delegating Accounts and Total ADA Active Stake (Yearly)",
    caption = "Accounts shown in thousands; Stake in billions ADA"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.title.y.left = element_text(color = "steelblue", size = 12, face = "bold"),
    axis.title.y.right = element_text(color = "darkred", size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", size = 14)
  )


#11. SHOW THE GROWTH OF ADA IN THIS ALL ACCAUNTS IN THE FUTURE TILL 2030 
#here we do prediction of future growth based on formula APY%



#12.NOW SHOW ONLY THE TOTAL AMOUNT OF ACCOUNTS IN 2020-2022 AND THE TOTAL ACTIVE STAKE
delegation_2020_2022 <- delegation_summary %>%
  filter(delegation_year %in% c(2020, 2021, 2022)) %>%
  summarise(
    total_accounts = sum(num_accounts),
    total_active_stake = sum(total_stake)
  )
print(delegation_2020_2022)


# PIE
# Add percentage and formatted labels
delegation_summary_2020_2022 <- delegation_summary %>%
  filter(delegation_year %in% c(2020, 2021, 2022)) %>%
  mutate(
    percentage = total_stake / sum(total_stake) * 100,
    stake_label = paste0(delegation_year, "\n", round(percentage, 1), "%\n", round(total_stake / 1e9, 1), "B ADA")
  )

# Calculate totals for title
total_accounts <- sum(delegation_summary_2020_2022$num_accounts)
total_ada <- sum(delegation_summary_2020_2022$total_stake)
# Pie
ggplot(delegation_summary_2020_2022, aes(x = "", y = total_stake, fill = factor(delegation_year))) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0) +
  
  # Add fancy labels inside the pie
  geom_text(
    aes(label = stake_label),
    position = position_stack(vjust = 0.5),
    size = 5,
    color = "black",
    fontface = "bold"
  ) +
  
  scale_fill_brewer(palette = "Set2") +
  
  labs(
    title = "📊 Total Delegated ADA per Year (2020–2022)",
    subtitle = paste0("💰 Total ADA: ", comma(total_ada), 
                      "   |   👥 Total Accounts: ", comma(total_accounts)),
    fill = "Year"
  ) +
  
  theme_void(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "none"
  )

#13.NOW WE NEED TO FIND LOST ACCOUNTS (lost if not Active after 2022-07-29)
cutoff_date <- as.Date("2022-09-18")
#create a new column laLostADA with 1 lost account and 0 active
lostada1 <- lostada1 |>
  mutate(
    laLostADA = if_else(
      (laRegisteredAtDatetime <= cutoff_date) &
        (laLastDelegationDate <= cutoff_date) &
        (laLastWithdrawalDate <= cutoff_date) &
        (laLastAddressOwnerActivityDate <= cutoff_date) &
        (laLastAddressActivityDate <= cutoff_date),
      1,
      0
    )
  )


#14. CALCULATE THE NUMBER OF LOST ACCAUNTS AND THE AMOUNT OF LOST ADA
#whole table with lost accounts
lost_accounts <- lostada1 |>
  filter(laLostADA == 1)
#total number lost accounts and sum of lost ADA stake
summary_lost_accounts <- lost_accounts |>
  summarise(num_lost_accounts = sum(laLostADA), total_lost_stake = sum(laActiveStake))
print(summary_lost_accounts)

#15. SHOW PIE DIAGRAMS WITH PERSENTAGES OF DELEGATED LOST ACCOUNTS 
#PIE DIAGRAM 2020-2022 IN PERSENTAGES
delegation_2020_2022 #total DELEGETED accounts and active stake in 2020-2022
summary_lost_accounts #total lost delegeted accounts and active stake in 2020-2022

# Compute active values
num_active_accounts <- delegation_2020_2022$total_accounts - summary_lost_accounts$num_lost_accounts
total_active_ada <- delegation_2020_2022$total_active_stake - summary_lost_accounts$total_lost_stake

# Create a data frame for plotting
pie_data <- data.frame(
  category = c("Lost", "Active"),
  accounts = c(summary_lost_accounts$num_lost_accounts, num_active_accounts),
  ada = c(summary_lost_accounts$total_lost_stake, total_active_ada)
) |>
  mutate(
    percent_accounts = accounts / sum(accounts) * 100,
    percent_ada = ada / sum(ada) * 100,
    label = paste0(category,
                   "\n", round(percent_accounts, 1), "% Accounts",
                   "\n", round(percent_ada, 1), "% ADA")
  )

# Plot
ggplot(pie_data, aes(x = "", y = ada, fill = category)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  
  # Labels inside pie
  geom_text(
    aes(label = label),
    position = position_stack(vjust = 0.5),
    size = 4.5,
    fontface = "bold"
  ) +
  
  scale_fill_brewer(palette = "Set2") +
  
  labs(
    title = "📉 Lost vs Active Delegated ADA Stake and Accounts from 2020 to 2022 years",
    subtitle = paste0("💰 Total ADA: ", comma(total_ada),
                      "   |   👥 Total Accounts: ", comma(total_accounts)),
    fill = "Status"
  ) +
  theme_void(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "none"
  )

#PIE DIAGRAM 2020-2025 IN PERSENTAGES lost ada vs all ada
#whole accounts and ada in 2020-2025
ada_with0stake_num <- ada_with0stake |>
  summarise(num_accounts = n(),total_active_stake = sum(laActiveStake, na.rm = TRUE))
# Compute active values
num_active_accounts_2 <- ada_with0stake_num$num_accounts - summary_lost_accounts$num_lost_accounts
total_active_ada_2 <- ada_with0stake_num$total_active_stake - summary_lost_accounts$total_lost_stake

# Create a data frame for plotting
pie_data_2 <- data.frame(
  category = c("Lost", "Active"),
  accounts = c(summary_lost_accounts$num_lost_accounts, num_active_accounts_2),
  ada = c(summary_lost_accounts$total_lost_stake, total_active_ada_2)
) |>
  mutate(
    percent_accounts = accounts / sum(accounts) * 100,
    percent_ada = ada / sum(ada) * 100,
    label = paste0(category,
                   "\n", round(percent_accounts, 1), "% Accounts",
                   "\n", round(percent_ada, 1), "% ADA")
  )
# Plot
ggplot(pie_data_2, aes(x = "", y = ada, fill = category)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  
  # Labels inside pie
  geom_text(
    aes(label = label),
    position = position_stack(vjust = 0.5),
    size = 4.5,
    fontface = "bold"
  ) +
  
  scale_fill_brewer(palette = "Set2") +
  
  labs(
    title = "📉 Lost vs Active ADA Stake and Accounts from 2020 to 2025 years",
    subtitle = paste0("💰 Total ADA: ", comma(total_ada),
                      "   |   👥 Total Accounts: ", comma(total_accounts)),
    fill = "Status"
  ) +
  theme_void(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "none"
  )


#16.SHOW THE GROWTH OF LOST ADA IN THIS ALL LOST ACCAUNTS IN THE FUTURE TILL 2040 
#whole table with lost accounts
lost_accounts 
#total number lost accounts and sum of lost ADA stake
summary_lost_accounts 
#do the prediction of future growth based on formula APY%



#17.GLM LOGISTIC REGRESSION (with our columns of dates and with amount of all active stake)
#may be for glm regression in order to do predictions of lost accounts in future is better to chose account_age_days
#boxplot
#may be people with big amount of ada less lost their key!!!
#DEVIDE ON TRAIN DATA AND TEST DATA table lostada1
#after the regression, prediction 
#Confusion matrix and accuracy
#find statistically significant variables
#the odds
#threshold of 0.5


#18. If we have time we can also do prediction for registered and unregistered accounts (glm and everything else)