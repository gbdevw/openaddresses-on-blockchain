// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Belgian addresses
 * @dev Manage belgian addresses and their location
 */
contract BelgianAddresses {

    /***************************************************************************************************************/
    /*  STRUCTURES                                                                                                 */
    /***************************************************************************************************************/

    /**
     * @dev Data of an address
     */
    struct StreetAddress { 
        bytes32 addressId;
        string streetName;
        string postcode;
        string houseNumber;
        string boxNumber;
        string latitude;
        string longitude;
    }

    /***************************************************************************************************************/
    /*  STATE                                                                                                      */
    /***************************************************************************************************************/

    /**
     * Map used to contain all addresses
     */
    mapping(bytes32 => StreetAddress) public belgianAddresses;

    /**
     * Map used to list all address ids by postcode
     */
    mapping(string => bytes32[]) addressIdsByPostcode;

    /**
     * List of all available postcodes
     */
    string [] postcodes;

    /***************************************************************************************************************/
    /*  PERMISSIONS STATE                                                                                          */
    /***************************************************************************************************************/

    address private owner;

    /***************************************************************************************************************/
    /*  EVENTS                                                                                                     */
    /***************************************************************************************************************/

    /**
     * Event fired when an address is created.
     */
    event AddressCreated (bytes32 indexed newAddressId);
    
    /**
     * Event fired when an address is removed.
     */
    event AddressRemoved (bytes32 indexed oldAddressId, StreetAddress oldAddress);
    
    /**
     * Event fired when an address is updated
     */
    event AddressUpdated (bytes32 indexed oldAddressId, StreetAddress oldAddress, bytes32 indexed newAddressId);

    /**
     * Event fired when maintainer is changed
     */
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    /***************************************************************************************************************/
    /*  MODIFIERS                                                                                                  */
    /***************************************************************************************************************/

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /***************************************************************************************************************/
    /*  CONSTRUCTOR                                                                                                */
    /***************************************************************************************************************/

    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /***************************************************************************************************************/
    /*  PUBLIC STATE METHODS                                                                                       */
    /***************************************************************************************************************/

    /**
     * Add an address to the registry. The address ID is computed by the function.
     * Fires an AddressCrated event.
     * Returns the id of the new address.
     */
    function createAddress (
        string memory streetName,
        string memory postcode,
        string memory houseNumber,
        string memory boxNumber,
        string memory latitude,
        string memory longitude) public isOwner returns (bytes32) {

        // Create address
        StreetAddress memory newAddress;
        newAddress.streetName = streetName;
        newAddress.postcode = postcode;
        newAddress.houseNumber = houseNumber;
        newAddress.boxNumber = boxNumber;
        newAddress.latitude = latitude;
        newAddress.longitude = longitude;
        bytes32 id = _createAddress(newAddress);
        
        // Emit event - AddressCreated
        emit AddressCreated(id);

        // Return address id
        return id;
    }

    /**
     * Remove an address from the registry.
     * Fires an AddressRemoved event.
     */
    function removeAddress (bytes32 addressId) public isOwner {

        // Check requirements - Address exist
        require(belgianAddresses[addressId].addressId == addressId, "Requested address does not exist.");

        // Remove the address
        StreetAddress memory oldAddress = _removeAddress(addressId);

        // Emit event - AddressRemoved
        // The address data are put in the log so they remain accessible for ever
        emit AddressRemoved(addressId, oldAddress);
    }

    /**
     * Update an existing address. The updated address will have a new ID computed by the function.
     * Emits an AddressUpdated event.
     * Returns the ID of the new version of the address.
     */
    function updateAddress (
        bytes32 addressId, 
        string memory streetName,
        string memory postcode,
        string memory houseNumber,
        string memory boxNumber,
        string memory latitude,
        string memory longitude) public isOwner returns (bytes32) {

        // Check requirements - Deleted address exist
        require(belgianAddresses[addressId].addressId == addressId, "Requested address does not exist.");

        // Create address
        StreetAddress memory newAddress;
        newAddress.streetName = streetName;
        newAddress.postcode = postcode;
        newAddress.houseNumber = houseNumber;
        newAddress.boxNumber = boxNumber;
        newAddress.latitude = latitude;
        newAddress.longitude = longitude;
        bytes32 id = _createAddress(newAddress);

        // Remove the address
        StreetAddress memory oldAddress = _removeAddress(addressId);

        // Emit event AddressUpdated
        emit AddressUpdated (addressId, oldAddress, id);

        // Return ID of the new version of the address
        return id;
    }

    /***************************************************************************************************************/
    /*  VIEW FUNCTIONS                                                                                             */
    /***************************************************************************************************************/

    /**
     * Get an address by ID
     */
    function getAddress (bytes32 newAddressId) public view returns (StreetAddress memory) {
        // Require address exist
        require(belgianAddresses[newAddressId].addressId == newAddressId, "Requested address does not exist.");
        return belgianAddresses[newAddressId];
    }

    /**
     * Get the list of address ids related to a postcode.
     */
    function listAddressIdsByPostcode (string memory postcode) public view returns (bytes32 [] memory) {
        // Require postcode exist
        require (addressIdsByPostcode[postcode].length > 0, "The provided postcode does not exist");
        return addressIdsByPostcode[postcode];
    }

    /**
     * List all available postcodes
     */
    function listPostcodes () public view returns (string [] memory) {
        return postcodes;
    }

    /***************************************************************************************************************/
    /*  PRIVATE STATE FUNCTIONS                                                                                    */
    /***************************************************************************************************************/
    
    /**
     * Add an address to the registry.
     * The ID of the address is computed by the function and returned.
     */
    function _createAddress (StreetAddress memory newAddress) private returns (bytes32) {

        // Compute ID
        newAddress.addressId = keccak256(abi.encodePacked(newAddress.postcode, newAddress.streetName, newAddress.houseNumber, newAddress.boxNumber, newAddress.latitude, newAddress.longitude));
        
        // Check the address does not exist yet
        require(belgianAddresses[newAddress.addressId].addressId != newAddress.addressId, "Address already exist.");

        // Add address to the storage & the list of addresses by postcode
        belgianAddresses[newAddress.addressId] = newAddress;
        if(addressIdsByPostcode[newAddress.postcode].length <= 0) {
            // Postcode is not know -> Add to postcode list
            postcodes.push(newAddress.postcode);
        }

        // Update the list of address ids by postcode
        addressIdsByPostcode[newAddress.postcode].push(newAddress.addressId);

        // Return the new ID
        return newAddress.addressId;
    }

    /**
     * Remove an address from the registry.
     * A copy of the removed address is returned by the function
     */
    function _removeAddress (bytes32 addressID) private returns (StreetAddress memory) {
        // Require address exist
        require (belgianAddresses[addressID].addressId != 0x0, "Requested address does not exist");

        // Remove address from the list of addresses for the postcode
        string memory targetPostcode = belgianAddresses[addressID].postcode;
        for (uint i = 0 ; i < addressIdsByPostcode[targetPostcode].length ; i++) {
            if (addressIdsByPostcode[belgianAddresses[addressID].postcode][i] == addressID) { 
                // Replace by the last element & pop the alst element
                addressIdsByPostcode[belgianAddresses[addressID].postcode][i] =
                    addressIdsByPostcode[belgianAddresses[addressID].postcode][addressIdsByPostcode[targetPostcode].length-1];
                addressIdsByPostcode[belgianAddresses[addressID].postcode].pop();
                // Break
                i = addressIdsByPostcode[targetPostcode].length + 1;
            }
        }

        // Remove the postcode from the list if there are no addresses left
        if (addressIdsByPostcode[targetPostcode].length <= 0) {
            bytes32 postcodeHash = keccak256(abi.encodePacked(targetPostcode));
            for (uint i = 0 ; i < postcodes.length ; i++) {
                if (keccak256(abi.encodePacked(postcodes[i])) == postcodeHash) {
                    // Replace by last element and pop
                    postcodes[i] = postcodes[postcodes.length-1];
                    postcodes.pop();
                    // Break
                    i = postcodes.length + 1;
                }
            }
        }

        // Get a copy of the address that will be removed
        StreetAddress memory oldAddress = belgianAddresses[addressID];

        // Remove the address from storage
        delete belgianAddresses[addressID];

        // Return a copy of the removed address
        return oldAddress;
    }

    /***************************************************************************************************************/
    /*  PRIVATE UTILITY FUNCTIONS                                                                                  */
    /***************************************************************************************************************/
    
    /**
     * Explode UTF8 string into an array of codepoints that identify each readable character of the input string.
     * Returns the array of codepoints and the index of the last element of the array
     */
    function _explodeUtf8StringToCodepoints (string memory input) private pure returns (bytes32 [] memory, uint8) {
        
        uint8 count = 0;
        bytes memory input_rep = bytes(input);
        bytes32 [] memory results = new bytes32 [] (input_rep.length);

        for (uint i = 0 ; i < input_rep.length;)
        {
            if (uint8(input_rep[i]>>7)==0) {
                results[count] = keccak256(abi.encodePacked(input_rep[i]));
                i+=1;
            }
            else if (uint8(input_rep[i]>>5)==0x6) {
                results[count] = keccak256(abi.encodePacked(input_rep[i], input_rep[i+1]));
                i+=2;
            }
            else if (uint8(input_rep[i]>>4)==0xE) {
                results[count] = keccak256(abi.encodePacked(input_rep[i], input_rep[i+1], input_rep[i+2]));
                i+=3;
            }
            else if (uint8(input_rep[i]>>3)==0x1E) {
                results[count] = keccak256(abi.encodePacked(input_rep[i], input_rep[i+1], input_rep[i+2], input_rep[i+3]));
                i+=4;
            }
            else {
                //For safety
                results[count] = keccak256(abi.encodePacked(input_rep[i]));
                i+=1;
            }

            count++;
        }

        return (results, count);
    }

    /**
     * Find the minimum between three integers
     */
    function _min3(uint8 x, uint8 y, uint8 z) private pure returns (uint8) {
        if(x <= y && x <= z)
			return x;
		if(y <= x && y <= z)
			return y;
		else
			return z;
	}

    /**
     * Compute the levenshtein distance between two strings
     */ 
    function _levenshtein (string memory origin, string memory target) public pure returns (uint8) {


        // Explode both strings
        (bytes32[] memory origin_exploded, uint256 origin_exploded_length)  = _explodeUtf8StringToCodepoints(origin);
        (bytes32[] memory target_exploded, uint256 target_exploded_length)  = _explodeUtf8StringToCodepoints(target);

        // Create matrix for subproblems solutions
        uint8[8][8] memory matrix;

		// Initialising first column:
		for(uint8 i = 0; i <= origin_exploded_length; i++)
			matrix[i][0] = i;
		
		// Initialising first row:
		for(uint8 j = 0; j <= target_exploded_length; j++)
			matrix[0][j] = j;
		
		// Applying the algorithm:
		uint8 insertion;
        uint8 deletion;
        uint8 replacement;
		for(uint8 i = 1; i <= origin_exploded_length; i++) {
			for(uint8 j = 1; j <= target_exploded_length; j++) {
				if(origin_exploded[i - 1] == target_exploded[j - 1])
					matrix[i][j] = matrix[i - 1][j - 1];
				else {
					insertion = matrix[i][j - 1];
					deletion = matrix[i - 1][j];
					replacement = matrix[i - 1][j - 1];
					
					// Using the sub-problems
					matrix[i][j] = 1 + _min3(insertion, deletion, replacement);
				}
			}
		}
		
        uint8 r = matrix[origin_exploded_length][target_exploded_length];
		return r;
    }

    /***************************************************************************************************************/
    /*  PERMISSIONS MANAGEMENT                                                                                     */
    /***************************************************************************************************************/

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}
