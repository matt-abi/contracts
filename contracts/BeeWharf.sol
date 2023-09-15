// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ICurrencyReceiver } from "./interfaces/ICurrencyReceiver.sol";
import { Administered } from "./Administered.sol";

contract BeeWharf is ICurrencyReceiver, Administered {

    using SafeERC20 for IERC20;

    constructor () {
    }

    function pay(
        address currency,
        uint256 amount,
        string calldata orderId
    ) external override {
        require(currency != address(0),"currency fail");
        require(amount > 0 ,"amount fail");
        IERC20(currency).safeTransferFrom(msg.sender,address(this),amount);
        emit Pay(currency,msg.sender,amount,orderId);
    }

    function withdraw(
        address[] calldata currency,
        uint256[] calldata amount,
        string calldata billId
    ) external override onlyMember {
        require(currency.length > 0,"currency fail");
        require(currency.length == amount.length,"currency or amount fail");

        address to = msg.sender;

        for(uint256 i=0;i<currency.length;i++) {
            require(amount[i] > 0, "amount fail");
            IERC20(currency[i]).safeTransfer(to,amount[i]);
        }
        
        emit Withdraw(currency,amount,to,billId);
    }

    function refund(
        address[] calldata currency,
        uint256[] calldata amount,
        address[] calldata to,
        string[] calldata orderId
    ) external override onlyMember {

        require(currency.length > 0,"currency fail");
        require(currency.length == amount.length,"amount fail");
        require(currency.length == to.length,"to fail");
        require(currency.length == orderId.length,"orderId fail");

        for(uint256 i=0;i<currency.length;i++) {
            require(amount[i] > 0, "amount fail");
            IERC20(currency[i]).safeTransfer(to[i],amount[i]);
        }
        
        emit Refund(currency,amount,to,orderId);
    }

    function balanceOf(
        address currency
    ) external view override returns (uint256) {
        require(currency != address(0),"currency fail");
        return IERC20(currency).balanceOf(address(this));
    }
}