library(tidyverse)
library(dplyr)
library(ggplot2)
library(lubridate)
install.packages("ggrepel")
library(ggrepel)   
install.packages('purr')
library(scales)
library(caret)
library(pROC)

lostada <- read.csv("C:/Users/Christina/Desktop/Advanced Data Analytics R/lost-ada/lostAda-166724931.csv")

summary(lostada)
str(lostada)
accounts_analized <- N_accounts <- nrow(lostada)

# --------------------------
#1.CHANGE SLOT TO REAL DATE
# --------------------------

# Add actual date columns to convert from seconds
#reference timestamp
reference_seconds <- 4492800
reference_datetime <- as.POSIXct("2020-07-29 15:44:51", tz = "America/Denver")

# Create new column converting seconds to datetime for laRegisteredAtSlotNo
lostada_time_changes <- lostada |>
  add_column(
    RegisteredAtDatetime = reference_datetime + 
      (lostada$laRegisteredAtSlotNo - reference_seconds),
    .after = "laRegisteredAtSlotNo"
  )

# Date/time conversion for laLastDelegationSlotNo
lostada_time_changes <- lostada_time_changes |>
  add_column(
    LastDelegationDate = reference_datetime + 
      (lostada_time_changes$laLastDelegationSlotNo - reference_seconds),
    .after = "laLastDelegationSlotNo"
  )
#Date/time conversion for laLastWithdrawalSlotNo
lostada_time_changes <- lostada_time_changes |>
  add_column(
    LastWithdrawalDate = reference_datetime + 
      (lostada_time_changes$laLastWithdrawalSlotNo - reference_seconds),
    .after = "laLastWithdrawalSlotNo"
  )
#Date/time conversion for laLastAddressOwnerActivitySlotNo
lostada_time_changes <- lostada_time_changes |>
  add_column(
    LastAddressOwnerActivityDate = reference_datetime + 
      (lostada_time_changes$laLastAddressOwnerActivitySlotNo - reference_seconds),
    .after = "laLastAddressOwnerActivitySlotNo"
  )
#Date/time conversion for laLastAddressActivitySlotNo
lostada_time_changes <- lostada_time_changes |>
  add_column(
    LastAddressActivityDate = reference_datetime + 
      (lostada_time_changes$laLastAddressActivitySlotNo - reference_seconds),
    .after = "laLastAddressActivitySlotNo"
  )

#Date/time conversion for laUnregisteredAtSlotNo
lostada_time_changes <- lostada_time_changes |>
  add_column(
    UnregisteredAtDate = reference_datetime + 
      (lostada_time_changes$laUnregisteredAtSlotNo - reference_seconds),
    .after = "laUnregisteredAtSlotNo"
  )

# --------------------------------
#2. COUNT NA VALUES IN EACH COLUMN
# --------------------------------

na_counts <- colSums(is.na(lostada))
print(na_counts)  # a lot NA in laUnregisteredAtSlotNo 

# -----------------------------------------------------
#3. COUNT NUMER OF REGISTERED AND UNREGISTARED ACCOUNTS
# -----------------------------------------------------

Registration_Count <- lostada_time_changes |>
  summarise(laAccount = n())
print(Registration_Count)   # number of registered accounts

Unregistration_Count <- lostada_time_changes |>
  summarise(Unregistration_Count = sum(is.na(laCurrentBalance)))
print(Unregistration_Count) # number of unregistered accounts

# Double check unregistered accounts
UnRegistration_Count_1 <- lostada_time_changes |>
  summarise(UnRegistration_Count_1 = Registration_Count - sum(is.na(laUnregisteredAtSlotNo)))
print(UnRegistration_Count_1)

# ----------------------------------------------------------------------
#4. TIME PLOT: NUMBER OF REGESTERED AND UNREGESTERED ACCOUNTS BY QUARTER
# ----------------------------------------------------------------------

# Change datetype and create per quarter
lostada_time_changes <- lostada_time_changes |>
  mutate(
    reg_date = as.Date(RegisteredAtDatetime),
    unreg_date = as.Date(UnregisteredAtDate),  #unregistration date column
    reg_year = year(reg_date),
    reg_quarter = quarter(reg_date),
    unreg_year = year(unreg_date),
    unreg_quarter = quarter(unreg_date),
    reg_quarter_label = if_else(!is.na(reg_date), paste0(reg_year, "-Q", reg_quarter), NA_character_),
    unreg_quarter_label = if_else(!is.na(unreg_date), paste0(unreg_year, "-Q", unreg_quarter), NA_character_)
  )

# Count registered accounts per quarter
registered <- lostada_time_changes |>
  filter(!is.na(reg_quarter_label)) |>
  count(reg_quarter_label) |>
  rename(quarter_label = reg_quarter_label, registered_n = n)

# Count unregistered accounts per quarter
unregistered <- lostada_time_changes |>
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
  geom_col(aes(y = registered_n, fill = "Registered"),width = 0.7) +
  geom_line(aes(y = unregistered_n, color = "Unregistered",group = 1), linewidth = 1.2) +
  geom_point(aes(y = unregistered_n, color = "Unregistered"), size = 2.5) +
  geom_text(aes(y = unregistered_n, label = scales::comma(unregistered_n), color = "Unregistered"),
    vjust = -0.5, size = 3) +
  labs(
    title = "Registered and Unregistered Accounts per Quarter",
    subtitle = "Number of accounts registered and unregistered during each quarter",
    x = NULL, y = "Number of Accounts",
    fill = "Status", color = "Status") +
  scale_fill_brewer(palette = "Set2") +
  scale_color_manual(values = c("Unregistered" = "#FC8D62")) +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.08))) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top",
    legend.text = element_text(size = 10))

##ANOTHER VARIANT OF PLOT

# Prepare data
plot_data <- combined |>
  pivot_longer(
    cols = c(registered_n, unregistered_n),
    names_to = "account_type",
    values_to = "number"
  ) |>
  mutate(
    account_type = recode(
      account_type,
      registered_n = "Registered",
      unregistered_n = "Unregistered"
    )
  )

# Plot
ggplot(plot_data, aes(x = quarter_label, y = number, color = account_type, group = account_type)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3) +
  geom_text(aes(label = comma(number)), vjust = -0.8, size = 3) +
  labs(
    title = "Account Registrations and Unregistrations Over Time",
    subtitle = "Quarterly number of registered and unregistered accounts",
    x = NULL, y = "Number of Accounts",
    color = "Account Status") +
  scale_color_manual(values = c(
      "Registered" = "#66C2A5",
      "Unregistered" = "#FC8D62")) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.1))) +
  theme_minimal(base_size = 12) + theme(plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11,color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title.y = element_text(margin = margin(r = 10)),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    plot.margin = margin(10, 15, 10, 10))


# --------------------------------------------------
#5. PIE DIAGRAM REGISTERED AND UNREGISTERED ACCOUNTS
# --------------------------------------------------
 
# Prepare data: count and percentage for status
summary_data <- lostada_time_changes |>
  filter(!is.na(RegisteredAtDatetime)) |>
  mutate(
    status = if_else(is.na(UnregisteredAtDate), "Still Registered", "Unregistered")
  ) |>
  count(status) |>
  mutate(
    total = sum(n),
    percent = n / total * 100,
    
# Create label
    label = paste0(status, "\n", comma(n), " (", round(percent, 1), "%)")
  )

ggplot(summary_data, aes(x = 2, y = n, fill = status)) +
  geom_col(width = 1,color = "white",linewidth = 1.5) +
  coord_polar(theta = "y") +
  geom_text(aes(label = label),position = position_stack(vjust = 0.5),size = 4.2,
    color = "black",fontface = "bold",lineheight = 1.1) +
# Empty center creates the donut
  xlim(0.5, 2.5) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Account Registration Status",
    subtitle = paste0(
      "Total accounts analyzed: ",
      comma(sum(summary_data$n))),
    fill = "Status") +
  theme_void(base_size = 14) +
  theme(plot.title = element_text(
      hjust = 0.5,face = "bold",size = 19),
    plot.subtitle = element_text(hjust = 0.5,size = 12,color = "gray40"),
    legend.position = "none")

# -------------------------------------------------------
#6. CALCULATE CURRENT TOTAL STAKE OF ADA BEFORE WE FILTER 
# laLastDelegationSlotNo,laLastWithdrawalSlotNo
# -------------------------------------------------------

str(lostada_time_changes)

# Remove column laUnregisteredAtSlotNo b/c redundant to CurrentBalance data
# Remove all other unnecessary any more columns for easy analysis 
lostada_clean <- subset(lostada_time_changes, select = -c(laUnregisteredAtSlotNo,UnregisteredAtDate,
                                          reg_date,unreg_date,reg_year,reg_quarter,unreg_year,unreg_quarter,
                                          reg_quarter_label,unreg_quarter_label))

# Remove all rows with NA in CurrentBalance data, NA means the account is unregistered
lostada_clean <- lostada_clean |>
  filter(
    !is.na(laCurrentBalance))

# Create a simpler Account ID - positioned right next to original account data for convenience
lostada_clean <- lostada_clean |>
  add_column(
    AccountID = seq_len(nrow(lostada_clean)),
    .after = "laAccount"
  )
str(lostada_clean)  # clean data

# Change NA current stake to 0
ada_with0stake <- lostada_clean |>
  mutate(
    laCurrentStake = replace_na(laCurrentStake, 0))

# Sum of total stake
ada_with0stake <- ada_with0stake |>
  add_column(
    TotalStake = ada_with0stake$laCurrentStake + ada_with0stake$laCurrentBalance
  )
final_total_stake <- sum(ada_with0stake$TotalStake)
final_total_stake

# N accounts
N_accounts <- nrow(ada_with0stake)
N_accounts

# -----------------------------------------
#7. PLOT THE TOTAL STAKE OF ADA ON ACCOUNTS
# -----------------------------------------

# Prepare cumulative ADA stake by quarter
total_stake_per_quarter <- ada_with0stake |>
  mutate(
    registration_date = as.Date(RegisteredAtDatetime),
    registration_quarter = floor_date(
      registration_date,
      "quarter"
    )
  ) |>
  filter(!is.na(registration_date)) |>
  arrange(registration_date) |>
  mutate(
    cumulative_stake = cumsum(TotalStake)
  ) |>
  group_by(registration_quarter) |>
  summarise(
    cumulative_stake = last(cumulative_stake),
    .groups = "drop"
  ) |>
  arrange(registration_quarter)


total_stake_per_quarter <- total_stake_per_quarter |>
  mutate(
    quarter_label = paste0(
      year(registration_quarter),
      "-Q",
      quarter(registration_quarter)
    ),
    quarter_label = factor(
      quarter_label,
      levels = unique(quarter_label)
    )
  )

# Plot
ggplot(total_stake_per_quarter,aes(x = quarter_label,y = cumulative_stake)) +
  geom_col(fill = "#66C2A5",width = 0.75) +
  geom_text(aes(label = paste0(round(cumulative_stake / 1e9, 1),"B")),
    vjust = -0.4,
    size = 3,
    fontface = "bold") +
  labs(
    title = "Cumulative ADA Stake of Registered Accounts",
    subtitle = "Total current stake of accounts registered up to each quarter",
    x = "Quarter",
    y = "Cumulative Stake (Billion ADA)") +
  scale_y_continuous(labels = function(x) paste0(scales::comma(x / 1e9),"B"),
    expand = expansion(mult = c(0, 0.08))) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(size = 16,face = "bold"),
    plot.subtitle = element_text(size = 11,color = "gray40"),
    axis.text.x = element_text(angle = 45,hjust = 1),
    axis.title.y = element_text(margin = margin(r = 10)),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 15, 10, 10))

# ---------------------------------------------
#8. PLOT THE GROW OF ADA STAKE DURING THE YEARS
# ---------------------------------------------

total_stake_monthly <- ada_with0stake |>
  mutate(
    snapshot_date = as.Date(RegisteredAtDatetime),
    month = floor_date(snapshot_date, unit = "month")
  ) |>
  group_by(month) |>
  summarise(
    total_stake = sum(TotalStake, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(month)

# Latest month
latest_month <- total_stake_monthly |>
  slice_tail(n = 1)

# Plot
ggplot(total_stake_monthly,
  aes(x = month, y = total_stake)) +
  geom_area(fill = "#66C2A5", alpha = 0.15) +
  geom_line(color = "#66C2A5", linewidth = 1.2) +
  geom_point(data = latest_month, Color = "#FC8D62", size = 4) +
  geom_text(data = latest_month,
    aes(label = paste0(
        comma(round(total_stake))," ADA")),
    color = "#FC8D62", fontface = "bold",
    size = 3.8, vjust = -1.2) +
  labs(
    title = "Growth of Total ADA Stake Over Time",
    subtitle = "Monthly total stake associated with registered accounts",
    x = NULL,
    y = "Total Stake (ADA)") +
  scale_x_date(
    date_breaks = "6 months",
    date_labels = "%Y-%m") +
  scale_y_continuous(
    labels = comma,
    expand = expansion(mult = c(0, 0.12))) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 15, 10, 10))

# ----------------------------------------------------------
#9. CORRELATION BETWEEN ADA STAKE AND THE AMOUNT OF ACCOUNTS
# ----------------------------------------------------------

## When more accounts were registered in a month, 
## was the total ADA stake associated with those accounts also higher?
Stake_accounts <- ada_with0stake |>
  mutate(
    snapshot_date = as.Date(RegisteredAtDatetime),
    month_date = floor_date(snapshot_date, "month")
  ) |>
  group_by(month_date) |>
  summarise(
    total_stake = sum(TotalStake, na.rm = TRUE),
    num_accounts = n(),
    avg_stake_per_account = total_stake / num_accounts,
    .groups = "drop"
  ) |>
  arrange(month_date)

# Pearson correlation
cor_result <- cor.test(
  Stake_accounts$total_stake,
  Stake_accounts$num_accounts,
  method = "pearson"
)

cor_result  # 0.199

model <- lm(
  total_stake ~ num_accounts,
  data = Stake_accounts
)

summary(model)

r_value <- cor_result$estimate
p_value <- cor_result$p.value
r_squared <- summary(model)$r.squared

# Plot
ggplot(Stake_accounts,aes(x = num_accounts,y = total_stake)) +
  geom_point(color = "#FC8D62",size = 3,alpha = 0.8) +
  geom_smooth(
    method = "lm",
    se = TRUE,
    color = "#66C2A5",
    linewidth = 1.2) +
  annotate(
    "text",
    x = Inf,
    y = Inf,
    label = paste0(
      "Pearson r = ", round(r_value, 2),
      "\nR² = ", round(r_squared, 2),
      "\np = ", format.pval(p_value, digits = 2)),
    hjust = 1.1,
    vjust = 1.3,
    size = 4,
    fontface = "bold") +
  labs(
    title = "Monthly ADA Stake vs. Number of Accounts",
    subtitle = "Relationship between monthly account registrations and associated ADA stake",
    x = "Number of Accounts Registered",
    y = "Total ADA Stake (Billion ADA)") +
  scale_y_continuous(
    labels = function(x) paste0(x / 1e9, "B")) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(size = 16,face = "bold"),
        plot.subtitle = element_text(size = 11,color = "gray40"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank())

# --------------------------------
#10. AVERAGE ADA STAKE PER ACCOUNT
# --------------------------------

avg_stake_per_account = final_total_stake / N_accounts
ggplot(Stake_accounts,aes(x = month_date,y = avg_stake_per_account)) +
  geom_line(color = "#FC8D62",Linewidth = 1.2) +
  geom_point(color = "#FC8D62",size = 2) +
  labs(
    title = "Average ADA Stake per Account Over Time",
    subtitle = "Monthly average stake among newly registered accounts",
    x = NULL,
    y = "Average ADA Stake per Account") +
  scale_y_continuous(labels = comma) +
  scale_x_date(date_breaks = "6 months",date_labels = "%Y-%m") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(size = 16,face = "bold"),
    plot.subtitle = element_text(size = 11,color = "gray40"),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank())

# ---------------------------------------------------
#11.HOW MUCH ADA DO INDIVIDUAL ACCOUNTS ACTUALLY HOLD
# ---------------------------------------------------

# Plot of distribution 
ggplot(ada_with0stake,aes(x = TotalStake)) +
  geom_histogram(bins = 50,fill = "#66C2A5",color = "white") +
  scale_x_continuous(labels = comma) +
  labs(
    title = "Distribution of ADA Stake Across Accounts",
    subtitle = "Stake distribution among registered accounts",
    x = "ADA Stake per Account",
    y = "Number of Accounts"
  ) +
  theme_minimal(base_size = 12)

# the huge bar around zero means that a very large number of accounts have zero
# or very small stake, while a relatively small number have much larger stakes.

# The distribution is strongly right-skewed on the original ADA scale, 
# meaning account sizes vary enormously.

# Use log, because distribution right skewed 
ggplot(ada_with0stake |> filter(TotalStake > 0),aes(x = TotalStake)) +
  geom_histogram(
    bins = 50,
    fill = "#FC8D62",
    color = "white") +
  scale_x_log10(
    labels = scales::label_number(
      big.mark = ",")) +
  labs(
    title = "Distribution of ADA Stake Across Accounts",
    subtitle = "Account stake distribution shown on a logarithmic scale",
    x = "ADA Stake per Account",
    y = "Number of Accounts") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(size = 16,face = "bold"),
    plot.subtitle = element_text(
      size = 11,
      color = "gray40"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank())

# Statistical calculation
stake_summary <- ada_with0stake |>
  summarise(
    accounts = n(),
    total_stake = sum(TotalStake, na.rm = TRUE),
    mean_stake = mean(TotalStake, na.rm = TRUE),
    median_stake = median(TotalStake, na.rm = TRUE),
    min_stake = min(TotalStake, na.rm = TRUE),
    max_stake = max(TotalStake, na.rm = TRUE), 
    mean_median_ratio = mean_stake / median_stake)
stake_summary

# Create account-size groups
ada_groups <- ada_with0stake |>
  mutate(
    stake_group = cut(
      TotalStake,
      breaks = c(
        -Inf,
        0,
        1000,
        10000,
        100000,
        1000000,
        10000000,
        100000000,
        Inf
      ),
      labels = c(
        "0 ADA",
        "1–999 ADA",
        "1K–9.9K ADA",
        "10K–99.9K ADA",
        "100K–999.9K ADA",
        "1M–9.9M ADA",
        "10M–99.9M ADA",
        "100M+ ADA"
      ),
      right = TRUE
    )
  )

# Summarize each group
stake_groups_summary <- ada_groups |>
  group_by(stake_group) |>
  summarise(
    accounts = n(),
    total_stake = sum(TotalStake, na.rm = TRUE),
    mean_stake = mean(TotalStake, na.rm = TRUE),
    median_stake = median(TotalStake, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    share_accounts = accounts / sum(accounts),
    share_stake = total_stake / sum(total_stake)
  )
stake_groups_summary

# Plot the number of accounts by size
ggplot(stake_groups_summary,
  aes(x = stake_group,y = accounts)) +
  geom_col(fill = "#66C2A5") +
  geom_text(aes(label = scales::percent(share_accounts, accuracy = 0.1)),
    vjust = -0.4,
    size = 3.2,
    fontface = "bold") +
  labs(
    title = "Distribution of Accounts by ADA Stake Size",
    subtitle = "Share of accounts in each stake category",
    x = "ADA Stake per Account",
    y = "Number of Accounts") +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.08))) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(
      size = 16,
      face = "bold"),
    plot.subtitle = element_text(
      size = 11,
      color = "gray40"),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank())

# Plot share of accounts and share of stake
stake_groups_plot <- stake_groups_summary |>
  select(
    stake_group,
    share_accounts,
    share_stake
  ) |>
  pivot_longer(
    cols = c(share_accounts, share_stake),
    names_to = "measure",
    values_to = "share"
  ) |>
  mutate(
    measure = recode(
      measure,
      share_accounts = "Share of Accounts",
      share_stake = "Share of Total ADA"
    )
  )
ggplot(stake_groups_plot,
  aes(
    x = stake_group,
    y = share,
    fill = measure
  )
) +
  geom_col(
    position = position_dodge(width = 0.75),
    width = 0.7
  ) +
  geom_text(
    aes(
      label = scales::percent(share, accuracy = 0.1)
    ),
    position = position_dodge(width = 0.75),
    vjust = -0.4,
    size = 2.8
  ) +
  labs(
    title = "Account Distribution vs. ADA Stake Distribution",
    subtitle = "Comparison of account share and share of total ADA by account size",
    x = "ADA Stake per Account",
    y = "Share",
    fill = NULL
  ) +
  scale_fill_manual(
    values = c(
      "Share of Accounts" = "#66C2A5",
      "Share of Total ADA" = "#FC8D62"
    )
  ) +
  scale_y_continuous(
    labels = scales::percent,
    expand = expansion(mult = c(0, 0.1))
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      size = 16,
      face = "bold"
    ),
    plot.subtitle = element_text(
      size = 11,
      color = "gray40"
    ),
    axis.text.x = element_text(
      angle = 45,
      hjust = 1
    ),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top"
  )

# ---------------------------------------------
#12.PLOT: HOW MANY ACCOUNTS DELEGATE ADA TO SPO
# ---------------------------------------------

ada_with0stake |>
  summarise(
    total_accounts = n(),
    delegated = sum(!is.na(LastDelegationDate)),
    not_delegated = sum(is.na(LastDelegationDate))
  )

# Pie: how many accounts delegate ada to spo
# Prepare data: count and percentage for status
# Prepare data: delegated vs. not delegated
percentage_of_delegation <- ada_with0stake |>
  mutate(status = if_else(is.na(LastDelegationDate),"Not Delegated","Delegated to SPO")) |>
  count(status) |>
  mutate(total = sum(n),percent = n / total * 100,label = paste0(status,"\n",comma(n)," (",
      round(percent, 1),
      "%)"
    )
  )

# Pie
ggplot(percentage_of_delegation,aes(x = 2, y = n, fill = status)) +
  geom_col(width = 1,color = "white",linewidth = 1.5) +
  coord_polar(theta = "y") +
  geom_text(aes(label = label),position = position_stack(vjust = 0.5),
    size = 4.2,color = "black",fontface = "bold",lineheight = 1.1) +
  xlim(0.5, 2.5) +
  scale_fill_manual(values = c(
      "Delegated to SPO" = "#66C2A5",
      "Not Delegated" = "#FC8D62")) +
  labs(
    title = "Delegation of ADA to SPO",
    subtitle = paste0(
      "Total accounts analyzed: ",
      comma(sum(percentage_of_delegation$n))),
    fill = "Status") +
  theme_void(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5,face = "bold",size = 19),
    plot.subtitle = element_text(hjust = 0.5,size = 12,color = "gray40"),
    legend.position = "none")


# Plot of monthly delegation
# Prepare monthly delegation counts
delegation_per_month <- ada_with0stake |>
  filter(!is.na(LastDelegationDate)) |>
  mutate(
    delegation_date = as.Date(LastDelegationDate),
    month_date = floor_date(delegation_date, unit = "month")
  ) |>
  group_by(month_date) |>
  summarise(
    num_delegating_accounts = n_distinct(AccountID),
    .groups = "drop"
  ) |>
  arrange(month_date)

# Find the latest month
latest_month <- delegation_per_month |>
  slice_tail(n = 1)

# Plot
ggplot(delegation_per_month,aes(x = month_date,y = num_delegating_accounts)) +
  geom_area(fill = "#66C2A5",alpha = 0.15) +
  geom_line(color = "#66C2A5",linewidth = 1.3) +
  geom_point(color = "#66C2A5",size = 2.5) +
  geom_point(data = latest_month,color = "#FC8D62",size = 4) +
  geom_text(data = latest_month,aes(label = paste0("Latest: ",comma(num_delegating_accounts))),
    color = "#FC8D62",
    fontface = "bold",
    size = 3.8,
    vjust = -1.2) +
  labs(
    title = "Accounts by Last Recorded Delegation Date",
    subtitle = "Monthly number of accounts with a recorded delegation date",
    x = NULL,
    y = "Number of Accounts") +
    scale_x_date(date_breaks = "6 months",date_labels = "%Y-%m") +
    scale_y_continuous(labels = comma,expand = expansion(mult = c(0, 0.12))) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(size = 16,face = "bold"),
    plot.subtitle = element_text(size= 11,color = "gray40"),
    axis.text.x = element_text(angle = 45,hjust = 1),
    axis.title.y = element_text(margin = margin(r = 10)),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 15, 10, 10))

# ----------------------------------------------------------------
#13. CALCULATE ACTIVE STAKE (this stake will grow because of APY%)
# ----------------------------------------------------------------

# Filter accounts who didn't delegate ADA and TotalStake >=1
ada_with_activestake <- ada_with0stake |>
  filter(
    !is.na(laLastDelegationSlotNo),
    TotalStake >= 1
  )

# Calculate Active Stake and add column
ada_with_activestake <- ada_with_activestake |>
  add_column(
    ActiveStake = ada_with_activestake$laCurrentStake + ada_with_activestake$laCurrentBalance
  )
current_delegated_ada <- sum(ada_with_activestake$ActiveStake, na.rm = TRUE) #sum of Active ADA Stake that will growth in the future 
nrow(ada_with_activestake) #number of delegated accounts

# -------------------------------------------------------------
#14.SHOW THE AMOUNT OF DELEGATED ADA ON THE ACCOUNTS IN 5 YEARS
# -------------------------------------------------------------

# Summary of delegation
five_years_ago <- 2020-07-29
delegation_summary <- ada_with_activestake %>%
  filter(as.Date(LastDelegationDate) >= five_years_ago) %>%
  mutate(
    delegation_year = year(as.Date(LastDelegationDate))
  ) %>%
  group_by(delegation_year) %>%
  summarise(
    num_accounts = n_distinct(AccountID),
    active_stake = sum(ActiveStake, na.rm = TRUE)
  ) %>%
  arrange(delegation_year)
print(delegation_summary)

# Find scaling factor between the two measures
scale_factor <- max(delegation_summary$num_accounts / 1000, na.rm = TRUE) / 
  max(delegation_summary$active_stake / 1e9, na.rm = TRUE)

# Plot
ggplot(delegation_summary, aes(x = factor(delegation_year))) +
  geom_col(aes(y = num_accounts / 1000),fill = "#FC8D62", alpha = 0.7) +
  geom_line(aes(y = (active_stake / 1e9) * scale_factor, group = 1),
    color = "#66C2A5", size = 1.5) +
  geom_point(aes(y = (active_stake / 1e9) * scale_factor),color = "#66C2A5", size = 3) +
  scale_y_continuous(name = "Number of Accounts (thousands)",
    sec.axis = sec_axis(~ . / scale_factor, name = "Total Active Stake (Billions ADA)")) +
  labs(x = "Year",
    title = "Delegated Accounts and Total ADA Active Stake (Yearly)",
    caption = "Accounts shown in thousands; Stake in billions ADA") +
  theme_minimal(base_size = 13) +
  theme(
    axis.title.y.left = element_text(color = "#FC8D62", size = 12, face = "bold"),
    axis.title.y.right = element_text(color = "#66C2A5", size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", size = 14))

# -----------------------------------------------------------------
#15. SHOW THE GROWTH OF ADA IN CURRENT DELEGATED ACCAUNTS TILL 2030
# -----------------------------------------------------------------

# Illustrative annual staking return assumptions
growth_projection <- expand.grid(
  year = 2026:2030,
  apy = c(0.015, 0.02, 0.025, 0.03)) |>
  as_tibble() |>
  mutate(
    years = year - 2026,
    projected_ada = current_delegated_ada * (1 + apy)^years,
    scenario = paste0(apy * 100, "% APY"))

# Plot
ggplot(growth_projection,
  aes(
    x = year,
    y = projected_ada,
    color = scenario,
    group = scenario)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3) +
  scale_y_continuous(
    labels = function(x) paste0(comma(x / 1e9), "B")) +
  scale_x_continuous(
    breaks = 2026:2030) +
  scale_color_manual(
    values = c(
      "1.5% APY" = "#FFD92F",
      "2% APY" = "#66C2A5",
      "2.5% APY" = "#FC8D62",
      "3% APY" = "#8DA0CB")) +
  labs(
    title = "Projected Growth of ADA in Currently Delegated Accounts",
    subtitle = "Illustrative projections under 1.5%–3% annual staking return assumptions",
    x = "Year",
    y = "Projected ADA",
    color = "Assumed APY") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top")

growth_projection |>
  filter(year == 2030) |>
  select(scenario, projected_ada) |>
  mutate(
    projected_ada_billions = projected_ada / 1e9)

# -------------------------------------------------------------------------------
#16. CALCULATE THE NUMBER OF POTENCIALLY LOST ACCAUNTS AND THE AMOUNT OF LOST ADA
# -------------------------------------------------------------------------------

# Chose like evidence these 3 columns RegisteredAtDatetime, LastWithdrawalDate, LastDelegationDate
# 3 years non activity
cutoff_date <- Sys.Date() - years(3)

lost_accounts_3col3years <- ada_with_activestake |>
  mutate(
    last_activity_date = pmax(RegisteredAtDatetime,LastWithdrawalDate,LastDelegationDate,na.rm = TRUE),
    inactive_flag = if_else(last_activity_date <= cutoff_date,1,0)) # 1 inactive account and 0 active

# Total number lost accounts and sum of lost ADA stake
summary_lost_accounts_3col3years <- lost_accounts_3col3years |>
  filter(inactive_flag == 1) |>
  summarise(
    num_lost_accounts = n(),
    total_lost_stake = sum(ActiveStake, na.rm = TRUE))

print(summary_lost_accounts_3col3years)

# Chose like evidence these 5 columns RegisteredAtDatetime, LastWithdrawalDate, LastDelegationDate, 
# LastAddressOwnerActivityDate, LastAddressActivityDate
# 3 years non activity

lost_accounts_5col3years <- ada_with_activestake |>
  mutate(
    last_activity_date = pmax(RegisteredAtDatetime,LastWithdrawalDate,LastDelegationDate,
                              LastAddressOwnerActivityDate, LastAddressActivityDate, na.rm = TRUE),
    inactive_flag_2 = if_else(last_activity_date <= cutoff_date,1,0)) # 1 inactive account and 0 active

# Total number lost accounts and sum of lost ADA stake
summary_lost_accounts_5col3years <- lost_accounts_5col3years |>
  filter(inactive_flag_2 == 1)|>
  summarise(
    num_lost_accounts = n(),
    total_lost_stake = sum(ActiveStake, na.rm = TRUE))

print(summary_lost_accounts_5col3years)

# --------------------------------------------------------------------------
#17. SHOW THE NUMBER OF POTENCIALLY LOST ACCAUNTS AND THE AMOUNT OF LOST ADA
# --------------------------------------------------------------------------

# Create comparison table
comparison_lost <- tibble(
  definition = c("3 activity indicators", "5 activity indicators"),
  lost_accounts = c(
    summary_lost_accounts_3col3years$num_lost_accounts,
    summary_lost_accounts_5col3years$num_lost_accounts),
  lost_ada = c(
    summary_lost_accounts_3col3years$total_lost_stake,
    summary_lost_accounts_5col3years$total_lost_stake))

current_delegated_ada #sum of Active ADA Stake that will growth in the future 
num_accounts_with_active_stake <- nrow(ada_with_activestake) #number of delegated accounts

comparison_lost <- comparison_lost |>
  mutate(
    account_percent = lost_accounts / num_accounts_with_active_stake * 100,
    ada_percent = lost_ada / current_delegated_ada * 100)

comparison_lost

# Plot
comparison_plot <- comparison_lost |>
  select(definition, account_percent, ada_percent) |>
  pivot_longer(cols = c(account_percent, ada_percent),
    names_to = "measure",
    values_to = "percent") |>
  mutate(measure = recode(
      measure,
      account_percent = "Share of Accounts",
      ada_percent = "Share of ADA"))

subtitle_text_forplot <- paste0("3-year inactivity criterion | ",
  scales::comma(num_accounts_with_active_stake),
  " accounts with active stake | ",
  round(current_delegated_ada / 1e9, 2),
  "B ADA currently delegated")

ggplot(
  comparison_plot,
  aes(x = definition, y = percent, fill = measure)) +
  geom_col(position = position_dodge(width = 0.7),width = 0.6) +
  geom_text(
    aes(label = paste0(round(percent, 1), "%")),
    position = position_dodge(width = 0.7),
    vjust = -0.4,
    size = 4,
    fontface = "bold") +
  scale_fill_manual(
    values = c(
      "Share of Accounts" = "#66C2A5",
      "Share of ADA" = "#FC8D62")) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Potentially Inactive Accounts and ADA",
    subtitle = subtitle_text_forplot,
    x = NULL,
    y = "Percentage",
    fill = NULL) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top")

# ---------------------------------------------------
#18.SHOW THE GROWTH OF POTENCIALLY LOST ADA TILL 2030
# ---------------------------------------------------

# Use total number lost accounts and sum of lost ADA stake according to 5 columns as evidance
current_lost_ada <- summary_lost_accounts_5col3years$total_lost_stake

# Illustrative annual staking return assumptions
growth_projection_lost_ada <- expand.grid(
  year = 2026:2030,
  apy = c(0.015, 0.02, 0.025, 0.03)) |>
  as_tibble() |>
  mutate(
    years = year - 2026,
    projected_lostada = current_lost_ada * (1 + apy)^years,
    scenario = paste0(apy * 100, "% APY"))

# Plot
ggplot(growth_projection_lost_ada,
       aes(
         x = year,
         y = projected_lostada,
         color = scenario,
         group = scenario)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3) +
  scale_y_continuous(
    labels = function(x) paste0(comma(x / 1e9), "B")) +
  scale_x_continuous(
    breaks = 2026:2030) +
  scale_color_manual(
    values = c(
      "1.5% APY" = "#FFD92F",
      "2% APY" = "#66C2A5",
      "2.5% APY" = "#FC8D62",
      "3% APY" = "#8DA0CB")) +
  labs(
    title = "Projected Growth of ADA in Potencially Lost Accounts",
    subtitle = "Illustrative projections under 1.5%–3% annual staking return assumptions",
    x = "Year",
    y = "Projected ADA",
    color = "Assumed APY") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top")

growth_projection_lost_ada |>
  filter(year == 2030) |>
  select(scenario, projected_lostada) |>
  mutate(
    projected_lostada_billions = projected_lostada / 1e9)

# ---------------------------------------------------------------------------
#17.GLM LOGISTIC REGRESSION (for prediction of potentially inactive accounts)
# ---------------------------------------------------------------------------

# Prepare the data
glm_data_for_ada <- ada_with0stake |>
  mutate(last_activity_date = pmax(
      LastWithdrawalDate,
      LastDelegationDate,
      LastAddressOwnerActivityDate,
      LastAddressActivityDate,
      na.rm = TRUE),
    cutoff_date = Sys.Date() - years(3),
    flag_for_glm = if_else(last_activity_date <= cutoff_date,1,0), # 1 = potentially inactive, 0 = active
    account_age_years = as.numeric(
      difftime(Sys.Date(),as.Date(RegisteredAtDatetime),units = "days")) / 365.25,
    # Log transformation because ADA stake is highly right-skewed
    log_total_stake = log1p(TotalStake))

# Check 
table(glm_data_for_ada$flag_for_glm)
prop.table(table(glm_data_for_ada$flag_for_glm)) * 100 #percentage

summary(glm_data_for_ada[, c(
    "flag_for_glm",
    "account_age_years",
    "TotalStake",
    "log_total_stake")])

sum(is.na(glm_data_for_ada$flag_for_glm))  # 4820 missing
sum(is.na(glm_data_for_ada$account_age_years))
sum(is.na(glm_data_for_ada$log_total_stake))

# Filter this NA
glm_data <- glm_data_for_ada |>
  filter(!is.na(flag_for_glm))

# Boxplot
# In order to avoid infinity values in log scale boxplot
boxplot_data <- glm_data |>
  filter(TotalStake > 0)

# Do potentially inactive accounts have different ADA stake levels than active accounts?
# Because ADA stake is very skewed, use a log scale
ggplot(boxplot_data,
  aes(
    x = factor(flag_for_glm),
    y = TotalStake)) +
  geom_boxplot(
    fill = "#66C2A5",
    outlier.alpha = 0.2) +
  scale_y_log10(labels = scales::comma) +
  scale_x_discrete(
    labels = c(
      "0" = "Active",
      "1" = "Potentially Inactive")) +
  labs(
    title = "ADA Stake by Account Activity Status",
    subtitle = "3-year inactivity criterion",
    x = NULL,
    y = "Total ADA Stake (log scale)") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank())

# Split the data
set.seed(123)

train_index <- sample(
  seq_len(nrow(glm_data)),
  size = 0.8 * nrow(glm_data)
)

train_data <- glm_data[train_index, ]
test_data <- glm_data[-train_index, ]

nrow(train_data)
nrow(test_data)

# Some visualization
# Histogram 1
ggplot(train_data, aes(x = account_age_years,
  fill = factor(flag_for_glm))) +
  geom_histogram(
    bins = 30,
    position = "identity",
    alpha = 0.5) +
  scale_fill_manual(
    values = c(
      "0" = "#66C2A5",
      "1" = "#FC8D62"
    ),
    labels = c(
      "0" = "Active",
      "1" = "Potentially Inactive")) +
  labs(
    title = "Account Age by Activity Status",
    subtitle = "Training data | 3-year inactivity criterion",
    x = "Account Age (years)",
    y = "Number of Accounts",
    fill = "Activity Status") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top")

# Histogram 2
ggplot(train_data,aes(
    x = log_total_stake,
    fill = factor(flag_for_glm))) +
  geom_histogram(
    bins = 25,
    position = "identity",
    alpha = 0.5) +
  scale_fill_manual(
    values = c(
      "0" = "#66C2A5",
      "1" = "#FC8D62"),
    labels = c(
      "0" = "Active",
      "1" = "Potentially Inactive")) +
  labs(
    title = "Log-Transformed ADA Stake by Activity Status",
    subtitle = "Training data | log(1 + Total Stake)",
    x = "Log(1 + Total ADA Stake)",
    y = "Number of Accounts",
    fill = "Activity Status") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "top")

# Regression
lostada_model_glm <- glm(
  flag_for_glm ~ account_age_years + log_total_stake,
  data = train_data,
  family = binomial)

summary(lostada_model_glm)

# Odds
odds_ratios <- data.frame(
Variable = names(coef(lostada_model_glm)),
Odds_Ratio = exp(coef(lostada_model_glm)),
CI_Lower = exp(confint(lostada_model_glm)[, 1]),
CI_Upper = exp(confint(lostada_model_glm)[, 2]))

odds_ratios

# Prediction
ada_test_data <- test_data |>
  mutate(
    predicted_probability = predict(
      lostada_model_glm,
      newdata = test_data,
      type = "response"),
    predicted_class = if_else(predicted_probability >= 0.5, 1, 0))

# Confusion matrix and accuracy
confusionMatrix(
  factor(ada_test_data$predicted_class, levels = c(0, 1)),
  factor(ada_test_data$flag_for_glm, levels = c(0, 1)),
  positive = "1")

roc_curve <- roc(
  ada_test_data$flag_for_glm,
  ada_test_data$predicted_probability
)
auc(roc_curve)
summary(ada_test_data$predicted_probability)

# -------------------------------------
#18. CREATE SUMMERY TABLES FOR POWER BI
# -------------------------------------

#TABLE 1: KPI table
KPI_Summary <- tibble(
  Metric = c(
    "Accounts Analyzed",
    "Registered Accounts",
    "Potentially Inactive Accounts",
    "Potentially Inactive Accounts %",
    "Total ADA",
    "Potentially Inactive ADA",
    "Potentially Inactive ADA %",
    "Active Accounts",
    "Active Stake",
    "ROC-AUC"),
  
  Value = c(
    accounts_analized,
    N_accounts,
    summary_lost_accounts_5col3years$num_lost_accounts,
    summary_lost_accounts_5col3years$num_lost_accounts / N_accounts * 100,
    final_total_stake,
    summary_lost_accounts_5col3years$total_lost_stake,
    summary_lost_accounts_5col3years$total_lost_stake / final_total_stake * 100,
    N_accounts - summary_lost_accounts_5col3years$num_lost_accounts,
    final_total_stake - summary_lost_accounts_5col3years$total_lost_stake,
    as.numeric(auc(roc_curve))))
KPI_Summary

#TABLE 2: Registration Trend
Registration_Trend <- combined |>
  mutate(
    Quarter = as.character(quarter_label)) |>
  select(
    Quarter,
    Registered_Accounts = registered_n,
    Unregistered_Accounts = unregistered_n)
Registration_Trend

Registration_Trend_Long <- Registration_Trend |>
  pivot_longer(
    cols = c(
      Registered_Accounts,
      Unregistered_Accounts),
    names_to = "Account_Status",
    values_to = "Number_of_Accounts") |>
  mutate(
    Account_Status = recode(
      Account_Status,
      Registered_Accounts = "Registered",
      Unregistered_Accounts = "Unregistered"))
Registration_Trend_Long

#TABLE 3: Account Registration Status
Registration_Status <- lostada_time_changes |>
  filter(!is.na(RegisteredAtDatetime)) |>
  mutate(
    Status = if_else(
      is.na(UnregisteredAtDate),
      "Still Registered",
      "Unregistered")) |>
  count(Status, name = "Accounts") |>
  mutate(
    Account_Share = Accounts / sum(Accounts))
Registration_Status

#TABLE 4: Stake Distribution
Stake_Distribution <- stake_groups_summary |>
  transmute(
    Stake_Group = as.character(stake_group),
    Accounts = accounts,
    Total_ADA = total_stake,
    Mean_ADA = mean_stake,
    Median_ADA = median_stake,
    Account_Share = share_accounts,
    ADA_Share = share_stake)
Stake_Distribution

Stake_Distribution_Long <- Stake_Distribution |>
  select(
    Stake_Group,
    Account_Share,
    ADA_Share) |>
  pivot_longer(
    cols = c(Account_Share, ADA_Share),
    names_to = "Measure",
    values_to = "Share") |>
  mutate(
    Measure = recode(
      Measure,
      Account_Share = "Share of Accounts",
      ADA_Share = "Share of ADA"))
Stake_Distribution_Long

#TABLE 5: Activity Status
cutoff_date <- Sys.Date() - years(3)
activity_status_5 <- ada_with_activestake |>
  mutate(
    last_activity_date = pmax(
      RegisteredAtDatetime,
      LastWithdrawalDate,
      LastDelegationDate,
      LastAddressOwnerActivityDate,
      LastAddressActivityDate,
      na.rm = TRUE),
    activity_status = if_else(
      last_activity_date <= cutoff_date,
      "Potentially inactive",
      "Active")) |>
  group_by(activity_status) |>
  summarise(
    Accounts = n(),
    ADA = sum(ActiveStake, na.rm = TRUE),
    .groups = "drop") |>
  mutate(
    Account_Percent = Accounts / sum(Accounts) * 100,
    ADA_Percent = ADA / sum(ADA) * 100)
activity_status_5

#TABLE 6: Potentially lost ADA definition sensitivity 
total_accounts <- nrow(ada_with_activestake)
total_ada <- sum(
  ada_with_activestake$ActiveStake,
  na.rm = TRUE
)
lost_ada_definition_sensitivity <- tibble(
  Definition = c(
    "3 activity indicators",
    "5 activity indicators"),
  Lost_Accounts = c(
    summary_lost_accounts_3col3years$num_lost_accounts,
    summary_lost_accounts_5col3years$num_lost_accounts),
  Lost_ADA = c(
    summary_lost_accounts_3col3years$total_lost_stake,
    summary_lost_accounts_5col3years$total_lost_stake)) |>
  mutate(
    Account_Percent =
      Lost_Accounts / total_accounts * 100,
    ADA_Percent =
      Lost_ADA / total_ada * 100)
print(lost_ada_definition_sensitivity)

#TABLE 7: Logistic Regression
model_auc <- as.numeric(
  auc(roc_curve))

# Confusion matrix
model_cm <- confusionMatrix(
  factor(
    ada_test_data$predicted_class,
    levels = c(0, 1)),
  factor(
    ada_test_data$flag_for_glm,
    levels = c(0, 1)),
  positive = "1")

Model_Metrics <- tibble(
  Metric = c(
    "ROC-AUC",
    "Accuracy",
    "Sensitivity",
    "Specificity",
    "PPV",
    "NPV",
    "Balanced Accuracy",
    "Kappa"),
  
  Value = c(
    model_auc,
    as.numeric(model_cm$overall["Accuracy"]),
    as.numeric(model_cm$byClass["Sensitivity"]),
    as.numeric(model_cm$byClass["Specificity"]),
    as.numeric(model_cm$byClass["Pos Pred Value"]),
    as.numeric(model_cm$byClass["Neg Pred Value"]),
    as.numeric(model_cm$byClass["Balanced Accuracy"]),
    as.numeric(model_cm$overall["Kappa"])))
Model_Metrics

#TABLE 8: Lorenz Curve / ADA concentration
lorenz_data_powerbi <- ada_with0stake |>
  filter(TotalStake >= 0) |>
  arrange(TotalStake) |>
  mutate(
    Cumulative_Accounts =
      row_number() / n(),
    Cumulative_ADA =
      cumsum(TotalStake) /
      sum(TotalStake, na.rm = TRUE)) |>
  select(
    Cumulative_Accounts,
    Cumulative_ADA)

x <- sort(
  ada_with0stake$TotalStake[
    !is.na(ada_with0stake$TotalStake)])

n <- length(x)

Gini_Coefficient <- (
  2 * sum(seq_along(x) * x) /
    (n * sum(x))
) - ((n + 1) / n)

Gini_Summary <- tibble(
  Metric = "Gini Coefficient",
  Value = Gini_Coefficient
)
Gini_Summary

#EXPORT ALL TABLES TO CSV
powerbi_folder <- "C:/Users/Christina/Desktop/Cardano_PowerBI"

if (!dir.exists(powerbi_folder)) {
  dir.create(powerbi_folder, recursive = TRUE)
}

write.csv(
  KPI_Summary,
  file.path(powerbi_folder, "KPI_Summary.csv"),
  row.names = FALSE)

write.csv(
  Registration_Trend,
  file.path(powerbi_folder, "Registration_Trend.csv"),
  row.names = FALSE)

write.csv(
  Registration_Trend_Long,
  file.path(powerbi_folder, "Registration_Trend_Long.csv"),
  row.names = FALSE)

write.csv(
  Registration_Status,
  file.path(powerbi_folder, "Registration_Status.csv"),
  row.names = FALSE)

write.csv(
  Stake_Distribution,
  file.path(powerbi_folder, "Stake_Distribution.csv"),
  row.names = FALSE)

write.csv(
  Stake_Distribution_Long,
  file.path(powerbi_folder, "Stake_Distribution_Long.csv"),
  row.names = FALSE)

write.csv(
  activity_status_5,
  file.path(powerbi_folder, "Activity_Status.csv"),
  row.names = FALSE
)

write.csv(
  lost_ada_definition_sensitivity,
  file.path(powerbi_folder, "Inactivity_Sensitivity.csv"),
  row.names = FALSE)

write.csv(
  Model_Metrics,
  file.path(powerbi_folder, "Model_Metrics.csv"),
  row.names = FALSE
)

write.csv(
  lorenz_data_powerbi,
  file.path(powerbi_folder, "Lorenz_Data.csv"),
  row.names = FALSE)

write.csv(
  Gini_Summary,
  file.path(powerbi_folder, "Gini_Summary.csv"),
  row.names = FALSE)

