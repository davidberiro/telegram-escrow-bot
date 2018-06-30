pragma solidity ^0.4.23;

contract EscrowController {
  address public owner;

  event EscrowCreated(address sender, address receiver, uint amount, bytes32 escrowHash);
  event EscrowClosed(address sender, address receiver, uint amount, bytes32 escrowHash);
  event EscrowCanceled(address sender, address receiver, uint amount, bytes32 escrowHash);

  struct Escrow {
    address sender;
    address receiver;
    uint amount;
    bool closed;
  }

  // Records nonce of user in case of creation of multiple escrows
  mapping(address => uint) nonceNumber;

  // Mapping of escrow hash to Holdings struct
  mapping(bytes32 => Escrow) escrows;

  // Basic Constructor
  constructor() public {
    owner = msg.sender;
  }

  function makeEscrow(address _receiver) public payable {
    // getting the current nonce of the sender
    uint nonce = nonceNumber[msg.sender];

    // increasing the senders nonce for the next time
    nonceNumber[msg.sender]++;
    
    // creating the hash that will map to the escrow
    bytes32 escrowHash = keccak256(msg.sender, _receiver, msg.value, nonce);
    
    // Make sure we don't overwrite an existing escrow
    require(!escrows[escrowHash]);

    // create the new escrow, with the value being the sent amount (msg.value)
    escrows[escrowHash] = new Escrow(msg.sender, _receiver, msg.value, false);

    emit EscrowCreated(msg.sender, _receiver, msg.value, escrowHash);
  }

  function closeEscrow(bytes32 _escrowHash) public {
    // Check to make sure that the escrow hasn't already been closed
    require(!escrows[_escrowHash].closed);

    // Make sure that the sender is closing the escrow
    require(msg.sender == escrows[_escrowHash].sender);
    
    // Setting closed to be true to prevent reentrancy attack
    escrows[_escrowHash].closed = true;

    address receiver = escrows[_escrowHash].receiver;
    uint amount = escrows[_escrowHash].amount;
    
    // send the held amount to the receiver
    receiver.transfer(amount);

    emit EscrowClosed(msg.sender, receiver, amount, _escrowHash);
  }

  function cancelEscrow(bytes32 _escrowHash) public {
    // Check to make sure that the escrow hasn't already been closed/cancelled
    require(!escrows[_escrowHash].closed);

    // Make sure that the sender is cancelling the escrow
    require(msg.sender == escrows[_escrowHash].sender);
    
    // Setting closed to be true to prevent reentrancy attack
    escrows[_escrowHash].closed = true;

    address receiver = escrows[_escrowHash].receiver;
    uint amount = escrows[_escrowHash].amount;

    // sending the amount back to the sender
    msg.sender.transfer(amount);

    emit EscrowCanceled(msg.sender, receiver, amount, _escrowHash);    
  }

}