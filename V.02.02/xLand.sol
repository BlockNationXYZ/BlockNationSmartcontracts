pragma solidity ^0.5.6;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Holder.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Burnable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721MetadataMintable.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol';


library String {
  /*
    From https://ethereum.stackexchange.com/questions/10811/solidity-concatenate-uint-into-a-string
  */

    function uintToString(uint v) internal pure returns (string memory str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] =  byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        str = string(s);
    }

}

contract xLand is  ERC721Holder, ERC721Burnable, ERC721MetadataMintable, ERC721Full , Ownable{
  constructor () public
    ERC721Full('BlockNation.XYZ land token', 'XLAND')
  { 
       super._setBaseURI("https://blocknationuri.herokuapp.com/id/");
  }
    /**
     * @dev Function to set uri endpoint
     * @param _rootTokenUri Root endpoint uri
     */
    function setBaseURI(string memory _rootTokenUri) public onlyOwner {
        super._setBaseURI(_rootTokenUri);
    }
     /**
     * @dev Function to mint tokens.
     * @param to The address that will receive the minted token.
     * @param tokenId The token id to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 tokenId) public onlyMinter returns (bool) {
        mintWithTokenURI(to, tokenId, String.uintToString(tokenId)) ;
        return true;
    }
}

