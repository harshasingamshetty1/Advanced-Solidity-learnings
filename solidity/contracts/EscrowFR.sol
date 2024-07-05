//escrow contract
//depost funds, associate password
//provide pasword and withdraw the password
//no partial withdrawals
// prevent frontrunning
contract Escrow {
    event Deposit(address, uint256);
    event Withdraw(address, uint256);

    mapping(bytes => uint256) funds;

    function deposit(bytes passHash) external payable {
        // bytes passHash = abi.encodePacked(passcode);
        require(funds[passHash] == 0, "Change Password");
        funds[passHash] = msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function Withdraw(string memory passcode) external {
        bytes passHash = abi.encodePacked(passcode);
        uint256 value = funds[passHash];
        require(value > 0, "No locked funds");
        funds[passHash] = 0;
        msg.sender.call{value: value}();

        emit Withdraw(msg.sender, value);
    }
}
