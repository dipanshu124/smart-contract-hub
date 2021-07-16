// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

//Implementaion of Single Transferable Vote
contract Ballot {
   
    struct Voter {
        bool voted;  // if true, that person already voted
        bool is_candidate;
    }
    struct Proposal {
        string name;
        string party_name;    // short name (up to 32 bytes)
        
        address[] support;
        uint in_support;        //Number of votes 
    }
        constructor(){
        chairperson=msg.sender;
    }

    address public chairperson;
    mapping(address=>Voter) public voters;
    bool public can_vote=bool(false);
    bool public can_register_candidate=bool(false);
    bool public can_register_voter=bool(false);
    uint public cand_num=0;
    uint public voter_num=0;
    modifier isChairPerson(){
        require(msg.sender==chairperson);
        _;
    }
    function toggle_can_vote() isChairPerson public{
        can_vote=!can_vote;
    }
    function toggle_can_register_voter() isChairPerson public{
        can_register_voter=!can_register_voter;
    }
    function toggle_can_register_candidate() isChairPerson public{
        can_register_candidate=!can_register_candidate;
    }
    uint public num_seat;
    function set_num_seat(uint num_seats) isChairPerson public{
        num_seat=num_seats;
    }
    function Register_Voter() public{
        if(can_register_voter){
        voters[msg.sender].voted=false;
        voter_num=voter_num+1;
        }
    }
    Proposal[] public proposals;
    function Register_Candidate(string memory Name,string memory party) public{
        if((can_register_candidate)&&(!voters[msg.sender].is_candidate)){
            Proposal memory temp;
            temp.name=Name;
            temp.party_name=party;
            voters[msg.sender].is_candidate=true;
            cand_num=cand_num+1;
            proposals.push(temp);
        }
    }
    function vote(uint pref) public {
        if((can_vote)&&(!voters[msg.sender].voted)){
        voters[msg.sender].voted=true;
                proposals[pref].support.push(msg.sender);
                proposals[pref].in_support+=1;
        }
    }
    Proposal[] public winners;
    
    function winningProposal() public { 
        uint256 i;
        uint256 j;
        for(i=0;i<cand_num-1;i++) {
            for(j=0;j<cand_num-1-i;j++) {
                if(proposals[j].in_support > proposals[j+1].in_support) {
                    uint256 temp;
                    temp=proposals[j].in_support;
                    proposals[j].in_support=proposals[j+1].in_support;
                    proposals[j+1].in_support=temp;
                    
                    string memory t;
                    t=proposals[j].name;
                    proposals[j].name=proposals[j+1].name;
                    proposals[j+1].name=t;
                    
                    t=proposals[j].party_name;
                    proposals[j].party_name=proposals[j+1].party_name;
                    proposals[j+1].party_name=t;
                }
            }
        }
        for(i=0;i<num_seat;i++) {
            Proposal memory t1;
            t1.name=proposals[cand_num-1-i].name;
            t1.party_name=proposals[cand_num-1-i].party_name;
            winners.push(t1);
        }

    }
}