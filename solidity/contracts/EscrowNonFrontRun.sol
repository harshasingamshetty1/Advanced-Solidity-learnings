//escrow contract
//depost funds, associate password
//provide pasword and withdraw the amount
//no partial withdrawals
// prevent frontrunning

//Solution:
/* 
    1. commit the passcode
    2. reveal the password
    3. must not allow commit and reveal in same block
 */
contract Escrow {
    event Deposit(address, uint256);
    event Withdraw(address, uint256);

    mapping(bytes32 => uint256) funds;
    // Mapping to store the commit details with address
    mapping(address => Commit) commits;

    struct Commit {
        bytes32 solutionHash;
        uint256 commitTime;
        bool revealed;
    }

    function deposit(bytes32 passHash) external payable {
        // bytes passHash = abi.encodePacked(passcode);
        require(funds[passHash] == 0, "Change Password");
        funds[passHash] = msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function commitPassword(bytes32 passHash) external {
        commits[msg.sender] = Commit(passHash, block.timestamp, false);
        //emit
    }

    function revealPasswordAndWithdraw(string memory passcode) external {
        bytes32 h1 = keccak256(abi.encodePacked(msg.sender, passcode));
        Commit storage commit = commits[msg.sender];
        require(commit.commitTime != 0, "Not committed yet");
        require(commit.commitTime < block.timestamp, "Cannot reveal in the same block");
        require(!commit.revealed, "Already commited and revealed");

        require(commits[msg.sender].solutionHash == h1, "committed hash doesn't match");

        bytes32 passHash = keccak256(abi.encodePacked(passcode));
        uint256 value = funds[passHash];
        require(value > 0, "No locked funds");
        funds[passHash] = 0;
        (bool success,) = msg.sender.call{value: value}("");
        require(success, "Failed");

        emit Withdraw(msg.sender, value);
    }
}
