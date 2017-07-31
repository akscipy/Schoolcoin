pragma solidity ^0.4.11;

/**
 * Schoolcoin extended ERC20 token contract created on July 31th, 2017 by Abhishek Kumar.
 * This project is a POC for School reviews, admission, payments or tracking of seats on blockchain which will give it a global visibility
 * and would be completely decenteralized.
 * Code is based on ERC20 token and Zeppelin-solidity to make it secure.
 * Initially it will create 10000000000000 (Ten trillion) coins and will be distributed for usage
 * Deployed on Metamask:
 * Owner address: 0x6997caca204d31f23fa02b03a6c419b7e252dd08
 * Contract Address: 0x7e7fcce3b175dcb54d1be93e0751147cfc664386
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    require(newOwner != 0x0);      
    owner = newOwner;
  }

}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}





/* Schoolcoin Contract */
contract SchoolcoinToken is Ownable, StandardToken {
	using SafeMath for uint256;
    string public name = "Schoolcoin";                                      // Name for the token
    string public symbol = "SCN";                                           // symbol for token
    address public SchoolcoinAddress = this;                                // Address of the Schoolcoin token
    uint8 public decimals = 0;                                              // Amount of decimals for display purposes
    uint256 public totalSupply = 10000000000000;                            // Set total supply of Schoolcoins (Ten trillion)
    uint256 public buyPriceEth = 1 finney;                                  // Buy price for Schoolcoins
    uint256 public sellPriceEth = 1 finney;                                 // Sell price for Schoolcoins
    uint256 public gasForSCN = 5 finney;                                    // Eth from contract against SCN to pay tx
    uint256 public SCNForGas = 10;                                          // SCN to contract against eth to pay tx
    uint256 public gasReserve = 1 ether;                                    // Eth amount that remains in the contract for gas and can't be sold
    uint256 public minBalanceForAccounts = 10 finney;                       // Minimal eth balance of sender and recipient
    bool public directTradeAllowed = true;                                  // Halt trading SCN by sending to the contract directly
    address public thisAddress;

/* Initializes contract with initial supply tokens to the creator of the contract */
    function SchoolcoinToken() {
        balances[this] = totalSupply;                                 // Give the creator all tokens
        thisAddress = this;
    }


/* Constructor parameters */
    function setEtherPrices(uint256 _newBuyPriceEth, uint256 _newSellPriceEth) onlyOwner {
        buyPriceEth = _newBuyPriceEth;                                       // Set prices to buy and sell SCN
        sellPriceEth = _newSellPriceEth;
    }
    function setGasForSCN(uint _newGasAmountInWei) onlyOwner {
        gasForSCN = _newGasAmountInWei;
    }
    function setSCNForGas(uint _newSCNAmount) onlyOwner {
        SCNForGas = _newSCNAmount;
    }
    function setGasReserve(uint _newGasReserveInWei) onlyOwner {
        gasReserve = _newGasReserveInWei;
    }
    function setMinBalance(uint _minimumBalanceInWei) onlyOwner {
        minBalanceForAccounts = _minimumBalanceInWei;
    }


/* Halts or unhalts direct trades without the sell/buy functions below */
    function haltDirectTrade() onlyOwner {
        directTradeAllowed = false;
    }
    function unhaltDirectTrade() onlyOwner {
        directTradeAllowed = true;
    }


/* Transfer function extended by check of eth balances and pay transaction costs with SCN if not enough eth */
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(_value > SCNForGas);                                        // Prevents drain and spam
        if (msg.sender != owner && _to == SchoolcoinAddress && directTradeAllowed) {
            sellSchoolcoinsAgainstEther(_value);                             // Trade Schoolcoins against eth by sending to the token contract
            return true;
        }

		require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);   // Check if sender has enough and for overflows
		
        balances[msg.sender] = balances[msg.sender].sub(_value);        // Subtract SCN from the sender
        if (msg.sender.balance >= minBalanceForAccounts && _to.balance >= minBalanceForAccounts) {    // Check if sender can pay gas and if recipient could
            balances[_to] = balances[_to].add(_value);                  // Add the same amount of SCN to the recipient
            Transfer(msg.sender, _to, _value);                          // Notify anyone listening that this transfer took place
            return true;
        } else {
            balances[this] = balances[this].add(SCNForGas);             // Pay SCNForGas to the contract
            balances[_to] = balances[_to].add(_value.sub(SCNForGas));   // Recipient balance -SCNForGas
            Transfer(msg.sender, _to, _value.sub(SCNForGas));           // Notify anyone listening that this transfer took place

            if(msg.sender.balance < minBalanceForAccounts) {
                require(msg.sender.send(gasForSCN));                    // Send eth to sender
              }
            if(_to.balance < minBalanceForAccounts) {
                require(_to.send(gasForSCN));                           // Send eth to recipient
            }
        }
    }


/* User can buy Schoolcoins by paying in Ether */
    function buySchoolcoinsAgainstEther() payable returns (uint amount) {
        require(buyPriceEth != 0 && msg.value > buyPriceEth);               // Avoid dividing 0, sending small amounts and spam
        amount = msg.value.div(buyPriceEth);                                   // Calculate the amount of Schoolcoins
        require(balances[this] > amount);                                   // Check if it has enough to sell
        balances[msg.sender] = balances[msg.sender].add(amount);            // Add the amount to buyer's balance
        balances[this] = balances[this].sub(amount);                        // Subtract amount from Schoolcoin balance
        Transfer(this, msg.sender, amount);                                 // Execute an event reflecting the change
        return amount;
    }


/* User can sell Schoolcoins and gets Ether */
    function sellSchoolcoinsAgainstEther(uint256 _amount) returns (uint revenue) {
        require(sellPriceEth != 0 && _amount > SCNForGas);                  // Avoid selling and spam
        require(balances[msg.sender] > _amount);                            // Check if the sender has enough to sell
        revenue = _amount.mul(sellPriceEth);                                // Revenue = eth that will be send to the user
        require(this.balance.sub(revenue) > gasReserve);                    // Keep min amount of eth in contract to provide gas for transactions
        require(msg.sender.send(revenue));                                  // Send ether to the owner. It's important to do this last to avoid recursion attacks
        balances[this] = balances[this].add(_amount);                       // Add the amount to Schoolcoin balance
        balances[msg.sender] = balances[msg.sender].sub(_amount);           // Subtract the amount from seller's balance
        Transfer(this, msg.sender, revenue);                                // Execute an event reflecting on the change
        return revenue;                                                     // End function and returns
    }


/* refund to owner */
    function refundToOwner (uint256 _amountOfEth, uint256 _scn) onlyOwner {
        uint256 eth = _amountOfEth.mul(1 ether);
        require(msg.sender.send(eth));                                      // Send ether to the owner. It's important to do this last to avoid recursion attacks
        Transfer(this, msg.sender, eth);                                    // Execute an event reflecting on the change
        require(balances[this] > _scn);                                     // Check if it has enough to sell
        balances[msg.sender] = balances[msg.sender].add(_scn);              // Add the amount to buyer's balance
        balances[this] = balances[this].sub(_scn);                          // Subtract amount from seller's balance
        Transfer(this, msg.sender, _scn);                                   // Execute an event reflecting the change
    }


/* This unnamed fallback function is called whenever someone tries to send ether to it and possibly sells Schoolcoins */
    function() payable {
        require(msg.sender != owner);
        require(directTradeAllowed);
        buySchoolcoinsAgainstEther();                                       // Allow direct trades by sending eth to the contract
    }
}
