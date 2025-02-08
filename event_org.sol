// SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0 <0.9.0;

contract eventContract {
    struct Event {
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
        bool isCancelled;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;

    uint public nextid; // Event ID counter

    // Create an event
    function createEvent(
        string calldata name,
        uint date,
        uint price,
        uint ticketCount
    ) external {
        require(date > block.timestamp, "You can only organize future events");
        require(ticketCount > 100, "Minimum 100 tickets required");

        events[nextid] = Event(msg.sender, name, date, price, ticketCount, ticketCount, false);
        nextid++;
    }

    // Buy tickets
    function buyticket(uint id, uint quantity) external payable {
        require(events[id].date != 0, "Event does not exist");
        require(block.timestamp < events[id].date, "Event has already occurred");

        Event storage _events = events[id];

        require(msg.value == (_events.price * quantity), "Incorrect Ether amount");
        require(_events.ticketRemain >= quantity, "Not enough tickets available");

        _events.ticketRemain -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    // Transfer tickets to another user
    function transferTicket(uint id, uint quantity, address to) external {
        require(events[id].date != 0, "Event does not exist");
        require(block.timestamp < events[id].date, "Event has already occurred");
        require(tickets[msg.sender][id] >= quantity, "Not enough tickets to transfer");

        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;
    }

    // Cancel an event (Only organizer can cancel)
    function cancelEvent(uint id) external {
        Event storage eventDetails = events[id];

        require(eventDetails.date != 0, "Event does not exist");
        require(msg.sender == eventDetails.organizer, "Only organizer can cancel");
        require(!eventDetails.isCancelled, "Event is already cancelled");

        eventDetails.isCancelled = true;
        emit EventCancelled(id);
    }

    // Claim refund if the event is cancelled
    function claimRefund(uint id) external {
        Event storage eventDetails = events[id];

        require(eventDetails.date != 0, "Event does not exist");
        require(eventDetails.isCancelled, "Event is not cancelled");
        require(tickets[msg.sender][id] > 0, "No tickets to refund");

        uint refundAmount = tickets[msg.sender][id] * eventDetails.price;
        tickets[msg.sender][id] = 0;

        // Safe conversion for Solidity 0.5.x
        address payable recipient = address(uint160(msg.sender));
        (bool success, ) = recipient.call.value(refundAmount)("");
        require(success, "Refund failed");

        emit RefundClaimed(msg.sender, id, refundAmount);
    }

    // Allow the event organizer to withdraw remaining funds
    function withdrawFunds(uint id) external {
        Event storage eventDetails = events[id];

        require(eventDetails.date != 0, "Event does not exist");
        require(msg.sender == eventDetails.organizer, "Only organizer can withdraw funds");
        require(!eventDetails.isCancelled, "Cannot withdraw funds from cancelled event");

        uint balance = eventDetails.ticketCount * eventDetails.price;
        
        address payable organizer = address(uint160(eventDetails.organizer));
        (bool success, ) = organizer.call.value(balance)("");
        require(success, "Withdrawal failed");
    }

    // Events for Logging
    event EventCancelled(uint eventId);
    event RefundClaimed(address user, uint eventId, uint amount);
}
