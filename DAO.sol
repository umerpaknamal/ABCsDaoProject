// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
interface ABCsToken {
    function balanceOf(address, uint256) external view returns (uint256);
    function balance(address) external view returns (uint256);
    function transfer(
        address,
        address,
        uint256
    ) external returns (bool);
}
contract Dao {
    address public owner;
    uint256 nextProposal;
    ABCsToken ABCs;
    constructor() {
        owner = msg.sender;
        nextProposal = 1;
        ABCs = ABCsToken(0xE09e76709caE02914fB4793Dbed549Bab00050CB);// token address 
    }
    struct proposal {
        uint256 id;
        address proposalar;
        bool exists;
        string description;
        uint256 deadline;
        uint256 votesUp;
        uint256 votesDown;
        uint256 maxVotesWeight;
        mapping(address => bool) voteStatus;
        bool countConducted;
        bool passed;
    }
    mapping(uint256 => proposal) public Proposals;
    event proposalCreated(uint256 id, string description, address proposer);

    event newVote(
        uint256 votesUp,
        uint256 votesDown,
        address voter,
        uint256 proposal,
        bool votedFor
    );
    event proposalCount(uint256 id, bool passed);

    function createProposal(string memory _description) public {
        require(ABCs.balance(msg.sender) >= 100, "Proposal fees is 3 ABCs ");
        proposal storage newProposal = Proposals[nextProposal];
        newProposal.id = nextProposal;
        newProposal.proposalar = msg.sender;
        newProposal.exists = true;
        newProposal.description = _description;
        newProposal.deadline = block.number + 1296000;
        ABCs.transfer(msg.sender, owner, 3);
        emit proposalCreated(nextProposal, _description, msg.sender);
        nextProposal++;
    }

    function voteOnProposal(uint256 _id, bool _vote) public {
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(
            !Proposals[_id].voteStatus[msg.sender],
            "You have already voted on this Proposal"
        );
        require(
            block.number <= Proposals[_id].deadline,
            "The deadline has passed for this Proposal"
        );
        require(
            ABCs.balance(msg.sender) >= 100,
            "votes has ABCs token greater than 100"
        );
        proposal storage p = Proposals[_id];
        if (_vote) {
            p.votesUp = p.votesUp + ABCs.balance(msg.sender);
        } else {
            p.votesDown = p.votesDown + ABCs.balance(msg.sender);
        }
        p.voteStatus[msg.sender] = true;
        emit newVote(p.votesUp, p.votesDown, msg.sender, _id, _vote);
    }

    function countVotes(uint256 _id) public {
        proposal storage p = Proposals[_id];
        require(msg.sender == p.proposalar, "Only proposalar Can Count Votes");
        require(Proposals[_id].exists, "This Proposal does not exist");
        require(
            block.number > Proposals[_id].deadline,
            "Voting has not concluded"
        );
        require(!Proposals[_id].countConducted, "Count already conducted");
        if (Proposals[_id].votesDown < Proposals[_id].votesUp) {
            p.maxVotesWeight = p.maxVotesWeight / 100;
            if (Proposals[_id].votesUp >= 30 * p.maxVotesWeight) {
                p.passed = true;
            } else {
                p.passed = false;
            }
        } else {
            p.passed = false;
        }
        p.countConducted = true;
        emit proposalCount(_id, p.passed);
    }
}
