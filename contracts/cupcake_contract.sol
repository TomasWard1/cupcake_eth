pragma solidity 0.8.19;

contract VendingMachine {

    //variables
    uint public machine_balance = 2500;
    uint256 public balance_count;
    address owner;
    address[] public activeAddresses;
    mapping(address => uint) public balances;

    //functions
    constructor() {
        //setting the deployer of the contract as the owner.
        owner = msg.sender;
    }


    function addPerson(address eth_address) public {
        balances[eth_address] = 0;
        activeAddresses.push(eth_address);
        incrementCount();
    }

    function incrementCount() internal {
        balance_count += 1;
    }

    function buyFromMachine(uint amount) public {
        require(machine_balance >= amount, "Insufficient Cupcakes in Machine");
        balances[msg.sender] += amount;
        machine_balance -= amount;
    }

    //dev

    function buyFromUser(address eth_address, uint amount) public {
        require(balances[eth_address] >= amount, "The user is not THAT rich");
        balances[eth_address] -= amount;
        balances[msg.sender] += amount;
    }

    function resetMachine() public {
        machine_balance = 2500;
        for (uint256 i = 0; i < balance_count; i++) {
            balances[activeAddresses[i]] = 0;
        }
    }

}