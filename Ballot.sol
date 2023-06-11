//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Ballot {

   struct Voter {
       uint weight;
       bool voted;
       address delegate;
       uint vote;
   }

   struct Proposal {
       uint countVote;
       string name;
   }

   mapping(address => Voter) public voters;
   Proposal[] public proposals;
   
   address public owner;

   constructor(string[] memory _allProposals) {
       owner = msg.sender;
       voters[owner].weight = 1;

        for (uint i = 0; i < _allProposals.length; i++) {
            proposals.push(Proposal({
                countVote: 0,
                name: _allProposals[i]
            }));
        }
   }

   function giveRightsToVote(address _voter) external {
       require(msg.sender == owner);
       require(voters[_voter].weight == 0);
       require(!voters[_voter].voted);
       voters[_voter].weight = 1;
   }

   function delegate(address _voter) external {
       Voter storage newVoter = voters[msg.sender];
       require(newVoter.weight != 0);
       require(!newVoter.voted);

       Voter storage newnewVoter = voters[_voter];
       require(newnewVoter.weight != 0);

       newVoter.voted = true;
       newVoter.delegate = _voter;
       newVoter.vote = newnewVoter.vote;

       if (newnewVoter.voted) {
           proposals[newnewVoter.vote].countVote += newVoter.weight;
       } else {
           newnewVoter.weight += newVoter.weight;
       }
   }

   function vote(uint _vote) external {
       Voter storage newVoter = voters[msg.sender];
       require(newVoter.weight != 0);
       require(!newVoter.voted);

       proposals[_vote].countVote += newVoter.weight;
       newVoter.voted = true;
       newVoter.vote = _vote;
   }

   function getWinner() view public returns(uint256 get) {
       uint256 count = 0;
       for (uint i = 0; i < proposals.length; i++) {
           if (proposals[i].countVote > count) {
               count = proposals[i].countVote;
               get = i;
           }
       }
   }

   function getWinnerName() view public returns(string memory winnerName_) {
       winnerName_ = proposals[getWinner()].name;
   }

}