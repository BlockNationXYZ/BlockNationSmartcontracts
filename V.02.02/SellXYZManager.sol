pragma solidity ^0.5.6;


import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';
/**
* @dev This interface of xyzToken
*/
interface IXYZContract{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

/**
 * @dev This interface of RefManager
 */
interface IRefManagerContract{
    function addKlay(address playerAddress, uint refCode, uint point) external returns(uint);
}

contract BlockNationContract is Ownable{    
    IXYZContract public xyzInstance;
    IRefManagerContract public refManagerInstance;

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

contract SellXYZManager is BlockNationContract {
    using SafeMath for uint;
    struct BunchPrice{
        uint priceKlay;
        uint amountXYZ;
        bool isAvailable;
    }
    BunchPrice[] public listBunch;
    function newBunch(uint _priceKlay, uint _amountXYZ) public onlyOwner{
        listBunch.push(BunchPrice(_priceKlay, _amountXYZ, true));
    }
    function editBunch(uint _id, uint _priceKlay, uint _amountXYZ, bool _isAvailable) public onlyOwner{
        require(_id<listBunch.length,"Out indexed");
        listBunch[_id].priceKlay = _priceKlay;
        listBunch[_id].amountXYZ = _amountXYZ;
        listBunch[_id].isAvailable = _isAvailable;
    }
    function totalBunch() public view returns(uint total){
        total = listBunch.length;
    }
    constructor() public{
        listBunch.push(BunchPrice(890 * 1e18, 1e6 * 1e6, true));
        listBunch.push(BunchPrice(95 * 1e18, 1e5 * 1e6, true));
        listBunch.push(BunchPrice(9.8 * 1e18, 1e4 * 1e6, true));
        listBunch.push(BunchPrice(0.99 * 1e18, 1e3 * 1e6, true));
    }
    function buyBunch(uint bunchId, uint refCode) public payable {
        require(bunchId<listBunch.length,"Bunch id dont exits");
        require(msg.value == listBunch[bunchId].priceKlay, "Please send right amount");
        require(xyzInstance.balanceOf(address(this)) >= listBunch[bunchId].amountXYZ, "Seller dont have enough XYZ to sell");
         //Transfer Klay to refManagerContract to ensure enough Klay for reward
        uint totalKlayWillDividen =  refManagerInstance.addKlay(msg.sender,refCode, msg.value);
        uint totalOwnerGet = msg.value.sub(totalKlayWillDividen);
        require(totalOwnerGet > 0, "Owner dont get anything");
        address(uint160(owner())).transfer(totalOwnerGet);
        
        (bool successToRef, ) = address(address(refManagerInstance)).call.value(totalKlayWillDividen)("");
        require(successToRef, "Transfer to refManager is failed.");
        require(xyzInstance.transfer(msg.sender,listBunch[bunchId].amountXYZ ), "transfer xyz error");
    }
    /**
    * @dev Withdraw token XYZ back to Owner
    */ 
    function withdraw() public onlyOwner {
        require(xyzInstance.transfer(owner(), xyzInstance.balanceOf(address(this))),'Request Transfer XYZ token is not successful');
    }
    function withdrawKlay() public onlyOwner(){
        (bool successToOwner, ) = address(owner()).call.value(address(this).balance)("");
        require(successToOwner, "Transfer to owner is failed.");
    }
}