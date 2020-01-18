pragma solidity ^0.5.6;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20Detailed.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20Mintable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20Burnable.sol';

contract XYZToken is ERC20, ERC20Mintable , ERC20Burnable, ERC20Detailed  {
     constructor () ERC20Detailed("XYZ token","XYZ",6) public{
        _mint(msg.sender, 1e18 * 1e6);
    }
}