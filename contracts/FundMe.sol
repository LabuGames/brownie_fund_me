// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] funders;
    address owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        // first number is the actual USD amount
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "Your tx value is below 50$");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() internal view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() internal view returns (uint256) {
        (,int256 answer,,,)= priceFeed.latestRoundData();
        return uint256(answer*10000000000);
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice*ethAmount) / 1000000000000000000;
        return ethAmountInUSD;
        //1041,822708050000000000
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You aren't the owner of this contract!");
        _;
    }

    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);
        for (uint256 funderIndex=0; funderIndex<funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

    }
    
    function getEntranceFee() public view returns (uint256) {
        //mimimumUSD
        uint256 mimimumUSD = 50* 10**18;
        uint256 price = getPrice();
        uint256 precision = 1* 10**18;
        return ((mimimumUSD * precision)/price) +1;

    }
    

    

    
    
}