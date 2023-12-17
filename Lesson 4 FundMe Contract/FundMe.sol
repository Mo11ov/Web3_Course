// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    // this attaches PriceConverter library for all uint256 types and now they can access all func inside that lib
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; // 5 * (1 * 000 000 000 000 000 000)

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        // sets owner of Contract so funcs can be called only by the owner!!!
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            // conversionRate func is from PriceConverter lib
            msg.value.getConversionRate() >= MINIMUM_USD,
            "You need to spend at least 5$ worth of ETH!!!"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withDraw() public onlyOwner {
        for (uint256 idx = 0; idx < funders.length; idx++) {
            address funder = funders[idx];
            addressToAmountFunded[funder] = 0;
        }

        // reseting funders array
        funders = new address[](0);

        // actually withdraw funds

        // transfer - will throws error if more than 2300 gas is used and reverts tnx
        // msg.sender = address
        // payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);

        // send - will return a bool if tnx is successfull
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed"); // reverts

        // call = lower lvl function - returns bool and data
        // (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    modifier onlyOwner() {
        //  require(msg.sender == i_owner, "Must be owner to call this func");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }

        // adds rest of the modified function
        _;
    }
}
