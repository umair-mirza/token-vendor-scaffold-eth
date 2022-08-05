pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  uint256 public constant tokensPerEth = 100;

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:

  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "Send ETH to buy some tokens");

    uint256 amountToBuy = msg.value * tokensPerEth;

    // check if the Vendor Contract has enough amount of tokens for the transaction
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract has not enough tokens in its balance");

    // Transfer token to the msg.sender
    (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer token to user");

    // emit the event
    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

  function withdraw() public onlyOwner {
    //Get the amount of Eth stored in this contract
    uint256 amount = address(this).balance;

    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Failed to send Ether");

  }

  // ToDo: create a sellTokens(uint256 _amount) function:

  function sellTokens(uint256 _amount) public {
    
    //Check if the user has enough coins to sell
    uint256 ownerBalance = yourToken.balanceOf(msg.sender);
    require(ownerBalance >= _amount, "Your balance is less than the amount you want to sell");

    //Check if the Vendor contract has enough Eth to pay
    uint256 amountOfEth = _amount / tokensPerEth;
    require(address(this).balance >= amountOfEth, "Vendor does not have enough Eth to purchase the coins");

    //After getting approval, Vendor contract will call transferFrom
    (bool success) = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(success, "transaction failed");

    //Send the Eth to user
    (bool sent, ) = msg.sender.call{value: amountOfEth}("");
    require(sent, "Failed to send Eth to user");
  }

}
