// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;


  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress); // set the address of the external contract
  }

  event Stake(address, uint256); // Triggered when stake is made

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  mapping (address => uint256) public balances;

  uint256 public constant threshold = 1 ether;

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  uint256 public deadline = block.timestamp + 20 seconds;

  modifier notCompleted() {
    require(exampleExternalContract.completed() == false, "Fundraising is completed");
    _;
  }

  function stake() public payable notCompleted {
    require(block.timestamp < deadline, "Deadline is passed"); // only allow staking before the deadline
    require(msg.value > 0, "Cannot stake 0"); // only allow positive values
    balances[msg.sender] += msg.value; // update balance
    emit Stake(msg.sender, msg.value); // trigger event
  }

  function execute() public notCompleted {
    require(block.timestamp >= deadline, "Deadline not passed yet"); // only allow execution after the deadline
    require(address(this).balance >= threshold, "Threshold not attained"); // only allow execution if the threshold is met 
    exampleExternalContract.complete{value: address(this).balance}(); // call the external contract
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public notCompleted {
    require(block.timestamp >= deadline, "Deadline not passed yet"); // only allow withdrawal after the deadline
    require(balances[msg.sender] > 0, "No balance to withdraw"); // only allow withdrawal if the user has a balance
    uint256 temp = balances[msg.sender]; // avoid reetrancy attack
    balances[msg.sender] = 0; // empty user's balance
    (bool sent, ) = msg.sender.call{value: temp}(""); // send function caller's balance to his wallet
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp < deadline) {
      return deadline - block.timestamp;
    } else {
      return 0;
    }
  }

  function showCurrentTime() public view returns (uint256) {
    return block.timestamp;
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
    emit Stake(msg.sender, msg.value); // trigger event
  }
}
