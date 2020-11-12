// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.7.0;
import "remix_tests.sol";
import 'CrowdFunding.sol';

contract CrowdFundingTest {
    
    CrowdFunding crowdFunding;

    function beforeEach() public {
        uint _test_goal = 1000;
        address payable _test_addr = 0x1e23b35B4352f28527d9740429Ea9957F613f70F;
        crowdFunding = new CrowdFunding(_test_goal, _test_addr);
    }
    
    function checkAfterOneDonates () public returns (bool) {
        // contr = new CrowdFunding.Contributor(string("Teo"), string("RO"), uint(500), address("0x5e8Db8791Ea88582A78AD7934Ef0849cb026bE06"));
        crowdFunding.donate("teo", "RO", 500);
        Assert.equal(crowdFunding.currentFunds, 500, "The current amount incresead");

    }
    
    function checkDonationsAfterReachingAmount () public returns (bool) {
        crowdFunding.donate("teo", "RO", 500);
        Assert.equal(crowdFunding.currentFunds, 1500, "The amount should now be bigger than the goal");
        Assert.equal(crowdFunding.campaignEnded, True, "Campaign has ended succesfully");
    }
    
    function checkRetractTooMuchMoney () public returns (bool) {
        // goal is 1000, donate 500 -> Campaign not ended yet
        crowdFunding.donate("Oana", "UK", 750);
        crowdFunding.retract(1500);
        
        Assert.equal(crowdFunding.currentFunds, 750, "Oana can't withdraw so much money so the amount remains the same");
    }
    
    function checkDistribute() public returns (bool) {
        crowdFunding.donate("Oana", "UK", 1000); // goal reached
        crowdFunding.sent2distribute();   // after distribution, the amount should be made 0

        Assert.equal(crowdFunding.currentFunds, 0, "The funds have been distributed");
        
    }
}
