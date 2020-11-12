// SPDX-License-Identifier: MIT


pragma solidity >=0.4.22 <0.7.0;
import 'OwnerProperty.sol';

contract DistributeFunding is OwnerProperty{
    address crowdfundingOwner;
    mapping ( address => uint) shares;
    address payable[] beneficiaries;    // lista de contribuitori ce vor primi o suma
    uint funds = 0;
    uint currentSharePercentage = 0;
    
    event fundsReceived(uint _funds);
    
    
    constructor() public {
        crowdfundingOwner = msg.sender;   // adresa celui care trimite mesajul
    }
   
    function receiveFunds() payable external {
        funds = msg.value;
        emit fundsReceived(funds);
    }
   
    function addBeneficiary(address payable _beneficiary, uint _percentage) onlyOwner public{
        
        require(_percentage <= 100, "The share goes above 100%. Please pick a smaller value.");
        require(currentSharePercentage + _percentage <= 100, "The share increases the total share above 100%. Please pick a smaller value.");
        
        beneficiaries.push(_beneficiary);
        shares[_beneficiary] = _percentage;  // unui beneficiar ii trimit x % 
        currentSharePercentage += _percentage;
    }
    
    function distributeFunds() onlyOwner public{
        require (funds > 0, "Not enough funds to distribute");
        
        for (uint i = 0; i < beneficiaries.length; i++) {
            beneficiaries[i].transfer(shares[beneficiaries[i]] * funds/100);
        }
        
    }
}
