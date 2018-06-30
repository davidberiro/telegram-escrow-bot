pragma solidity ^0.4.23;

Contract Escrow {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }

}