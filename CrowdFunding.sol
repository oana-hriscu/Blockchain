// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <=0.7.5;
pragma experimental ABIEncoderV2;
import 'DistributeFunding.sol';
import 'OwnerProperty.sol';

contract CrowdFunding is OwnerProperty {
    
    uint fundingGoal;
    uint currentFunds;
    bool campaignEnded; //by default initialized with false
    address payable private distributeFundingAddress;
    
    mapping (address => Contributor) donors;
    
    struct Contributor{
        string name;
        string countryCode;
        uint donatedSum;
        bool exists;
    }
    
    event newDonation (Contributor _contributor);
    event checkStatus (uint _currentFunds, string message);
    event donationRetracted(address _contributorAddress, uint _retractedSum);
    event endCampaign ();
    event mybalance(uint balance);
    event stats(bool campaignEnded, uint currentFunds, address distributeFundingAddress);
   
    constructor (uint _fundingGoal) {
        fundingGoal = _fundingGoal;
        currentFunds = 0;
    }
    
    function donate(string memory _name, string memory _countryCode ) payable public {
        
        Contributor memory currentContributor = donors[msg.sender];
        
        require(
            campaignEnded != true,
            "Our Campaign has ended but thank you very much for your intent!"
            );
        
        if(currentContributor.exists == false) {  //new donor - does not exist in the mapping
            currentContributor = Contributor({
                name: _name,
                countryCode: _countryCode,
                donatedSum: msg.value,
                exists: true
            });
        }
        else {
            currentContributor.donatedSum += msg.value;   //if an already existing contributor makes another donation, just increase the sum
        }
        
        currentFunds += msg.value;
        donors[msg.sender] = currentContributor;
        emit newDonation(currentContributor);
        
        if(currentFunds >= fundingGoal){
            campaignEnded = true;
            emit endCampaign();
        }
    }
    
    function retract (uint amount) public {
        Contributor memory currentContributor = donors[msg.sender];
        
        require( 
            currentContributor.exists == true,
            "I'm sorry but it looks like you are not part of our list of contributors."
            );
        
        require(
            campaignEnded != true,
            "Sorry but our campaign has ended. You can no longer retract your donation."
            );
        
        
        currentFunds -= amount;
        currentContributor.donatedSum -= amount;
        
        if(currentContributor.donatedSum == 0) {
            delete donors[msg.sender];
        }
        
        emit donationRetracted(msg.sender, amount);
        
        msg.sender.transfer(amount);
    }
    
    function setDistributionAddress(address payable _distributeFundingAddress) public ownerOnly {
        emit mybalance(address(this).balance);
        distributeFundingAddress = _distributeFundingAddress;
        emit stats(campaignEnded, currentFunds, distributeFundingAddress);
    }
    
    function send2distribute () payable public ownerOnly {
        
        require(
            campaignEnded == true,
            "Sorry but you cannot distribute the funds until the campaign has ended."
            );
         
        require(
            currentFunds >= fundingGoal,
            "Can't distribute right now. Campaign has not ended or unsufficient funds"
            );    
        
        require(
            distributeFundingAddress != address(0x0),
            "Distribution contract address not set!"
            );
        
        currentFunds = 0;
        fundingGoal = 0;
        distributeFundingAddress.call{value:address(this).balance}("");
    }
    
    function campaignStatus() public {
        if (currentFunds < fundingGoal)
            emit checkStatus(currentFunds, "We have not reached our Goal yet");
        else
            emit checkStatus(currentFunds, "We have reached our goal :D");
    }

}
