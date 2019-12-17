// This should have been deployed to Remix
// We will be using Solidity version 0.5.3
pragma solidity 0.5.3;
// Importing OpenZeppelin's ERC-721 Implementation
import 'https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
// Importing OpenZeppelin's SafeMath Implementation
import 'https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol';


contract POBAToken is ERC721Full {
    using SafeMath for uint256;
    // This struct will be used to represent one POBA
    struct POBA {
        uint8 genes;
        uint256 orderId;
        uint256 serialId;
    }
    
    // List of existing POBAs
    POBA[] public POBAs;

    // Event that will be emitted whenever a new POBA is created
    event Birth(
        address owner,
        uint256 POBAId,
        uint256 orderId,
        uint256 serialId,
        uint8 genes
    );

    // Initializing an ERC-721 Token named 'POBAs' with a symbol 'P08A'
    constructor() ERC721Full("POBAs", "PO8A") public {
    }

    // Fallback function
    function() external payable {
    }

    /** @dev Function to determine a POBA's characteristics.
      * @param order ID of POBA's order (one parent)
      * @param serial ID of POBA's serial (other parent)
      * @return The POBA's genes in the form of uint8
      */
    function generatePOBAGenes(
        uint256 order,
        uint256 serial
    )
        internal
        pure
        returns (uint8)
    {
        return uint8(order.add(serial)) % 6 + 1;
    }

    /** @dev Function to create a new POBA
      * @param order ID of new POBA's order (one parent)
      * @param serial ID of new POBA's serial (other parent)
      * @param POBAOwner Address of new POBA's owner
      * @return The new POBA's ID
      */
    function createPOBA(
        uint256 order,
        uint256 serial,
        address POBAOwner
    )
        internal
        returns (uint)
    {
        require(POBAOwner != address(0));
        uint8 newGenes = generatePOBAGenes(order, serial);
        POBA memory newPOBA = POBA({
            genes: newGenes,
            orderId: order,
            serialId: serial
        });
        uint256 newPOBAId = POBAs.push(newPOBA).sub(1);
        super._mint(POBAOwner, newPOBAId);
        emit Birth(
            POBAOwner,
            newPOBAId,
            newPOBA.orderId,
            newPOBA.serialId,
            newPOBA.genes
        );
        return newPOBAId;
    }
    
    /** @dev Function to allow user to buy a new POBA (calls createPOBA())
      * @return The new POBA's ID
      */
    function buyPOBA() external payable returns (uint256) {
        require(msg.value == 0.02 ether);
        return createPOBA(0, 0, msg.sender);
    }
    
    /** @dev Function to make custom POBAs with your own symbol.
      * @param orderId ID of new POBA's order (one parent)
      * @param serialId ID of new POBA's serial (other parent)
      * @return The new POBA's ID
      */
    function breedPOBAs(uint256 orderId, uint256 serialId) external payable returns (uint256) {
        require(msg.value == 0.05 ether);
        return createPOBA(orderId, serialId, msg.sender);
    }
    
    /** @dev Function to retrieve a specific POBA's details.
      * @param POBAId ID of the POBA who's details will be retrieved
      * @return An array, [POBA's ID, POBA's genes, order's ID, serial's ID]
      */
    function getPOBADetails(uint256 POBAId) external view returns (uint256, uint8, uint256, uint256) {
        POBA storage POBA = POBAs[POBAId];
        return (POBAId, POBA.genes, POBA.orderId, POBA.serialId);
    }
    
    /** @dev Function to get a list of owned POBAs' IDs
      * @return A uint array which contains IDs of all owned POBAs
      */
    function ownedPOBAs() external view returns(uint256[] memory) {
        uint256 POBACount = balanceOf(msg.sender);
        if (POBACount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](POBACount);
            uint256 totalPOBAs = POBAs.length;
            uint256 resultIndex = 0;
            uint256 POBAId = 0;
            while (POBAId < totalPOBAs) {
                if (ownerOf(POBAId) == msg.sender) {
                    result[resultIndex] = POBAId;
                    resultIndex = resultIndex.add(1);
                }
                POBAId = POBAId.add(1);
            }
            return result;
        }
    }
}
