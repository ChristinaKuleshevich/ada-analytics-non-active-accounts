# Potentially Lost ADA: Analyzing and Predicting Value Locked in Potentially Inactive Cardano Accounts

## An Exploratory Analysis of Account Activity, ADA Balances, Delegation, and Inactivity Criteria


### Author: Christina Kuleshevich

### Date: 10/30/2026


## Introduction

Cryptocurrency is a type of digital asset that uses blockchain technology, a form of distributed ledger technology, to record and verify transactions. The growing adoption of digital assets has made cryptocurrency an increasingly important area of financial and technological research.

Cardano is a blockchain platform that supports smart contracts and the development of decentralized applications, including decentralized finance (DeFi) applications, digital tokens, and blockchain-based games. ADA is the native cryptocurrency of the Cardano blockchain. It can be exchanged for other assets, used to transfer value, and used to pay transaction fees. Cardano uses a proof-of-stake consensus protocol called Ouroboros, which allows ADA holders to delegate their stake to stake pool operators.

Cryptocurrency ownership introduces a particular risk: if an owner loses access to a wallet's private keys and cannot recover them, the associated funds may become permanently inaccessible. In Cardano, delegation does not require transferring ownership of ADA to a stake pool operator. Consequently, delegation information may remain recorded even when an account has no recent activity. If an owner has permanently lost access to the keys controlling an account, the associated ADA may remain on the blockchain without being recoverable by that owner. Whether additional staking rewards accrue depends on protocol rules and stake pool operation.

Identifying such accounts is challenging because a lack of recent activity does not necessarily mean that an owner has lost access to a wallet. An account may remain inactive for an extended period while its owner retains control of the private keys. Therefore, recorded inactivity should be treated as an indicator of potential inactivity or loss of access, rather than definitive proof that funds are permanently lost.

The goal of this research is to identify potentially inactive Cardano accounts based on their recorded activity history and estimate the amount of ADA associated with these accounts. The study examines account registration patterns, ADA balance distributions, and delegation status. It also compares alternative inactivity definitions to assess how the estimated number of potentially inactive accounts and their associated ADA change depending on the activity indicators used. Finally, illustrative annual-return scenarios are used to explore the potential growth of ADA associated with selected account groups.

The findings provide an estimate of potential ADA exposure rather than a definitive measurement of permanently lost cryptocurrency.

## Data and Methodology

This study uses the lostada dataset, which contains information about Cardano accounts, including registration status, ADA balances, staking information, and recorded activity dates. These variables are used to examine account characteristics and identify accounts that meet specified inactivity criteria.

Table 1. Summary of Data.

![Summary of data](/ADA_Project_Report/Summary_of_data.png)

The dataset contains 1,834,953 accounts. Of these, 1,449,584 are classified as registered and 385,369 as unregistered.

The dataset includes slot-based timestamps. These were converted into calendar dates using a reference slot and its corresponding timestamp. The reference slot used was 4,492,800, corresponding to July 29, 2020, at 15:44:51. The converted dates were used to compare registration dates with recorded activity dates.

For the analysis of ADA holdings, current balance and current stake were combined according to the study's data definition. Unregistered accounts were excluded from this calculation. The resulting combined measure was 22,153,020,090 ADA across 1,449,584 registered accounts.

The analysis consists of several stages. First, account registration status and the distribution of ADA across accounts are examined. Second, the relationship between registration cohort size and the current ADA associated with each cohort is investigated. Third, delegation patterns are analyzed. Fourth, potentially inactive accounts are identified using a three-year inactivity threshold and alternative sets of activity indicators. Finally, illustrative annual-return scenarios are used to examine possible changes in the ADA associated with selected groups of accounts.

Because the dataset records blockchain activity rather than private-key ownership or recovery status, the analysis cannot determine whether an account is permanently inaccessible. All inactivity estimates are therefore interpreted as potential inactivity, not confirmed loss.

## Registered and Unregistered Accounts

The initial analysis examines the number of registered and unregistered accounts in the dataset.

Of the 1,834,953 accounts analyzed, 1,449,584 were classified as registered and 385,369 as unregistered. These categories provide an overview of the account records available for further analysis.

Figure 1. Account Registration Status.

![Registered and Unregistered Accounts](/ADA_Project_Report/Regist_Unregist_Accounts_3.png)

Figure 2. Registered and Unregistered Accounts per Quarter

![Registered and Unregistered Accounts](/ADA_Project_Report/Regist_Unregist_Accounts_2.png)

## Current Total Stake of ADA

To estimate the current ADA associated with registered accounts, unregistered accounts were excluded and the CurrentBalance and CurrentStake variables were combined.

The resulting total was 22,153,020,090 ADA across 1,449,584 registered accounts. This figure represents the combined balance and stake measure used in this study.

The aggregate value provides context for the subsequent analyses of account size, delegation, and potential inactivity. 

Figure 3. Cumulative ADA Stake of Registered Accounts.

![Cumulative ADA Stake](/ADA_Project_Report/Cumulative_ADA.png)  

Figure 4. Growth of Total ADA Stake Over Time.

![Growth of ADA](/ADA_Project_Report/Growth_ADA.png)  

## Correlation between Total ADA Stake and the Amount of Accounts

An important question is whether registration cohorts containing more accounts also have more ADA associated with them.

To investigate this relationship, accounts were grouped by their registration month. The number of accounts in each cohort was compared with the total current ADA associated with those accounts. A Pearson correlation analysis and a simple linear regression were used to examine the relationship.

Figure 5. Relationship between the number of accounts in each registration cohort and the current ADA associated with those accounts.

![Correlation](/ADA_Project_Report/Correlation.png)

The results indicated a weak positive correlation ((r = 0.20)). The linear regression model had an (R^2) of approximately 0.04, meaning that the number of accounts in a cohort explained about 4% of the variation in the total ADA associated with that cohort. The relationship was not statistically significant at the 5% level ((p = 0.12)).

These results suggest that registration cohort size alone is not a strong predictor of the total ADA currently associated with a cohort. Differences in individual account balances and the presence of accounts with very large balances may contribute to the observed variation.

This analysis compares registration cohorts with their current associated ADA. It does not compare the number of registrations in a historical month with the total ADA staked on the Cardano network during that same month.

Figure 6. Average ADA Stake per Account Over Time.

![AVG of ADA](/ADA_Project_Report/AVG_ADA.png)

## Distribution of ADA Across Accounts

The distribution of ADA across individual accounts was examined to understand how holdings vary between accounts.

The distribution is strongly right-skewed on the original ADA scale. Many accounts have relatively small balances, while a smaller number of accounts have substantially larger balances. This wide range of account sizes makes it difficult to interpret the distribution using a linear scale alone.

Figure 7. Distribution of ADA across accounts on the original scale.

![Distribution](/ADA_Project_Report/Distribution.png)

A logarithmic scale was therefore used to make differences across a wide range of account sizes easier to visualize. The log-transformed distribution provides a clearer view of the concentration of accounts across different balance levels.

The distribution also explains why total ADA can vary substantially between registration cohorts with similar numbers of accounts. A small number of large accounts can contribute a considerable share of the total ADA associated with a cohort.

Figure 8. Distribution of ADA across accounts using a logarithmic scale.

![Log of Distribution](/ADA_Project_Report/Log_Distribution.png)

Because the mean is sensitive to extremely large values, the median ADA per account is also an important measure. Comparing mean and median balances can help distinguish a broad change in account size from changes driven by a small number of large holders.

The data appear to have a structure like: many smaller accounts and relatively few very large accounts. 

Table 2. Stake Distribution.

![Stake Distribution Table](/ADA_Project_Report/Stake_Distribution.png)

Figure 9. Distribution of Accounts by ADA Stake Size.

![Stake Distribution](/ADA_Project_Report/Stake_Distribution_2.png)

Figure 10. Account Distribution vs ADA Stake Distribution.

![Stake and Accounts Distribution](/ADA_Project_Report/Stake_account_distribution.png)

## Delegation of ADA to Stake Pool Operators

Delegation is relevant to this research because an account may continue to have a recorded stake delegation even when no recent activity is observed.

In Cardano, delegating ADA does not transfer ownership of the funds to a stake pool operator. Delegation information may remain recorded while an account is inactive. If an account owner permanently loses access to the keys controlling the account, the associated ADA may become inaccessible to that owner, even if the delegation remains recorded.

Among the 1,449,584 registered accounts in the analysis, 1,427,136 were classified as delegated to stake pool operators, while 22,448 were classified as not delegated.

Figure 11. Delegation status of registered accounts.

![Delegation](/ADA_Project_Report/Delegation.png)

Figure 12. Accounts by Last Recorded Delegation Date.

![Delegation by month](/ADA_Project_Report/Delegation_month.png)

When the analysis was restricted to delegated accounts with nonzero total ADA, 1,169,509 accounts remained, with a combined ADA measure of 22,137,218,044 ADA.

These results show that a substantial number of accounts in the dataset are associated with delegation. However, delegation alone does not establish whether an account is active, inactive, or permanently inaccessible. The inactivity criteria described in the following sections are therefore necessary to estimate the ADA associated with potentially inactive accounts.

Table 3. Delegation Summary by Year.

![Delegation Summary](/ADA_Project_Report/Delegation_summary.png)

Staking rewards may change the amount associated with an account over time, but the accumulation of rewards is not guaranteed indefinitely. It depends on protocol rules, pool operation, and other relevant conditions.

Figure 13. Delegated Accounts and Total ADA Active Stake (Yearly).

![Delegation Summary](/ADA_Project_Report/Delegation_summary_2.png)

##  Illustrative Growth Scenarios for ADA Associated with Delegated Accounts

To explore how ADA holdings could change over time, illustrative annual-return scenarios were considered for delegated accounts. The assumed annual rates were 1.5%, 2%, 2.5%, and 3%.

These rates are scenario assumptions rather than exact predictions of Cardano staking rewards. The analysis does not reproduce the full Cardano protocol reward calculation, and the results depend on the assumed rates and compounding method.

Under an annual-compounding assumption, the projected amount is calculated as:

[A_t = A_0(1+r)^t], where (A_0) is the initial ADA amount, (r) is the assumed annual return, and (t) is the number of years.

The scenarios illustrate how the amount of ADA associated with a selected group of accounts could change if the assumed returns were realized and compounded annually. Actual outcomes may differ because staking returns vary and not all delegated ADA necessarily earns the assumed rate.

Importantly, this calculation projects the potential growth of an existing ADA amount. It does not forecast how many additional accounts will become inactive in future years. It also does not establish that the accounts included in the projection are permanently inaccessible.

Figure 14. Illustrative growth scenarios for ADA under alternative annual-return assumptions.

![Projected Growth of ADA](/ADA_Project_Report/Projected_growth_ADA.png)

## Estimating Potentially Inactive Accounts and Associated ADA

A central objective of this study is to estimate the number of accounts that meet a defined inactivity criterion and the amount of ADA associated with those accounts.

For this analysis, an account is classified as potentially inactive when the most recent qualifying recorded activity is at least three years before the analysis date. This threshold is an analytical choice rather than evidence that an account owner has lost access to the account.

Two alternative sets of indicators were examined to evaluate how the results depend on the definition used.

### Alternative definition using three indicators

The first definition uses RegisteredAtDatetime, LastWithdrawalDate, and LastDelegationDate, together with a three-year threshold. Under this definition, the report identified 699,288 potentially inactive accounts associated with 3,771,716,689 ADA.

Because registration date is not itself an activity event, this definition should be interpreted as an alternative proxy based on registration and selected activity records, rather than a direct measure of the last activity date.

### Alternative definition using five indicators

The second definition includes RegisteredAtDatetime, LastWithdrawalDate, LastDelegationDate, LastAddressOwnerActivityDate, and LastAddressActivityDate, again using a three-year threshold. Under this definition, the report identified 578,595 potentially inactive accounts associated with 3,794,754,616 ADA.

Including additional activity indicators can change which accounts qualify as potentially inactive. For example, an account with no recent delegation or withdrawal may still have recorded address activity. Including such activity can therefore exclude an account from the potentially inactive group.

### Comparing the definitions

The two definitions produce different estimates of the number of potentially inactive accounts and the amount of ADA associated with them. This illustrates that the estimates are sensitive to the indicators used to define inactivity.

Table 4. Inactivity Table. 

![Inactivity Table](/ADA_Project_Report/Inactivity_table.png)

The second definition identifies fewer accounts but reports a slightly higher associated ADA total. This could occur if the accounts retained under the second definition have larger balances on average. However, the calculations should be verified using a consistent dataset, balance measure, and analysis date before drawing a firm conclusion.

Figure 15. Comparing the difinitions of Potencially Inactive Accounts and ADA.

![Inactive Accounts](/ADA_Project_Report/Inactive_accounts.png)

Neither definition proves that the identified accounts are permanently lost. The results represent ADA associated with accounts meeting the specified inactivity criteria.

## Projected Growth of ADA Associated with Potentially Inactive Accounts

In addition to estimating the current amount of ADA associated with potentially inactive accounts, this study examines how that amount could change over time under alternative annual percentage yield (APY) assumptions. This analysis illustrates the potential effect of staking returns on the ADA associated with accounts classified as potentially lost.

Four annual-return scenarios were considered: 1.5%, 2%, 2.5%, and 3%. These scenarios are illustrative assumptions rather than guaranteed returns or precise forecasts of future Cardano staking rewards. The projections assume that the selected starting amount of ADA remains associated with the identified accounts and that the assumed annual returns are applied according to the model's compounding method.

Table 5. Projected ADA Associated with Potentially Lost Accounts.

![Projection of lost ADA](/ADA_Project_Report/Projected_lost_ADA.png)

The projected amount of ADA ranges from approximately 1.905 billion ADA under the 1.5% APY scenario to 2.020 billion ADA under the 3% APY scenario. The 2% and 2.5% scenarios produce projected amounts of approximately 1.943 billion and 1.981 billion ADA, respectively.

Figure 16. Projected ADA Associated with Potentially Lost Accounts.

![Projection of lost ADA](/ADA_Project_Report/Projected_lost_ADA_2.png)

These results demonstrate that the projected amount increases as the assumed annual return rises. The difference between the lowest and highest scenarios is approximately 115.1 million ADA. This represents the difference between the scenario estimates, not a guaranteed increase in lost ADA.

The projections should be interpreted cautiously. The analysis does not establish that the accounts have permanently lost access to their private keys, nor does it predict how many additional accounts may become inactive in the future. Instead, it estimates how the ADA associated with the selected group of potentially inactive accounts could change under the specified return assumptions.

Actual outcomes may differ because staking rewards vary with protocol conditions and stake pool performance. The results are therefore best understood as scenario-based estimates of potential ADA exposure rather than definitive forecasts of permanently lost cryptocurrency.

## Exploratory Logistic Regression

As an additional analysis, logistic regression was considered to examine the relationship between account characteristics and a binary label indicating whether an account meets the three-year inactivity criterion.

The target variable was constructed from recorded activity dates. Accounts with a qualifying last activity date more than three years before the analysis date were labeled as potentially inactive, while accounts with more recent recorded activity were labeled as active. Accounts without a usable activity date were excluded from model fitting.

The model used account age and the logarithm of total ADA stake as predictors. The logarithmic transformation was applied because ADA holdings are strongly right-skewed.

The dataset was divided into training and test sets, with 80% of the observations assigned to training and 20% to testing. The logistic regression model was fitted to the training data, and its predictions were evaluated on the held-out test data using a confusion matrix and a receiver operating characteristic (ROC) curve.

Figure 17. ROC curve for the logistic regression model on the test dataset.

![ROC-curve](/ADA_Project_Report/ROC.png)

The previously calculated area under the ROC curve (AUC) was approximately 0.815. This indicates that the model showed good discrimination between accounts labeled active and potentially inactive under the study's defined criterion.

Figure 18. Confusion matrix for the logistic regression model on the test dataset.

![Confusion Matrix](/ADA_Project_Report/Confusion_matrix.png)

However, the model has an important limitation. The target variable is already determined by a rule based on recorded inactivity, and account age is structurally related to whether an account could have been inactive for three years. Consequently, the model may partly reproduce the relationship between account age and the inactivity definition rather than provide genuinely new predictive information.

The model should therefore be interpreted as exploratory analysis of a rule-based inactivity label, not as a method for detecting permanently lost ADA or determining whether account owners have lost their private keys. The rule-based classification remains the primary method for estimating the number of potentially inactive accounts and their associated ADA.

## Limitations

Several limitations should be considered when interpreting the results.

First, recorded inactivity does not establish permanent loss of access. Account owners may retain their private keys despite having no recent recorded activity.

Second, the estimates depend on the selected inactivity threshold and the activity indicators used. Alternative definitions can produce different account counts and ADA totals.

Third, the accuracy of the results depends on the completeness and consistency of the underlying activity dates and balance variables. Missing activity dates must not automatically be interpreted as evidence of inactivity.

Fourth, the distribution of ADA is strongly right-skewed. A small number of large accounts can substantially affect average balances and aggregate ADA totals. Median balances should therefore be considered alongside means.

Fifth, the annual-return scenarios are simplified illustrations. They do not reproduce all Cardano protocol reward mechanisms and should not be interpreted as precise forecasts of future staking rewards.

Finally, the logistic regression model predicts a label constructed from the study's inactivity rule. It cannot establish whether private keys are lost, and its performance should not be interpreted as evidence that permanently inaccessible accounts can be identified from these variables alone.

## Conclusion

This study examined Cardano account activity, ADA holdings, and staking delegation to estimate the amount of ADA associated with potentially inactive accounts. It also explored how alternative inactivity definitions and assumed staking returns affect the resulting estimates.

The analysis included 1,834,953 accounts, of which 1,449,584 were classified as registered. The combined current balance and stake measure for registered accounts was approximately 22.15 billion ADA, based on the definitions used in the dataset. The distribution of ADA across accounts was strongly right-skewed, indicating substantial differences in account sizes and highlighting the importance of considering both mean and median values when analyzing ADA holdings.

The relationship between registration cohort size and the current ADA associated with each cohort was weak and not statistically significant at the 5% level. This suggests that the number of accounts registered within a cohort alone does not provide a strong explanation of the total ADA currently associated with those accounts.

A central finding of this study is that estimates of potentially inactive accounts depend on the activity indicators used to define inactivity. The alternative definitions produced different numbers of accounts and different estimates of associated ADA. This demonstrates that the estimated amount of potentially inaccessible ADA is sensitive to methodological choices. The results should therefore be interpreted as estimates based on recorded activity rather than confirmed measurements of permanently lost cryptocurrency.

The study also examined the potential growth of ADA associated with the selected group of potentially lost accounts under four illustrative annual-return scenarios. The projected amount ranged from approximately 1.905 billion ADA under the 1.5% APY scenario to 2.020 billion ADA under the 3% APY scenario, a difference of approximately 115.1 million ADA. These projections illustrate how the assumed return rate can affect the estimated future amount of ADA associated with the selected accounts. However, they depend on the assumptions used in the model and should not be interpreted as guaranteed staking rewards or definitive forecasts of lost ADA.

An exploratory logistic regression model was also developed to examine the relationship between account age, ADA holdings, and a rule-based inactivity label. The model achieved an area under the ROC curve of approximately 0.815 on the test dataset. Although this indicates good discrimination between the defined classes, the outcome was constructed from recorded inactivity, and account age is closely related to the three-year criterion. Consequently, the model does not establish whether an account owner has lost access to their private keys and should not be interpreted as a model for detecting permanently lost cryptocurrency.

The main limitation of this research is that blockchain activity data cannot directly establish whether an account owner still controls their private keys. An account with no recent activity may belong to an owner who deliberately holds ADA without making transactions, while an account whose owner has permanently lost access may continue to have recorded balances or delegation information. Therefore, inactivity is an indicator of potential loss of access, not proof of permanent loss.

Overall, this study provides a framework for identifying potentially inactive Cardano accounts and estimating the ADA associated with them. The findings highlight the importance of clearly defined inactivity criteria, careful interpretation of account-level data, and transparent assumptions when projecting potential future ADA amounts. Future research could improve these estimates by using longer historical records, refining activity indicators, validating the treatment of missing dates, and developing models that predict future inactivity using appropriately timed historical observations.

Ultimately, the study demonstrates that blockchain data can help quantify the potential scale of ADA associated with inactive accounts, but additional evidence would be required to determine how much of this ADA is permanently inaccessible.

## How Cardano Wallets, Transactions, and Staking Work

To understand how ADA can become potentially inaccessible, it is useful to understand how Cardano stores and transfers ADA, how stake delegation works, and what happens when a wallet owner loses access to their private keys.

### Wallets, addresses, and transaction outputs

A wallet is a tool that allows its owner to manage ADA and authorize transactions using cryptographic keys. A wallet can control multiple addresses, and each address can be associated with transaction outputs containing ADA.

Cardano uses the unspent transaction output (UTxO) model. When a user sends ADA, the transaction consumes one or more existing unspent transaction outputs and creates new outputs. The consumed outputs are no longer available to spend, while the newly created outputs can be used in subsequent transactions.

For example, suppose Account A controls an output containing 10 ADA and wants to send 4 ADA to Account B. A transaction may consume the 10 ADA output and create a new output of 4 ADA for Account B, another output returning the remaining ADA to an address controlled by Account A, and an output or accounting adjustment for the transaction fee. The exact structure depends on the transaction.

A useful analogy is to think of unspent transaction outputs as cash that can be spent. When cash is spent, it is no longer available in its previous form. Similarly, when a UTxO is consumed, a new set of outputs is created according to the transaction.

### Stake accounts and delegation

In addition to transaction outputs, Cardano maintains stake-account information used for staking and delegation. ADA holders can delegate their stake to a stake pool operator (SPO) to participate in the network's proof-of-stake system.

Delegation does not transfer ownership of the ADA to the stake pool operator. The owner retains control of their funds and can spend their ADA, subject to the normal transaction rules. Delegation is therefore different from depositing money in a bank or transferring money to an investment manager.

Delegation may generate staking rewards, but the amount earned is variable rather than guaranteed. Rewards depend on protocol rules, stake pool performance, and other factors. The recorded delegation can also remain in place when the owner does not regularly make transactions.

### Stake pool operators and block production

Stake pool operators maintain the infrastructure used to participate in Cardano's proof-of-stake consensus protocol. They operate computers and servers that participate in block production and help maintain the blockchain.

Cardano divides time into slots and epochs. Blocks are produced in selected slots according to the protocol; a block is not guaranteed to appear in every slot. Consequently, it is more accurate to describe block production as occurring at a target rate rather than claiming that a block is created at an exact interval every time.

Transaction fees and protocol-defined monetary mechanisms contribute to the network's reward and treasury arrangements. The allocation of rewards follows Cardano's protocol rules rather than a simple fixed division of every transaction fee among all stake pool operators and delegators.

### Staking rewards and annual percentage yield

Annual percentage yield (APY) expresses an annualized rate of return that accounts for compounding under the assumptions used to calculate it. Cardano staking rewards are associated with the protocol's epoch-based reward process, with one epoch lasting approximately five days.

For a simplified illustration, suppose an account has 1,000 ADA and earns an assumed annual return of 5%. A simple annualized estimate would be 50 ADA over one year on the initial balance, before considering the actual Cardano reward mechanism. If rewards are reinvested, the amount may grow through compounding.

However, Cardano rewards are not necessarily calculated by applying a fixed daily rate to the wallet's balance every five days. Actual rewards depend on the protocol's calculations and relevant pool and delegation conditions. Therefore, a simplified APY formula should be treated as an illustrative model rather than an exact representation of Cardano's reward mechanism.

### Potentially inaccessible ADA

Every wallet relies on cryptographic keys to authorize transactions. If an owner permanently loses the keys required to control their funds and cannot recover them, the associated ADA may become inaccessible to that owner.

If the owner had delegated their stake before losing access, the delegation may remain recorded on the blockchain. Nevertheless, the persistence of a delegation does not establish that rewards will continue to accrue indefinitely. Reward amounts and eligibility depend on protocol rules and stake pool operation, and future changes to delegation or reward conditions may affect the outcome.

This creates an important challenge for blockchain analysis: an account can have no recent recorded activity while its owner still controls the keys. Conversely, an owner may have permanently lost access to an account whose delegation remains recorded.

Therefore, this study uses recorded inactivity as an indicator of potential inactivity or loss of access. It estimates the amount of ADA associated with accounts meeting the selected inactivity criteria, rather than claiming to identify definitively lost cryptocurrency.

Figure 19. Visualization how Cardano Wallets, Transactions, and Staking Work.

![Visualization how Cardano Wallets Work](/ADA_Project_Report/ADA.png)





















