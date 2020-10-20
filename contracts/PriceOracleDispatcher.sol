pragma solidity ^0.5.16;

import "./PriceOracle.sol";
import "./PriceOracleAdapter.sol";

contract PriceOracleDispatcher is PriceOracle {
    /// @notice Address of the guardian, which may set the SAI price once
    address public guardian;
    /// @notice Mapping of the cTokenAddress => adapterAddress
    mapping(address => address) public tokenAdapter;

    /// @param guardian_ The address of the guardian, which may set the
    constructor(address guardian_) public {
        guardian = guardian_;
    }

    /**
     * @notice Get the underlying price of a listed cToken asset
     * @param cToken The cToken to get the underlying price of
     * @return The underlying asset price mantissa (scaled by 1e18)
     */
    function getUnderlyingPrice(CToken cToken) public view returns (uint256) {
        //get adapter
        address oracleAdapter = tokenAdapter[address(cToken)];
        //validate mapping
        if (oracleAdapter == address(0)) {
            return uint256(0);
        }
        return PriceOracleAdapter(oracleAdapter).getPrice();
    }

    /**
     * @notice Set the underlying price of a listed cToken asset
     * @param addressToken Address of the cToken
     * @param addressAdapter Address of the OracleAdapter
     */
    function setAdapterToToken(address addressToken, address addressAdapter)
        public
    {
        //validate only guardian can set
        require(
            msg.sender == guardian,
            "PriceOracleDispatcher: only guardian may set the address"
        );
        //set token => adapter
        tokenAdapter[addressToken] = addressAdapter;
    }
}
