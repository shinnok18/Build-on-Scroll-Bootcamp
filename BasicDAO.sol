// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicDAO {
    struct Proposal {
        string description;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
    }

    address public owner;
    uint256 public membershipFee;
    mapping(address => bool) public members;
    Proposal[] public proposals;
    mapping(address => mapping(uint256 => bool)) public votes;

    event Joined(address member);
    event ProposalCreated(uint256 proposalId, string description, uint256 deadline);
    event Voted(uint256 proposalId, address voter, bool vote);
    event ProposalExecuted(uint256 proposalId, bool passed);

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    constructor(uint256 _membershipFee) {
        owner = msg.sender;
        membershipFee = _membershipFee;
    }

    function join() external payable {
        require(msg.value == membershipFee, "Incorrect membership fee");
        require(!members[msg.sender], "Already a member");
        members[msg.sender] = true;
        emit Joined(msg.sender);
    }

    function createProposal(string calldata _description, uint256 _duration) external onlyMember {
        proposals.push(Proposal({
            description: _description,
            deadline: block.timestamp + _duration,
            yesVotes: 0,
            noVotes: 0,
            executed: false
        }));
        emit ProposalCreated(proposals.length - 1, _description, block.timestamp + _duration);
    }

    function vote(uint256 _proposalId, bool _vote) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.deadline, "Voting period over");
        require(!votes[msg.sender][_proposalId], "Already voted");

        votes[msg.sender][_proposalId] = true;

        if (_vote) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }

        emit Voted(_proposalId, msg.sender, _vote);
    }

    function executeProposal(uint256 _proposalId) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period not over");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;
        bool passed = proposal.yesVotes > proposal.noVotes;
        emit ProposalExecuted(_proposalId, passed);
    }
}
