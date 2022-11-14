pragma solidity ^0.5.0;
// pragma solidity ^0.8.11;

contract Auction {
    address payable public beneficiary;

    // Current state of the auction. You can create more variables if needed
    address public highestBidder;
    uint public highestBid;
    bool private aucEnd=false;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Constructor
    constructor() public {
        beneficiary = msg.sender;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() public payable {


        require(!aucEnd,"Auction has ended!");
        // TODO If the bid is not higher than highestBid, send the
        // money back. Use "require"
        // string memory s="A higher bid has already been placed. Current Bid: "+highestBid;
        require(msg.value>highestBid,"A higher bid has already been placed.");

        // TODO update state
        uint lbid = highestBid;
        address lbidder = highestBidder;
        highestBid = msg.value;
        highestBidder = msg.sender;

        // TODO store the previously highest bid in pendingReturns. That bidder
        // will need to trigger withdraw() to get the money back.
        // For example, A bids 5 ETH. Then, B bids 6 ETH and becomes the highest bidder. 
        // Store A and 5 ETH in pendingReturns. 
        // A will need to trigger withdraw() later to get that 5 ETH back.
        pendingReturns[lbidder]+=lbid;

        // Sending back the money by simply using
        // highestBidder.send(highestBid) is a security risk
        // because it could execute an untrusted contract.
        // It is always safer to let the recipients
        // withdraw their money themselves.
        
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {

        // TODO send back the amount in pendingReturns to the sender. Try to avoid the reentrancy attack. Return false if there is an error when sending
        uint refund = pendingReturns[msg.sender];
        require(refund>0,"You don't have anything to withdraw.");
        // if(refund>0){
        pendingReturns[msg.sender]=0;
        if(!msg.sender.send(refund)){
            pendingReturns[msg.sender]=refund;
            return false;
        }
        // }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() public {
        // TODO make sure that only the beneficiary can trigger this function. Use "require"
        require(!aucEnd,"Auction has ended!");
        require(msg.sender==beneficiary,"Auction cannot be closed by this account!");
        aucEnd=true;
        // TODO send money to the beneficiary account. Make sure that it can't call this auctionEnd() multiple times to drain money
        beneficiary.transfer(highestBid);
    }
}