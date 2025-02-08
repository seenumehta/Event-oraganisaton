//SPDX-License-Identifier : Unlicense
pragma solidity >= 0.5.0 <0.9.0;
contract eventContract {
   struct Event{
    address organizer;
    string name;
    uint date;
    uint price;
    uint ticketCount;
    uint ticketRemain;
    bool isCancelled;
   }
   mapping(uint=>Event) public events;
   mapping(address=>mapping (uint=>uint)) public tickets;

   uint public nextid; //eventsID
   
   function createEvent(string calldata name,uint date,uint price,uint ticketCount)  external  {
    require(date>block.timestamp,"YOU CAN ORGANIZE FOR FUTURE");
    require(ticketCount>100 ,"you can organise if you can create more than 100 tickets");
    events[nextid] = Event(msg.sender,name,date,price,ticketCount,ticketCount , false);
    nextid++ ;
   }
   function buyticket(uint id ,uint quantity) external payable  {

    require(events[id].date != 0 ,"Event doest exist");

    require(block.timestamp < events[id].date,"event has already occured");

    Event storage _events = events[id];

    require(msg.value==(_events.price*quantity),"ether is not enough");

    require(_events.ticketRemain>=quantity,"not enough tickets");
    _events.ticketRemain -=quantity;
    tickets[msg.sender][id]+=quantity;

   }
   //transfer function to shareing ticket;
   function transferTicket(uint id,uint quantity,address to) external{

    require(events[id].date != 0 ,"Event doest exist");

    require(block.timestamp < events[id].date,"event has already occured");
    
    require(tickets[msg.sender][id] >= quantity,"you have not enough ticket");
    tickets[msg.sender][id] -= quantity;
    tickets[to][id] += quantity;


   }

   // Event Cancellation
function cancelEvent(uint id) external {
    Event storage eventDetails = events[id];

    require(eventDetails.date != 0, "Event does not exist");
    require(msg.sender == eventDetails.organizer, "Only organizer can cancel");
    require(!eventDetails.isCancelled, "Event is already cancelled");

    eventDetails.isCancelled = true;
    emit EventCancelled(id);
}

// Refund System
function claimRefund(uint id) external {
    Event storage eventDetails = events[id];

    require(eventDetails.date != 0, "Event does not exist");
    require(eventDetails.isCancelled, "Event is not cancelled");
    require(tickets[msg.sender][id] > 0, "No tickets to refund");

    uint refundAmount = tickets[msg.sender][id] * eventDetails.price;
    tickets[msg.sender][id] = 0;

    payable(msg.sender).transfer(refundAmount);
    emit RefundClaimed(msg.sender, id, refundAmount);
}

// Events for Logging
event EventCancelled(uint eventId);
event RefundClaimed(address user, uint eventId, uint amount);


}
