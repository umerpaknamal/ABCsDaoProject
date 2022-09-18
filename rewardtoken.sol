
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ABCs is ERC20, ERC20Burnable, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;
  mapping(address => bool) controllers;

  uint256 private _totalSupply;
  uint public timenow =  block.timestamp;
  uint256 private MAXSUP;
  uint256 MAXIMUMSUPPLY=1000000*10**18;

  constructor() ERC20("Ambersterdam Books Coin", "ABCs") { 

  }

  function mint(address to, uint256 amount) external {
    require(controllers[msg.sender], "Only controllers can mint");
    require((MAXSUP+amount)<=MAXIMUMSUPPLY,"Maximum supply has been reached");
    _totalSupply = _totalSupply.add(amount);
    MAXSUP=MAXSUP.add(amount);
    _balances[to] = _balances[to].add(amount);
    _mint(to, amount);
  }

  function burnFrom(address account, uint256 amount) public override {
      if (controllers[msg.sender]) {
          _burn(account, amount);
      }
      else {
          super.burnFrom(account, amount);
      }
  }

  function addController(address controller) external onlyOwner {
    controllers[controller] = true;
  }

  function removeController(address controller) external onlyOwner {
    controllers[controller] = false;
  }
  
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  function maxSupply() public view returns (uint256) {
    return MAXIMUMSUPPLY;
  }

  function sendTokensToCommunity(address community) public payable onlyOwner{
    uint256 moneyToTransfer = _totalSupply/100 * 15;
    _totalSupply = _totalSupply - moneyToTransfer;
    transfer(community, moneyToTransfer);
  }
  
  function oneThirdSupply() public {
      require(block.timestamp + 30 > block.timestamp, "time is 2 blocks");
      MAXIMUMSUPPLY = MAXIMUMSUPPLY/3;
  }
  
}
