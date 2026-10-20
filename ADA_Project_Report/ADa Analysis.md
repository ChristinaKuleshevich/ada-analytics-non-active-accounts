# Potentially Lost ADA: Analyzing and Predicting Value Locked in Potentially Inactive Cardano Accounts

### Author: Christina Kuleshevich

### Date: 10/30/2026



## Introduction

Cryptocurrency is a type of digital asset that uses blockchain technology, a form of distributed ledger technology, to record and verify transactions. Cryptocurrency adoption has grown substantially in recent years, making digital assets an increasingly important area of financial and technological research.

Cardano is a blockchain platform and one of the leading cryptocurrency projects by market capitalization. Designed as a next-generation blockchain platform, Cardano supports smart contracts and the development of decentralized applications, including decentralized finance (DeFi) applications, digital tokens, and blockchain-based games.

Similar to how Ether (ETH) is the native cryptocurrency of Ethereum, ADA is the native cryptocurrency of the Cardano blockchain. ADA can be bought and sold on cryptocurrency exchanges, used to transfer value, and used to pay transaction fees. Cardano also uses a proof-of-stake consensus protocol called Ouroboros, which allows ADA holders to participate in network staking and delegate their stake to stake pool operators.

However, cryptocurrency ownership introduces a particular risk: if an owner loses access to a wallet's private keys and cannot recover them, the associated funds may become permanently inaccessible. In Cardano, delegation is separate from the private keys used to control funds. Consequently, a stake delegation may remain recorded even when an owner is no longer actively managing their wallet. If the owner has permanently lost access to the wallet, the associated ADA may remain on the blockchain without being recoverable by that owner. Where staking rewards continue to accrue, the amount associated with such a wallet may increase over time, subject to Cardano's protocol rules and the stake pool's operation.

Identifying such accounts is challenging because a lack of recent activity does not necessarily mean that an owner has lost access to a wallet. An account may remain inactive for an extended period while its owner retains control of the private keys. Therefore, inactivity should be treated as an indicator of potential inactivity or loss of access, rather than definitive proof that funds are permanently lost.

The goal of this research is to identify potentially inactive Cardano accounts based on their recorded activity history and to estimate the amount of ADA associated with these accounts. The study applies alternative inactivity definitions to examine how the results change depending on the activity indicators used. It also explores the potential future growth of the ADA associated with these accounts under different annual staking-return assumptions. The findings provide an estimate of potential ADA exposure, rather than a definitive measure of permanently lost cryptocurrency.


## Data

This study uses the lostada dataset, which contains information about Cardano ADA accounts and their recorded blockchain activity. The dataset includes variables related to account registration, staking balances, and activity dates, which can be used to investigate potentially inactive accounts.

![Summary of data](/ADA_Project_Report/Summary_of_data.png)

For convenience I changed slot numbers that in seconds to real date. Starting slot number: 4492800 (when Stacking was introduced to Cardano), which corresponds to: Jul 29, 2020 3:44:51 PM. Slot numbers increase with a duration of one second per slot.


## Calculate number of Registered and Unregistered Accounts

According to the data the amount of all accounts analyzed is 1 834 953, among them 385 369 are unregistered. Above are represent some visualization.

![Registered and Unregistered Accounts](/ADA_Project_Report/Regist_Unregist_Accounts_1.png)

![Registered and Unregistered Accounts](/ADA_Project_Report/Regist_Unregist_Accounts_2.png)

![Registered and Unregistered Accounts](/ADA_Project_Report/Regist_Unregist_Accounts_3.png)


## Calculate current total Stake of ADA

In order to calculate current total Stake of ADA I removed all Unregistered Accounts and sum two columns from the data CurrentBalance and CurrentStake. The sum is 22153020090 ADA on 1449584 Accounts.

![Cumulative ADA Stake](/ADA_Project_Report/Cumulative_ADA.png)  

![Growth of ADA](/ADA_Project_Report/Growth_ADA.png)  


## Correlation between ADA Stake and the amount of Accounts

When more accounts were registered in a month, was the total ADA stake associated with those accounts also higher? To answer on this question I calculated a correlation. 

Pearson correlation analysis was conducted to examine the relationship between the number of accounts registered in each monthly cohort and the total ADA currently associated with those accounts. 

The results indicated a weak positive correlation (r = 0.20), while the linear regression model explained approximately 4% of the variation in total ADA ((R^2 = 0.04)). The relationship was not statistically significant (p = 0.12). 

These findings suggest that the number of accounts in a registration cohort alone is not a strong predictor of the total ADA associated with that cohort. Other factors, including differences in individual account balances and the presence of large holders, may contribute to the observed variation.

![Correlation](/ADA_Project_Report/Correlation.png)

![AVG of ADA](/ADA_Project_Report/AVG_ADA.png)


## Distribution of ADA among Accounts

How much ADA do individual accounts actually hold? To answer on this question I provide distribution. The huge bar around zero means that a very large number of accounts have zero or or very small stake, while a relatively small number have much larger stakes.

The distribution is strongly right-skewed on the original ADA scale, meaning account sizes vary enormously. 

![Distribution](/ADA_Project_Report/Disrtibution.png)

For this distribution I used log scale. 

![Log of Distribution](/ADA_Project_Report/Log_Distribution.png)

Because I used a log scale, the huge range of account sizes becomes visible. The histogram looks roughly like a broad bell-shaped distribution after taking logs.

Most accounts have relatively modest ADA balances. The highest concentration is in the middle of the distribution. There is a long tail of very large accounts.
A relatively small number of accounts hold dramatically more ADA than the typical account. The mean could be misleading. Those very large accounts can have a huge effect on total ADA stake and average stake per account.
So this helps explain my previous correlation plot. Two months can have a similar number of accounts but very different total ADA stake because a relatively small number of large accounts can contribute a huge amount of ADA.

My data appear to have a structure like: many smaller accounts and relatively few very large accounts. Let's check this statement. 

![Stake Distribution Table](/ADA_Project_Report/Stake_Distribution.png)

![Stake Distribution](/ADA_Project_Report/Stake_Distribution_2.png)

![Stake and Accounts Distribution](/ADA_Project_Report/Stake_account_distribution.png)


## Delegation

For this research important part is delegation ADA to SPO. If the owner of a wallet loses his private key after delegating his ADA to a Stack Pool, that delegation persists forever. Which means the interests will compound forever unless that Stack Pool retires. Which in turn increases the amount of potencially lost ADA forever.  

Among 1 449 584 Accounts only 22 448 were not delegated and 1 427 136 were delegated to SPO. 

![Delegation](/ADA_Project_Report/Delegation.png)

![Delegation by month](/ADA_Project_Report/Delegation_month.png)

One more important fact, that we interested only in Accounts with not 0 ADA Total Stake. If so we have 1 169 509 Accounts that delegated to SPO with 22 137 218 044 ADA. 

![Delegation Summary](/ADA_Project_Report/Delegation_summary.png)

![Delegation Summary](/ADA_Project_Report/Delegation_summary_2.png)


## The growth of ADA in current Delegated Accounts till 2030

The formula of APY that used Cordano is very difficult and I don't have enough of data to calculate the growth of ADA using it. So I pretend to have a APY equal 1.5%, 2%, 2.5%, 3%.

![Projected Growth of ADA](/ADA_Project_Report/Projected_growth.png)


## Calculate the number of potencially lost Accounts and the amount of potencially lost ADA

If we chose like evidence these 3 columns: RegisteredAtDatetime, LastWithdrawalDate, LastDelegationDate and 3 years non activity, for example. So we will have like 699 288 potencially lost Accounts with 3 771 716 689 ADA. 

If we chose like evidence these 5 columns: RegisteredAtDatetime, LastWithdrawalDate, LastDelegationDate, LastAddressOwnerActivityDate, LastAddressActivityDate and 3 years non activity. We will have like 578 595 potencially lost Accounts with 3 794 754 616 ADA. 

![Inactivity Table](/ADA_Project_Report/Inactivity_table.png)

![Inactive Accounts](/ADA_Project_Report/Inactive_accounts.png)

![Projection of lost ADA](/ADA_Project_Report/Projected_lost_ADA.png)

![Projection of lost ADA](/ADA_Project_Report/Projected_lost_ADA_2.png)
















