# Event Management Smart Contract

## 📌 Overview
This Solidity smart contract allows users to **create, buy, transfer, and refund tickets** for events on the Ethereum blockchain. It ensures secure and transparent event management using smart contract functionality.

## ⚙️ Features
- **Create Events**: Organizers can create events with a specified date, ticket price, and ticket count.
- **Buy Tickets**: Users can purchase tickets by sending the required Ether.
- **Transfer Tickets**: Users can transfer tickets to other addresses.
- **Cancel Events**: Organizers can cancel events, allowing ticket holders to get refunds.
- **Claim Refunds**: Users can get refunds if an event is canceled.
- **Blockchain Logs**: Uses `emit` to log important transactions for tracking.

## 🚀 Deployment
### **1. Install Dependencies**
Make sure you have Node.js and Hardhat installed:
```sh
npm install -g hardhat
```

### **2. Compile the Contract**
```sh
npx hardhat compile
```

### **3. Deploy the Contract**
Modify `deploy.js` in Hardhat and deploy to a testnet:
```sh
npx hardhat run scripts/deploy.js --network goerli
```

## 🔧 Smart Contract Functions
### **Create an Event**
```solidity
function createEvent(string calldata name, uint date, uint price, uint ticketCount) external;
```
**Parameters:**
- `name` → Name of the event.
- `date` → Event date (must be in the future).
- `price` → Ticket price in Wei.
- `ticketCount` → Total number of tickets available.

### **Buy Tickets**
```solidity
function buyTicket(uint id, uint quantity) external payable;
```
**Requirements:**
- Event must exist and not be canceled.
- Must send the correct amount of Ether.
- Sufficient tickets must be available.

### **Transfer Tickets**
```solidity
function transferTicket(uint id, uint quantity, address to) external;
```
**Requirements:**
- Sender must own the tickets.
- Event must not have already occurred.

### **Cancel an Event**
```solidity
function cancelEvent(uint id) external;
```
**Requirements:**
- Only the **event organizer** can cancel it.

### **Claim a Refund**
```solidity
function claimRefund(uint id) external;
```
**Requirements:**
- The event must be **canceled**.
- The user must own tickets for the event.

## 📜 Event Logs (Emit)
- `EventCreated(eventId, name, date, price, ticketCount);`
- `TicketPurchased(buyer, eventId, quantity);`
- `TicketTransferred(from, to, eventId, quantity);`
- `EventCancelled(eventId);`
- `RefundClaimed(user, eventId, amount);`

## 🛠️ Future Enhancements
- **Dynamic pricing** for tickets based on demand.
- **Admin role** to block fraudulent event organizers.
- **Secondary marketplace** for ticket reselling.

## 📄 License
This project is licensed under the **Unlicense**.

---
🔥 Built for **secure and decentralized event management**! 🚀

