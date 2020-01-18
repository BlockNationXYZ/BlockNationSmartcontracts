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
contract BlockNationNameServices is BlockNationContract{
    mapping(string => address) public UserNameToAddress;
    mapping(address => string) public UserAddressToName;
    mapping(string => uint) public LandNameToId;
    mapping(uint => string) public LandIdToName;
    
    uint public UserNamePrice;
    uint public LandNamePrice;
    function SetUserNamePrice(uint newPrice) public onlyOwner{
        UserNamePrice = newPrice;
    }
    function SetLandNamePrice(uint newPrice) public onlyOwner{
        LandNamePrice = newPrice;
    }
    constructor() public{
        UserNamePrice = 100 * 1e6;
        LandNamePrice = 100 * 1e6;
    }
    function buyUserName(string memory newUserName, uint refCode) public {
        require(UserNameToAddress[newUserName] == address(0), "This name is taken");
        require(payment(UserNamePrice, refCode), "Payment error");
        UserNameToAddress[UserAddressToName[msg.sender]] = address(0);
        UserNameToAddress[newUserName] = msg.sender;
        UserAddressToName[msg.sender] = newUserName;
    }
    function buyLandName(uint tokenId, string memory newLandName, uint refCode) public {
        require(xLandInstance.ownerOf(tokenId) == msg.sender, "Cant change tokenid not owner");
        require(LandNameToId[newLandName] == 0, "This name is taken");
        require(payment(LandNamePrice, refCode), "Payment error");
        LandNameToId[LandIdToName[tokenId]] = 0;
        LandNameToId[newLandName] = tokenId;
        LandIdToName[tokenId] = newLandName;
    }
    function payment(uint amountRequest, uint refCode) private returns(bool isSuccess){
        require(xyzInstance.transferFrom(msg.sender, address(this), amountRequest), "Cant transfer xyz token");
        uint totalPointWillDividen =  refManagerInstance.addPoint(msg.sender,refCode, amountRequest);
        require(xyzInstance.transfer(address(refManagerInstance), totalPointWillDividen), 'Transfer is not successful');
        isSuccess = true; 
    }
    function withdraw() public onlyOwner{
        require(xyzInstance.transfer(owner(), xyzInstance.balanceOf(address(this))), "Cant transfer");
    }
}