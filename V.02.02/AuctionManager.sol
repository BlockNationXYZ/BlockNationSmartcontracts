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

contract SellerTokensEnumerable {
    using SafeMath for uint;
    mapping(address => uint256[]) private _sellerTokens;
    mapping(uint256 => uint256) private _sellerTokensIndex;
    uint public totalSellerTokens;
    function tokenOfSellerTokensLength(address owner) public view returns(uint){
        return _sellerTokens[owner].length; 
    }
    function tokenOfSellerTokensByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < _sellerTokens[owner].length, "index out of bounds");
        return _sellerTokens[owner][index];
    }

    function addTokenToSellerEnumeration(address to, uint256 tokenId) internal {
        _sellerTokensIndex[tokenId] = _sellerTokens[to].length;
        _sellerTokens[to].push(tokenId);
        totalSellerTokens = totalSellerTokens.add(1);
    }
    function removeTokenFromSellerEnumeration(address from, uint256 tokenId) internal {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).
        uint256 lastTokenIndex = _sellerTokens[from].length.sub(1);
        uint256 tokenIndex = _sellerTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _sellerTokens[from][lastTokenIndex];

            _sellerTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _sellerTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _sellerTokens[from].length--;
        // Since tokenId will be deleted, we can clear its slot in _sellerTokensIndex to trigger a gas refund
        _sellerTokensIndex[tokenId] = 0;
        totalSellerTokens = totalSellerTokens.sub(1);

        // Note that _sellerTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }
}
contract BidderTokensEnumerable {
    using SafeMath for uint;
    mapping(address => uint256[]) private _bidderTokens;
    mapping(uint256 => uint256) private _bidderTokensIndex;
    uint public totalBidderTokens;
    function tokenOfBidderTokensLength(address owner) public view returns(uint){
        return _bidderTokens[owner].length; 
    }
    function tokenOfBidderTokensByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < _bidderTokens[owner].length, "index out of bounds");
        return _bidderTokens[owner][index];
    }

    function addTokenToBidderEnumeration(address to, uint256 tokenId) internal {
        _bidderTokensIndex[tokenId] = _bidderTokens[to].length;
        _bidderTokens[to].push(tokenId);
        totalBidderTokens = totalBidderTokens.add(1);
    }
    function removeTokenFromBidderEnumeration(address from, uint256 tokenId) internal {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).
        uint256 lastTokenIndex = _bidderTokens[from].length.sub(1);
        uint256 tokenIndex = _bidderTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _bidderTokens[from][lastTokenIndex];

            _bidderTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _bidderTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _bidderTokens[from].length--;
        // Since tokenId will be deleted, we can clear its slot in _bidderTokensIndex to trigger a gas refund
        _bidderTokensIndex[tokenId] = 0;
        totalBidderTokens = totalBidderTokens.sub(1);
        // Note that _bidderTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occupied by
        // lastTokenId, or just over the end of the array if the token was the last one).
    }
}
contract AuctionManager is BlockNationContract, SellerTokensEnumerable, BidderTokensEnumerable {
    using SafeMath for uint;
    struct BidData{
        address owner;
        uint startPrice;
        uint listingTime;
        uint bidTime;
        uint bidStep;
        uint startTime;
        uint endTime;
        address topBidder;
        uint topPrice;
    }
    mapping (uint => BidData) public tokenIdToBidData;
    mapping(address=> mapping(uint=>uint)) public balance;
    BidData public defaultBidData;
    uint public refFeeRatio;//100% If price land is 100, refFeeRatio = 50% => 100 * 50 % * ref Ratio, seller just get a rest after minus total ref
    constructor() public{
        defaultBidData.owner = owner();
        defaultBidData.startPrice = 100 * 1e6; //100 XYZ
        defaultBidData.bidTime = 1 hours;
        defaultBidData.bidStep = 10 * 1e6;
        
        refFeeRatio = 10; // Currently, total refRatio is 30%, and with refFeeRatio = 10%, that's mean bid fee is 3%. Will redure in furture to zero 
    }
    
    function SetDefaultBidData(address _owner, uint _startPrice, uint _bidTime, uint _bidStep) public onlyOwner{
        defaultBidData.owner = _owner;
        defaultBidData.startPrice = _startPrice;
        defaultBidData.bidTime = _bidTime;
        defaultBidData.bidStep = _bidStep;
    }
    function SetRefFeeRatio(uint _refFeeRatio) public onlyOwner{
        refFeeRatio = _refFeeRatio;
    }
    function NewListing(uint _tokenId, uint _startPrice,uint _bidTime, uint _bidStep, uint _ref) public{
        xLandInstance.transferFrom(msg.sender, address(this), _tokenId);
        require(xLandInstance.ownerOf(_tokenId) == address(this), "Transfer Xland not success");
        tokenIdToBidData[_tokenId] = BidData(msg.sender, _startPrice, now, _bidTime, _bidStep, 0, 0, address(0), 0);
        refManagerInstance.addPoint(msg.sender,_ref, 0);
        addTokenToSellerEnumeration(msg.sender, _tokenId);
    }
    
    function DeListing(uint _tokenId) public{
        require(msg.sender == tokenIdToBidData[_tokenId].owner, "Just owner can DeListing");
        require(tokenIdToBidData[_tokenId].startTime == 0, "Auction is start cant DeListing");
        xLandInstance.transferFrom(address(this), msg.sender, _tokenId);
        require(xLandInstance.ownerOf(_tokenId) == msg.sender, "tokenId cant transfer back to owner");
        tokenIdToBidData[_tokenId] = BidData(address(0), 0, 0, 0, 0, 0, 0, address(0), 0);
        removeTokenFromSellerEnumeration(msg.sender, _tokenId);

    }
    function MintAndBid(uint _tokenId, uint _stepNum, uint _ref) public {
        require(xLandInstance.mint(address(this),_tokenId), "Mint token is not success. Maybe not have right or token is exits");
        tokenIdToBidData[_tokenId] = BidData(defaultBidData.owner, defaultBidData.startPrice, now, defaultBidData.bidTime, defaultBidData.bidStep, 0, 0, address(0), 0);
        Bid(_tokenId, _stepNum, _ref);
        addTokenToSellerEnumeration(defaultBidData.owner, _tokenId);
    }
    function Bid(uint _tokenId, uint _stepNum, uint _ref)  public {
        //Check bid is available
        BidData memory tokenBidData = tokenIdToBidData[_tokenId];
        require(tokenBidData.listingTime != 0, 'Token not listing');
        if(tokenBidData.startTime > 0)
            require(tokenBidData.startTime.add(tokenBidData.bidTime) >= now, 'Bid is end');//Bid end 
        require(tokenBidData.endTime == 0, 'Bid end and tokenid not available');//Bid end and token transfer to winner
        
        require(_stepNum > 0, 'Step must be great than 0');
        
        uint currentBalanceForThisToken = balance[msg.sender][_tokenId];
        uint requireBalanceForBid = 0;
        if(tokenBidData.topPrice == 0)
            requireBalanceForBid = tokenBidData.startPrice.add(_stepNum.mul(tokenBidData.bidStep));
        else
            requireBalanceForBid= tokenBidData.topPrice.add(_stepNum.mul(tokenBidData.bidStep));
        if( requireBalanceForBid > currentBalanceForThisToken){
            uint balanceNeedToDeposit = requireBalanceForBid.sub(currentBalanceForThisToken);
            require(xyzInstance.transferFrom(msg.sender, address(this), balanceNeedToDeposit), 'Cant deposit to bid');
            balance[msg.sender][_tokenId] = requireBalanceForBid;
        }
        tokenIdToBidData[_tokenId].topBidder = msg.sender;
        tokenIdToBidData[_tokenId].topPrice = requireBalanceForBid;
        tokenIdToBidData[_tokenId].startTime = now;
        
        refManagerInstance.addPoint(msg.sender,_ref, 0);//Sign up
        addTokenToBidderEnumeration(msg.sender, _tokenId);
    }
    function QuitBidIfNotWin(uint _tokenId) public{//
        BidData memory tokenBidData = tokenIdToBidData[_tokenId];
        require(msg.sender != tokenBidData.topBidder, "You are topBidder, cant quit");
        uint userBalanceForThisBid = balance[msg.sender][_tokenId];
        require(userBalanceForThisBid >0, "You are not join this Auction");
        balance[msg.sender][_tokenId] = 0;
        require(xyzInstance.transfer(msg.sender, userBalanceForThisBid), "Cant withdraw from bid");
        removeTokenFromBidderEnumeration(msg.sender, _tokenId);
    }
    function EndBid(uint _tokenId) public{//anyone can call this to end bid and transfer every thing to winner and owner
        BidData memory tokenBidData = tokenIdToBidData[_tokenId];
        require(tokenBidData.endTime == 0, 'Bid end and tokenid not available');//Bid end and token transfer to winner
        require(tokenBidData.startTime.add(tokenBidData.bidTime) < now, "Bid is not end");
        uint topBidderBalance = balance[tokenBidData.topBidder][_tokenId];
        balance[tokenBidData.topBidder][_tokenId] = 0;
        tokenIdToBidData[_tokenId].endTime = now;
        
        uint feeFillBid = topBidderBalance.mul(refFeeRatio).div(100);
        uint totalPointWillDividenInSellerRefTree =  refManagerInstance.addPoint(tokenBidData.owner,0, feeFillBid.div(2));
        uint totalPointWillDividenInBuyerRefTree =  refManagerInstance.addPoint(tokenBidData.topBidder,0, feeFillBid.div(2));
        uint restBalanceToOwner = topBidderBalance.sub(totalPointWillDividenInSellerRefTree).sub(totalPointWillDividenInBuyerRefTree);
        require(xyzInstance.transfer(tokenBidData.owner, restBalanceToOwner), "Cant transfer xyz to owner of tokenId");
        require(xyzInstance.transfer(address(refManagerInstance), totalPointWillDividenInSellerRefTree.add(totalPointWillDividenInBuyerRefTree)), "Cant transfer xyz to owner of tokenId");
        
        xLandInstance.transferFrom(address(this), tokenBidData.topBidder, _tokenId);
        require(xLandInstance.ownerOf(_tokenId) == tokenBidData.topBidder, "tokenId cant transfer to this winner");
        removeTokenFromBidderEnumeration(tokenBidData.topBidder, _tokenId);
        removeTokenFromSellerEnumeration(tokenBidData.owner, _tokenId);
    }
}