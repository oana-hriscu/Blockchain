// SPDX-License-Identifier: MIT


pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;

import 'DistributeFunding.sol';
import 'OwnerProperty.sol';

contract CrowdFunding is OwnerProperty {
    
    uint fundingGoal;
    uint currentFunds;
    bool campaignEnded;
    mapping (address => Contributor) donors;  // mapping (cheia address, valoarea Contributor)
    DistributeFunding distributeFunding;
    
    struct Contributor{
        string name;
        string countryCode;
        uint donatedSum;
        address addr;
    }
    
    // contract members (evenimente care stocheaza args in transaction logs)
    event newDonation (Contributor _contributor);
    event checkStatus (uint _currentFunds, string message);
    event donationRetracted(address _contributorAddress, uint _retractedSum);
    event endCampaign ();
   
    constructor (uint _fundingGoal, address payable _distributeFunding) public {
        
        distributeFunding = DistributeFunding(_distributeFunding);
        fundingGoal = _fundingGoal;  // in wei
        currentFunds = 0;
    }
    
    function donate(string memory _name, string memory _countryCode, uint _amount) payable public {
        
        Contributor memory currentContributor = donors[msg.sender];  // sender of the message (current call address)
        
        require(
            campaignEnded != true,
            "Our Campaign has ended but thank you very much for your intent!"
            );
        
        if(currentContributor.addr == address(0)) {  // contrib nou (nu exista valoare pt cheia adresei)
            currentContributor = Contributor({
                name: _name,
                countryCode: _countryCode,
                addr: msg.sender,
                donatedSum: _amount   //msg.value
            });
        }
        else {
            // actualizam datele contribuitorului existent
            currentContributor.name = _name;
            currentContributor.countryCode = _countryCode;
            currentContributor.donatedSum += _amount;   // crestem suma donata de contribuitorul existent
        }
        
        currentFunds += _amount;
        donors[msg.sender] = currentContributor;
        emit newDonation(currentContributor);   // apel explicit
        
        if(currentFunds >= fundingGoal){
            campaignEnded = true;
            emit endCampaign();
        }
    }
    
    function retract (uint amount) public {
        Contributor memory currentContributor = donors[msg.sender];
        
        require( 
            currentContributor.addr != address(0),   // trebuie ca adresa care vrea sa extraga bani sa existe in mappig
            "I'm sorry but it looks like you are not part of our list of contributors."
            );
        
        require(
            campaignEnded != true,
            "Sorry but our campaign has ended. You can no longer retract your donation."
            );
            
        // trebuie sa poata extrage maximul sumei donate:
        require(
            currentContributor.donatedSum >= amount, "You haven't donated this much money!"
            );
        
        
        currentFunds -= amount;
        currentContributor.donatedSum -= amount;
        
        if(currentContributor.donatedSum == 0) {
            delete donors[msg.sender];
        }
        
        emit donationRetracted(msg.sender, amount);
        msg.sender.transfer(amount);
    }
    
    function sent2distribute () public {
        
        require(
            campaignEnded == true,
            "Sorry but you cannot distribute the funds until the campaign has ended."
            );
        
        distributeFunding.receiveFunds{value:currentFunds};
        currentFunds = 0;
    }
    
    function campaignStatus() public {
        if (currentFunds < fundingGoal)
            emit checkStatus(currentFunds, "We have not reached our Goal yet");
        else
            emit checkStatus(currentFunds, "We have reached our goal :D");
    }

}
