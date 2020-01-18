pragma solidity ^0.5.6;


import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';

/**
 * @dev This interface of xLandContract
 */
interface xLandContract{
     function mint(address _to, uint256 _tokenId) external returns(bool);
     function balanceOf(address _owner) external view returns (uint256 _balance);
}
/**
 * @dev This interface of RefManager
 */
interface refManagerContract{
    function addPoint(address playerAddress, uint refCode, uint point) external;
}


contract Utils{
    using SafeMath for uint;
    uint nonce = 0;
    function getRandTokenId(uint numberDigit) internal returns(uint){
        uint rand = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) %1e14;
        nonce++;
        uint isNorth = rand.mod(10)>5 ? 1: 0;
        uint isWest = rand.div(10).mod(10)>5 ? 1: 0;
        uint x = rand.div(1e2).mod(10 ** numberDigit);
        uint y = rand.div(1e8).mod(10 ** numberDigit);
        
        uint tokenId = 0 * 1e14 + x * 1e8 + y * 1e2 + isNorth * 1e1 + isWest;
        return tokenId;
    }
}
contract FreeLandManager is Ownable, Utils{
    using SafeMath for uint;
    address public xLandContractAddress; 
    address public refManagerContractAddress; 
    mapping(address=>uint) public freeCount;
    uint public maxLandFree;
    constructor() public{
        maxLandFree = 2;
    }
    /**
    * @dev Set maxLandFree
    * @param newMaxLandFree uint max free land user can get
    */
    function setMaxLandFree(uint newMaxLandFree) public onlyOwner {
        
        maxLandFree = newMaxLandFree;
    }
    /**
    * @dev Set xLandAddress
    * @param newAddress address Contract address for Xland to interact, ensure this contract is minter of Xland contract
    */
    function setXLandAddress(address newAddress) public onlyOwner {
        
        xLandContractAddress = newAddress;
    }
    /**
    * @dev Set refManagerContractAddress
    * @param newAddress address Contract address for Xland to interact, ensure this contract is minter of Xland contract
    */
    function setRefManagerContractAddress(address newAddress) public onlyOwner {
        
        refManagerContractAddress = newAddress;
    }
    /**
    * @dev Get land free, each user just have 2 free land
    * @param refCode uint Direct ref code
    */ 
    function getFreeLand(uint refCode) public  {
        require(freeCount[msg.sender] < maxLandFree, "Reach max free land to get");
        freeCount[msg.sender] = freeCount[msg.sender].add(1);
        require(refManagerContractAddress != address(0),"refManagerContractAddress is not define");
        refManagerContract refManagerInstance = refManagerContract(refManagerContractAddress);
        refManagerInstance.addPoint(msg.sender,refCode, 0);
        require(xLandContractAddress != address(0), "xLandContractAddress is not define");
        xLandContract xLand = xLandContract(xLandContractAddress);
        uint tokenId = getRandTokenId(6);//range (000000 - 999999, 000000 - 999999)
        require(xLand.mint(msg.sender,tokenId ), "mint fail");
    }
    
}