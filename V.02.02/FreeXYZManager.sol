pragma solidity ^0.5.6;


import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';
/**
* @dev This interface of xyzToken
*/
interface IXYZContract{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}
/**
 * @dev This interface of xLandContract
 */
interface IXLandContract{
    function mint(address _to, uint256 _tokenId) external returns(bool);
    function balanceOf(address _owner) external view returns (uint256 _balance);
    function transferFrom(address from, address to, uint256 tokenId) external ;
        function ownerOf(uint256 tokenId) external view returns (address owner);
    
}
/**
 * @dev This interface of RefManager
 */
interface IRefManagerContract{
    function addPoint(address playerAddress, uint refCode, uint point) external returns(uint);
}

contract BlockNationContract is Ownable{    
    IXYZContract public xyzInstance;
    IXLandContract public xLandInstance;
    IRefManagerContract public refManagerInstance;
    /**
    * @dev Set xLandAddress
    * @param newAddress address Contract address for Xland to interact, ensure this contract is minter of Xland contract
    */
    function setXLandAddress(address newAddress) public onlyOwner {
        require(newAddress != address(0), "xLandContractAddress is not define");
        xLandInstance = IXLandContract(newAddress);
    }
    /**
    * @dev Set refManagerContractAddress
    * @param newAddress address Contract address for Xland to interact, ensure this contract is minter of Xland contract
    */
    function setRefManagerContractAddress(address newAddress) public onlyOwner {
        require(newAddress != address(0),"refManagerContractAddress is not define");
        refManagerInstance = IRefManagerContract(newAddress);
    }
       /**
    * @dev Set xyzTokenAddress
    * @param newAddress address Contract address for XYZtoken to interact, ensure this contract have enough XYZ token balance
    */
    function setXYZTokenAddress(address newAddress) public onlyOwner {
        require(newAddress != address(0), "xyzTokenAddress is not defined");
        xyzInstance = IXYZContract(newAddress);
    }
}

contract FreeXYZManager is BlockNationContract {
    using SafeMath for uint;
    
    constructor() public{
        
    }
    
    struct PlayerInfo{
        uint lastTimeGetFreeToken;
        uint lastAmountGetFreeToken;
    }
    mapping (address => PlayerInfo) public AllPlayerInfo;
    uint public DeltaTime = 1 days;
    uint public EachDayRewardAmount = 10 * 1e6; //10 XYZ per day
    
    /**
    * @dev Set DeltaTime
    * @param deltaTime uint DeltaTime
    */ 
    function setDeltaTime(uint deltaTime) public onlyOwner {
        DeltaTime = deltaTime;
    }
    /**
    * @dev Set EachDayRewardAmount
    * @param eachDayRewardAmount uint EachDayRewardAmount
    */ 
    function setEachDayRewardAmount(uint eachDayRewardAmount) public onlyOwner {
        EachDayRewardAmount = eachDayRewardAmount;
    }
    /**
    * @dev Show player info
    * @param playerAddress address player
    */ 
    function getPlayerInfo(address playerAddress) public view returns(uint lastTimeGetFreeToken, uint lastAmountGetFreeToken, uint nextTimeToGetFree, uint numberDaysContinue) {
        lastAmountGetFreeToken = AllPlayerInfo[playerAddress].lastAmountGetFreeToken;
        lastTimeGetFreeToken = AllPlayerInfo[playerAddress].lastTimeGetFreeToken;
        nextTimeToGetFree = lastTimeGetFreeToken + DeltaTime;
        numberDaysContinue = lastAmountGetFreeToken.div(EachDayRewardAmount);
    }
    /**
    * @dev Check in very day to get free token
    * @param refCode uint Direct ref code
    */ 
    function getFreeToken(uint refCode) public{
        require(xLandInstance.balanceOf(msg.sender) >0, "To get free token please buy some land");
        require(now.sub(AllPlayerInfo[msg.sender].lastTimeGetFreeToken) > DeltaTime,"Just get free token 1 time each DeltaTime");
        
        uint tokenFreeAmount = 0;
        if((now.sub(AllPlayerInfo[msg.sender].lastTimeGetFreeToken)) / DeltaTime == 1){//this if player check every DetalTime they will get more
            if(AllPlayerInfo[msg.sender].lastAmountGetFreeToken == EachDayRewardAmount.mul(10))//max is 10 times of daily reward
                tokenFreeAmount = EachDayRewardAmount.mul(10);
            else
                tokenFreeAmount = AllPlayerInfo[msg.sender].lastAmountGetFreeToken + EachDayRewardAmount;
        }
        else{
            tokenFreeAmount = EachDayRewardAmount;//reset to first step
        }
       
        require(xyzInstance.transfer(msg.sender,tokenFreeAmount), "Transfer is not successful");
        AllPlayerInfo[msg.sender].lastTimeGetFreeToken = now;
        AllPlayerInfo[msg.sender].lastAmountGetFreeToken = tokenFreeAmount;
        
        //Transfer xyz to refManagerContract to ensure enough XYZ for reward
        uint totalPointWillDividen =  refManagerInstance.addPoint(msg.sender,refCode, tokenFreeAmount);
        require(xyzInstance.transfer(address(refManagerInstance), totalPointWillDividen), "Transfer is not successful");
    }
    /**
    * @dev Withdraw token XYZ back to Owner
    */ 
    function withdraw() public onlyOwner {
        require(xyzInstance.transfer(owner(), xyzInstance.balanceOf(address(this))),'Request Transfer XYZ token is not successful');
    }
}