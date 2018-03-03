pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimumContributionSet) public {
        address newCampaign = new Campaign(minimumContributionSet, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        uint approvalCount;
        bool complete;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;

    modifier onlyManager() {
        require(manager == msg.sender);
        _;
    }

    function Campaign (uint minimumContributionSet, address creator) public {
        manager = creator;
        minimumContribution = minimumContributionSet;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string description, uint value, address recipient) public onlyManager {
            Request memory newRequest = Request({
              description: description,
              value: value,
              recipient: recipient,
              complete: false,
              approvalCount: 0
            });
         requests.push(newRequest);
    }

    function approveRequest(uint index) public {
            Request storage request = requests[index];

            require(approvers[msg.sender]);
            require(!request.approvals[msg.sender]);

            request.approvals[msg.sender] = true;
            request.approvalCount++;
    }

    function finalizeRequest(uint index) public onlyManager{
        // the capital R here indicates we are about to create a variable that refers to a a Request struct
            Request storage request = requests[index];

            require(request.approvalCount > (approversCount / 2));
            require(!request.complete);

            request.recipient.transfer(request.value);
            request.complete = true;
    }

}
