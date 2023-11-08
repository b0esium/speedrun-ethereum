pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }


  uint256 public constant tokensPerEth = 100;

  function buyTokens() public payable {
    yourToken.transfer(msg.sender, msg.value * 100);
    emit BuyTokens(msg.sender, msg.value, msg.value * 100);
  }

  function withdraw() public onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
  }

  function sellTokens(uint256 amount) public {
    require(yourToken.balanceOf(msg.sender) >= amount, "You do not have enough tokens");
    yourToken.transferFrom(msg.sender, address(this), amount);
    (bool success, ) = payable(msg.sender).call{value: amount / 100}("");
    emit SellTokens(msg.sender, amount, amount / 100);
  }
}
