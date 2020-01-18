pragma solidity ^0.5.6;


import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/WhitelistedRole.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol';


/**
* @dev This interface of xyzToken
*/
interface IXYZToken{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}
contract topBoard{
    struct TopData{
        address playerAddress;
        uint point;
    }
    TopData[5] public top5;
    function showTop5() public view returns(address top1_address, uint top1_point, address top2_address, uint top2_point,address top3_address, uint top3_point,address top4_address, uint top4_point,address top5_address, uint top5_point){
        top1_address = top5[0].playerAddress;
        top1_point = top5[0].point;
        top2_address = top5[1].playerAddress;
        top2_point = top5[1].point;
        top3_address = top5[2].playerAddress;
        top3_point = top5[2].point;
        top4_address = top5[3].playerAddress;
        top4_point = top5[3].point;
        top5_address = top5[4].playerAddress;
        top5_point = top5[4].point;
    }
    function _addToTop5(address playerAddress, uint point) internal{
        bool playerInTop = false;
        for(uint i = 0; i< 5; i++){
            if(top5[i].playerAddress == playerAddress)
            {
                top5[i].point = point;
                playerInTop = true;
                i = 5;
            }
        }
        if(playerInTop){//Sorting list
            for(uint i = 0; i< 5; i++){
                for(uint j = i+1; j<5; j++){
                    if(top5[i].point < top5[j].point){
                        TopData memory tempForSwap = top5[i];
                        top5[i] = top5[j];
                        top5[j] = tempForSwap;
                    }
                }
            }
        }
        else//Append to list
        {
            for(uint i = 0; i<5; i++){
                if(top5[i].point < point){
                        for(uint j = 2; j>i; j--){
                            top5[j] = top5[j-1];
                        }
                        top5[i].playerAddress = playerAddress;
                        top5[i].point = point;
                        i = 5;
                }
            }
        }
    
    }
}
contract topBoardKlay{
    struct TopDataKlay{
        address playerAddress;
        uint point;
    }
    TopDataKlay[5] public top5Klay;
    function showTop5Klay() public view returns(address top1_address, uint top1_point, address top2_address, uint top2_point,address top3_address, uint top3_point,address top4_address, uint top4_point,address top5_address, uint top5_point){
        top1_address = top5Klay[0].playerAddress;
        top1_point = top5Klay[0].point;
        top2_address = top5Klay[1].playerAddress;
        top2_point = top5Klay[1].point;
        top3_address = top5Klay[2].playerAddress;
        top3_point = top5Klay[2].point;
        top4_address = top5Klay[3].playerAddress;
        top4_point = top5Klay[3].point;
        top5_address = top5Klay[4].playerAddress;
        top5_point = top5Klay[4].point;
    }
    function _addToTop5Klay(address playerAddress, uint point) internal{
        bool playerInTop = false;
        for(uint i = 0; i< 5; i++){
            if(top5Klay[i].playerAddress == playerAddress)
            {
                top5Klay[i].point = point;
                playerInTop = true;
                i = 5;
            }
        }
        if(playerInTop){//Sorting list
            for(uint i = 0; i< 5; i++){
                for(uint j = i+1; j<5; j++){
                    if(top5Klay[i].point < top5Klay[j].point){
                        TopDataKlay memory tempForSwap = top5Klay[i];
                        top5Klay[i] = top5Klay[j];
                        top5Klay[j] = tempForSwap;
                    }
                }
            }
        }
        else//Append to list
        {
            for(uint i = 0; i<5; i++){
                if(top5Klay[i].point < point){
                        for(uint j = 2; j>i; j--){
                            top5Klay[j] = top5Klay[j-1];
                        }
                        top5Klay[i].playerAddress = playerAddress;
                        top5Klay[i].point = point;
                        i = 5;
                }
            }
        }
    
    }
}
contract RefSystem{
    using SafeMath for uint;
    uint public refCount = 1;
    mapping(address=>uint) public player2RefCode;
    mapping(uint=>address) public refCode2Player;

    struct RefInfo{
        uint parent;
        uint[11] levelCount;
    }
    mapping(uint=>RefInfo) public refInfos;
        /**
     * @dev Get Amount child ref info of Ref
     * @param refCode uint Ref code
     */
    function getRefInfos(uint refCode) public view returns(uint parent, uint level1Count, uint level2Count, uint level3Count, uint level4Count, uint level5Count, uint level6Count, uint level7Count, uint level8Count, uint level9Count,uint level10Count ){
        parent = refInfos[refCode].parent;
        level1Count =  refInfos[refCode].levelCount[1];
        level2Count =  refInfos[refCode].levelCount[2];
        level3Count =  refInfos[refCode].levelCount[3];
        level4Count =  refInfos[refCode].levelCount[4];
        level5Count =  refInfos[refCode].levelCount[5];
        level6Count =  refInfos[refCode].levelCount[6];
        level7Count =  refInfos[refCode].levelCount[7];
        level8Count =  refInfos[refCode].levelCount[8];
        level9Count =  refInfos[refCode].levelCount[9];
        level10Count =  refInfos[refCode].levelCount[10];
        
    }

    /**
     * @dev Emitted when new user signUp
     */
    event SignUp(address newUserAddress, uint ref);
    /**
     * @dev Add new player and get ref id
     */
     function signUp(address playerAddress, uint refCode) internal{
         
         if(player2RefCode[playerAddress]==0){//Don't have ref code (new player)
            require(refCode<refCount,'Invalid refCode');
            emit SignUp(playerAddress, refCode);
            player2RefCode[playerAddress] = refCount;
            refCode2Player[refCount] = playerAddress;
            refInfos[refCount].parent = refCode;
            refCount = refCount.add(1);
             uint playerRefCode = player2RefCode[playerAddress];
             uint currentParentRef = refInfos[playerRefCode].parent;
             for(uint i = 1; i<= 10; i ++){
                 if(currentParentRef == 0 ) break;// no parent;
                 refInfos[currentParentRef].levelCount[i] = refInfos[currentParentRef].levelCount[i].add(1);
                 currentParentRef = refInfos[currentParentRef].parent;
             }
         }
     }
}
contract RefManager is RefSystem, topBoard,topBoardKlay, WhitelistedRole, Ownable{
    using SafeMath for uint;
    struct RefCondition{
        uint requirePoint;
        uint dividenRatio;// 1 per 1000 (not per 100)
    }
    RefCondition[11] public refConfig;
    struct RefPoint{
        uint[11] levelPoint;
        uint totalRefPoint;
        uint totalRefPointToXYZ;
    }
    mapping(uint=>RefPoint) ref2Point;
    struct RefKlay{
        uint[11] levelKlay;
        uint totalRefKlay;
        uint totalRefKlayEarned;
    }
    mapping(uint=>RefKlay) ref2Klay;
    /**
     * @dev Get Point info of Ref
     * @param refCode uint Ref code
     */
    function getRef2Point(uint refCode) public view returns(uint totalRefPoint, uint level0Point, uint level1Point, uint level2Point, uint level3Point, uint level4Point, uint level5Point, uint level6Point, uint level7Point, uint level8Point, uint level9Point,uint level10Point, uint totalRefPointToXYZ ){
        totalRefPoint = ref2Point[refCode].totalRefPoint;
        level0Point = ref2Point[refCode].levelPoint[0];
        level1Point =  ref2Point[refCode].levelPoint[1];
        level2Point =  ref2Point[refCode].levelPoint[2];
        level3Point =  ref2Point[refCode].levelPoint[3];
        level4Point =  ref2Point[refCode].levelPoint[4];
        level5Point =  ref2Point[refCode].levelPoint[5];
        level6Point =  ref2Point[refCode].levelPoint[6];
        level7Point =  ref2Point[refCode].levelPoint[7];
        level8Point =  ref2Point[refCode].levelPoint[8];
        level9Point =  ref2Point[refCode].levelPoint[9];
        level10Point =  ref2Point[refCode].levelPoint[10];
        totalRefPointToXYZ =ref2Point[refCode].totalRefPointToXYZ;
    }
    function getRef2Klay(uint refCode) public view returns(uint totalRefKlay, uint level0Klay, uint level1Klay, uint level2Klay, uint level3Klay, uint level4Klay, uint level5Klay, uint level6Klay, uint level7Klay, uint level8Klay, uint level9Klay,uint level10Klay, uint totalRefKlayEarned ){
        totalRefKlay = ref2Klay[refCode].totalRefKlay;
        level0Klay = ref2Klay[refCode].levelKlay[0];
        level1Klay =  ref2Klay[refCode].levelKlay[1];
        level2Klay =  ref2Klay[refCode].levelKlay[2];
        level3Klay =  ref2Klay[refCode].levelKlay[3];
        level4Klay =  ref2Klay[refCode].levelKlay[4];
        level5Klay =  ref2Klay[refCode].levelKlay[5];
        level6Klay =  ref2Klay[refCode].levelKlay[6];
        level7Klay =  ref2Klay[refCode].levelKlay[7];
        level8Klay =  ref2Klay[refCode].levelKlay[8];
        level9Klay =  ref2Klay[refCode].levelKlay[9];
        level10Klay =  ref2Klay[refCode].levelKlay[10];
        totalRefKlayEarned =ref2Klay[refCode].totalRefKlayEarned;
    }
    constructor() public{
        refConfig[0].requirePoint = 1e6;
        refConfig[0].dividenRatio = 25;//pẻ 1000, 2.5%
        for(uint i = 1; i <=10; i++){//@dev: i is level ref (1-10 level)
            refConfig[i].requirePoint = 10**(i-1);
            refConfig[i].dividenRatio = (55-i*5);//per 1000
        }
    }
     /**
     * @dev Emitted when ref config changed
     */
    event RefConfigChanged(uint id, uint requirePoint, uint dividenRatio);
    /**
     * @dev modifier Ref config
     * @param id uint RefConfig id
     * @param requirePoint uint requirePoint
     * @param dividenRatio uint dividenRatio per 1000 
     */
     function modifyRefConfig(uint id, uint requirePoint, uint dividenRatio) public onlyOwner {
         refConfig[id].requirePoint = requirePoint;
         refConfig[id].dividenRatio = dividenRatio;
         emit RefConfigChanged(id, requirePoint, dividenRatio);
     }
    IXYZToken public xyzInstance;
    /**
    * @dev Set xyzTokenAddress
    * @param newAddress address Contract address for XYZtoken to interact, ensure this contract have enough XYZ token balance
    */
    function setXYZTokenAddress(address newAddress) public onlyOwner {
        require(newAddress != address(0), 'xyzTokenAddress is not assigned!');
        xyzInstance = IXYZToken(newAddress);
    }
     /**
     * @dev Emitted when Point added
     */
    event PointAdded(address playerAddress, uint point);
      /**
     * @dev Add point to ref RefSystem
     * @param playerAddress address Player address
     * @param refCode uint parent refcode, if user signup before, this ref will not work
     * @param point uint Point will add
     * @return result bool True if successful
     */
    function addPoint(address playerAddress, uint refCode, uint point) public onlyWhitelisted returns(uint){
        signUp(playerAddress, refCode);
        uint totalPointWillDividen = 0;
        if(point > 0){
            uint playerRefCode = player2RefCode[playerAddress];
            uint refPoint = point.mul(refConfig[0].dividenRatio).div(1000);
            ref2Point[playerRefCode].levelPoint[0] = ref2Point[playerRefCode].levelPoint[0].add(refPoint);//Self ref
            ref2Point[playerRefCode].totalRefPoint = ref2Point[playerRefCode].totalRefPoint.add(refPoint);
            _addToTop5(playerAddress,ref2Point[playerRefCode].totalRefPoint );
            totalPointWillDividen =  totalPointWillDividen.add(refPoint);
            uint currentParentRef = refInfos[playerRefCode].parent;
            emit PointAdded(playerAddress,point );
            for(uint i = 1; i<= 10; i++){
                  if(currentParentRef == 0 ) break;// no parent;
                  if(xyzInstance.balanceOf(playerAddress) >= refConfig[i].requirePoint){
                    refPoint = point.mul(refConfig[i].dividenRatio).div(1000);
                    ref2Point[currentParentRef].levelPoint[i] = ref2Point[currentParentRef].levelPoint[i].add(refPoint);
                    ref2Point[currentParentRef].totalRefPoint = ref2Point[currentParentRef].totalRefPoint.add(refPoint);
                    _addToTop5( refCode2Player[currentParentRef], ref2Point[currentParentRef].totalRefPoint );
                    totalPointWillDividen = totalPointWillDividen.add(refPoint);
                  }
                 currentParentRef = refInfos[currentParentRef].parent;
            }
        }
        return totalPointWillDividen;//That help to determine amount xyz to transfer to this contract to ensure enouugh to pay reward
    }

    /**
    * @dev Convert refPoint to token XYZ
    */ 
    function convertRefPoint2XYZ() public {
        require(player2RefCode[msg.sender] != 0, "Player dont have refCode");
        RefPoint memory playerRefPoint  = ref2Point[player2RefCode[msg.sender]];
        uint availablePoint = playerRefPoint.totalRefPoint.sub(playerRefPoint.totalRefPointToXYZ);
        require(availablePoint > 0, "Don have any point available");
       
        uint amountXYZToConvert = availablePoint;
        require(amountXYZToConvert > 0, 'Not enough Point to convert to XYZ token');
        ref2Point[player2RefCode[msg.sender]].totalRefPointToXYZ = playerRefPoint.totalRefPointToXYZ.add(amountXYZToConvert);
        require(xyzInstance.transfer(msg.sender, amountXYZToConvert),'Request Transfer XYZ token is not successful');
    }
    
    //Klay
      /**
     * @dev Emitted when Klay added
     */
    event KlayAdded(address playerAddress, uint klay);
      /**
     * @dev Add klay to ref RefSystem
     * @param playerAddress address Player address
     * @param refCode uint parent refcode, if user signup before, this ref will not work
     * @param point uint Klay will add
     * @return result bool True if successful
     */
    function addKlay(address playerAddress, uint refCode, uint point) public onlyWhitelisted returns(uint){
        signUp(playerAddress, refCode);
        uint totalPointWillDividen = 0;
        if(point > 0){
            uint playerRefCode = player2RefCode[playerAddress];
            uint refKlay = point.mul(refConfig[0].dividenRatio).div(1000);
            ref2Klay[playerRefCode].levelKlay[0] = ref2Klay[playerRefCode].levelKlay[0].add(refKlay);//Self ref
            ref2Klay[playerRefCode].totalRefKlay = ref2Klay[playerRefCode].totalRefKlay.add(refKlay);
            _addToTop5Klay(playerAddress,ref2Klay[playerRefCode].totalRefKlay );
            totalPointWillDividen =  totalPointWillDividen.add(refKlay);
            uint currentParentRef = refInfos[playerRefCode].parent;
            emit KlayAdded(playerAddress,point );
            for(uint i = 1; i<= 10; i++){
                  if(currentParentRef == 0 ) break;// no parent;
                  if(xyzInstance.balanceOf(playerAddress) >= refConfig[i].requirePoint){
                    refKlay = point.mul(refConfig[i].dividenRatio).div(1000);
                    ref2Klay[currentParentRef].levelKlay[i] = ref2Klay[currentParentRef].levelKlay[i].add(refKlay);
                    ref2Klay[currentParentRef].totalRefKlay = ref2Klay[currentParentRef].totalRefKlay.add(refKlay);
                    _addToTop5Klay( refCode2Player[currentParentRef], ref2Klay[currentParentRef].totalRefKlay );
                    totalPointWillDividen = totalPointWillDividen.add(refKlay);
                  }
                 currentParentRef = refInfos[currentParentRef].parent;
            }
        }
        return totalPointWillDividen;//That help to determine amount xyz to transfer to this contract to ensure enouugh to pay reward
    }

    /**
    * @dev Convert refKlay to klay
    */ 
    function earnRefKlay() public {
        require(player2RefCode[msg.sender] != 0, "Player dont have refCode");
        RefKlay memory playerRefKlay  = ref2Klay[player2RefCode[msg.sender]];
        uint availableKlay = playerRefKlay.totalRefKlay.sub(playerRefKlay.totalRefKlayEarned);
        require(availableKlay > 0, "Don have any klay available");
       
        ref2Klay[player2RefCode[msg.sender]].totalRefKlayEarned = playerRefKlay.totalRefKlayEarned.add(availableKlay);
        require(address(this).balance >= availableKlay, "Not enough klay in contract");
        address(msg.sender).transfer(availableKlay);
    }
    /**
     * @dev Accept klay 
     */
    function () external payable{
    }
}
