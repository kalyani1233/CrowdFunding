// SPDX-License-Identifier:GPL 
pragma solidity >=0.5.0 < 0.9.0;
// Crowdfunding Project
contract CrowdFunding{
    // mapping of addresses with integer here we will calculate the contributors
    mapping(address => uint) public contributors;
    // All the required parameters
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;
    

    // This is Request struct as it is declared so that if any one want to request for fund then all the data is stored in it
    struct Request{

        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;

    }
    // how many number of request are mapped with Request Struct
    mapping (uint =>Request) public requests;
    uint public numRequests;


    constructor(uint _target,uint _deadline){
        target=_target;
        deadline=block.timestamp + _deadline;
        minimumContribution = 100 wei;
        manager =msg.sender;
    }
    // To send Eth to the Manager it must be payable
    function sendEth() public payable{
        require(block.timestamp < deadline,"Deadline has crossed!!");
        require(msg.value >= minimumContribution,"Minium contribution is not met!");
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    // This function will allow you to check your balance
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

// This will allow you to reFund if any contributor dont want to contribute
    function reFund() public {
        require(block.timestamp > deadline && raisedAmount <target,"You are not eligible for refund!");
        require(contributors[msg.sender]>0,"You are not a contributor");
        address payable user= payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;


    }
    // Modifier is created for manager
    modifier onlyManager(){
        require(msg.sender == manager,"Only Manager can call this function!");
        _;
    }

    // Create request fucntion will create all the Requests  of Fund 
    function createRequest(string memory _description,address payable _recipient,uint _value) public onlyManager{
         Request storage newRequest =requests[numRequests];
         numRequests++;
         newRequest.description=_description;
         newRequest.recipient=_recipient;
         newRequest.value=_value;
         newRequest.completed=false;
         newRequest.noOfVoters=0;

    }
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender]>0 ,"You must be contributer!");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender] ==false,"You have already voted!");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
       
       
       }

    function makePayment(uint _requestNo) public payable onlyManager{
        require(raisedAmount >=target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support");
       thisRequest.recipient.transfer(thisRequest.value);
       thisRequest.completed=true;
       }
}