# Event Ticketing Platform

A decentralized event management and ticketing system built on the Stacks blockchain.

## Features

- **Event Creation**: Organizers can create events with pricing and capacity limits
- **Ticket Sales**: Secure ticket purchasing with automatic payment processing
- **Event Verification**: Platform validators can verify legitimate events
- **Sales Tracking**: Complete record of all ticket sales and transactions

## Smart Contract Functions

### Public Functions
- `create-event`: Create a new event with details and ticket pricing
- `purchase-ticket`: Buy tickets for events with STX payment
- `verify-event`: Mark events as verified (validator only)

### Read-Only Functions
- `get-event`: Retrieve event information and details
- `get-ticket-sale`: View individual ticket sale records
- `get-tickets-sold`: Get total tickets sold for an event

## Getting Started

1. Deploy the contract to Stacks blockchain
2. Set platform validator address
3. Organizers create events with capacity and pricing
4. Attendees purchase tickets with STX payments
5. Validator verifies legitimate events

## Error Codes

- `u1`: Invalid ticket price (must be greater than 0)
- `u2`: Event not found
- `u3`: Cannot purchase ticket for own event
- `u4`: Unauthorized validator access
- `u5`: Invalid event name
- `u6`: Invalid event details
- `u7`: Invalid capacity
- `u8`: Invalid event ID
```

**PR Title**: feat: implement decentralized event ticketing platform

**PR Description**: Adds comprehensive event ticketing system with secure payment processing, capacity management, and validator verification. Includes complete sales tracking and event management capabilities.

**README Commit**: docs: add event ticketing platform documentation

**Code Commit**: feat: implement event ticketing contract with sales tracking

**Branch Name**: feature/event-ticketing

