pragma solidity >=0.7.0 <0.9.0;

contract Escrow {

    enum State {NOT_INITIATED,AWAITING_PAYMENT,AWAITING_DELIVERY,DONE}

    State public current_state;

    bool public buyerIn;
    bool public sellerIn;

    uint public price ;
    
    address public buyer;
    address payable public seller;

    constructor (address payable _seller , address payable _buyer , uint _price) {
        seller = _seller ; 
        buyer  = _buyer  ;
        price  = _price * (1 ether) ;
    }

    modifier onlyBuyer () {
        require (msg.sender == buyer , "Only Buyer Can Call This FUnction . ");
        _;
    }

    modifier escrowNotStarted () {
        require (current_state == State.NOT_INITIATED);
        _;
    }

    function initContract() escrowNotStarted public {
        if (msg.sender == buyer){
            buyerIn = true ;
        }

        if (msg.sender == seller){
            sellerIn = true ;
        }

        if(buyerIn && sellerIn){
            current_state = State.AWAITING_PAYMENT ;
        }

    }

    function deposit () onlyBuyer public payable {
        require (current_state == State.AWAITING_PAYMENT , "Already Paid .");
        require (msg.value == price , "The price is wrong .");

        current_state = State.AWAITING_DELIVERY;
    }

    function confirmDelivery () onlyBuyer public payable{
        require (current_state == State.AWAITING_DELIVERY , "Cannot Confirm Delivery .");
        seller.transfer(price);
        current_state = State.DONE;
    }

    function withdraw() onlyBuyer public payable{
        require (current_state == State.DONE , "Cannot Withdraw Before Delivery DOne");
        payable(msg.sender).transfer(price);
        current_state = State.DONE;
    }


}