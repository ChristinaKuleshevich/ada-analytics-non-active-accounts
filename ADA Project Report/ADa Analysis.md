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



!\[Summary of data](./ADA Project Report/Summary of data.png)



For convenience I changed slot numbers that in seconds to real date. Starting slot number: 4492800 (when Stacking was introduced to Cardano), which corresponds to: Jul 29, 2020 3:44:51 PM. Slot numbers increase with a duration of one second per slot.



## Calculate number of Registered and Unregistered Accounts



According to the data the amount of all accounts analyzed is 1 834 953, among them 385 369 are unregistered. Above are represent some visualization. 



!\[Registered and Unregistered Accounts](./ADA Project Report/Regist and Unregist Accounts 1.png)



!\[Registered and Unregistered Accounts](./ADA Project Report/Regist and Unregist Accounts 2.png)



!\[Registered and Unregistered Accounts](./ADA Project Report/Regist and Unregist Accounts 3.png)









