// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <=0.7.5;
import 'OwnerProperty.sol';

contract DistributeFunding is OwnerProperty{
    address crowdfundingOwner;
    mapping ( address => uint) shares;
    address payable[] beneficiaries;
    uint funds = 0;
    uint currentSharePercentage = 0;
    
    event fundsReceived(uint _funds);
    
    
    constructor() {
        crowdfundingOwner = msg.sender;
    }
   
    fallback() payable external{}
    
    receive() payable external{
        funds = msg.value;
        emit fundsReceived(funds);
    }
   
    function addBeneficiary(address payable _beneficiary, uint _percentage) ownerOnly public{
        
        require(_percentage <= 100, "The share goes above 100%. Please pick a smaller value.");
        require(currentSharePercentage + _percentage <= 100, "The share increases the total share above 100%. Please pick a smaller value.");
        
        beneficiaries.push(_beneficiary);
        shares[_beneficiary] = _percentage;
        currentSharePercentage += _percentage;
    }
    
    function distributeFunds() ownerOnly public{
        require (funds > 0, "Not enought funds to distribute");
        
        for (uint i = 0; i < beneficiaries.length; i++) {
            beneficiaries[i].transfer(shares[beneficiaries[i]] * funds/100);
        }
        
    }
}
