pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        //Validate buy amount
        require(msg.value > 0, "Buy amount must be larger than 0");

        uint YourTokenAmount = msg.value * tokensPerEth;
        require(yourToken.balanceOf(address(this)) >= YourTokenAmount);

        bool sent = yourToken.transfer(msg.sender, YourTokenAmount);
        require(sent, "Failed to transfer token");

        emit BuyTokens(msg.sender, msg.value, YourTokenAmount);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public {
        //Validate sell amount
        require(_amount > 0, "Must sell a token amount greater than 0");
        uint256 allowance = yourToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");

        bool tokenSent = yourToken.transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(tokenSent, "Failed to transfer tokens");

        (bool ethSent, ) = msg.sender.call{value: _amount / tokensPerEth}("");
        require(ethSent, "Failed to send back eth");

        emit SellTokens(msg.sender, _amount / tokensPerEth, _amount);
    }
}
