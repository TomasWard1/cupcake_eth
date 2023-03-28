pragma solidity 0.8.19;

contract VendingMachine {

    //variables
    uint public machine_balance = 100;
    uint256 public balance_count;
    address owner;
    mapping(address => uint) public balances;

    //functions
    constructor() {
        //setting the deployer of the contract as the owner.
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function addPerson(address eth_address) public onlyOwner {
        balances[eth_address] = 0;
        incrementCount();
    }

    function incrementCount() internal {
        balanceCount += 1;
    }

    function buyFromMachine(uint amount) public {
        require(machine_balance >= amount,"Insufficient Cupcakes in Machine");
        balances[msg.sender] += amount;
        machine_balance -= amount;
    }

    function buyFromUser(address eth_address,uint amount) public {
        require(balances[eth_address] >= amount,"The user is not THAT rich");
        balances[eth_address] -= amount;
        balances[msg.sender] += amount;
    }

    function myEconomicState() public view returns(string memory) {
        uint b =  balances[msg.sender];

        if (b < 50) {
            return "Poor";
        } else if (b < 500) {
            return "Rich";
        } else {
            return "Millionaire";
        }
    }

}