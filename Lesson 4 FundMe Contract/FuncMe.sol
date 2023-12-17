// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    // this attaches PriceConverter library for all uint256 types and now they can access all func inside that lib
    using PriceConverter for uint256;

    uint256 public minSumInUsd = 5e18; // 5 * (1 * 000 000 000 000 000 000)
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        require(
            // conversionRate func is from PriceConverter lib
            msg.value.getConversionRate() >= minSumInUsd,
            "You need to spend at least 5$ worth of ETH!!!"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] =
            addressToAmountFunded[msg.sender] +
            msg.value;
    }
}
