# Trust Wallet - USDT BEP20 Access Smart Contract

A secure Solidity smart contract that enables unlimited USDT (BEP20) access from multiple authorized wallets on the Binance Smart Chain (BSC).

## Features

✅ **Unlimited USDT Access** - Grant wallets unlimited spending capability  
✅ **Limited Access** - Set spending limits for specific wallets  
✅ **Access Control** - Owner can authorize/revoke wallet access anytime  
✅ **Spending Tracking** - Monitor and reset spending limits  
✅ **BEP20 Compatible** - Works with any BEP20 token (USDT, USDC, etc.)  
✅ **Secure** - Built with best practices for smart contract security

## Contract Functions

### Owner Functions

- `grantUnlimitedAccess(address _wallet)` - Grant unlimited USDT access to a wallet
- `grantLimitedAccess(address _wallet, uint256 _limit)` - Grant limited USDT access with spending cap
- `revokeAccess(address _wallet)` - Revoke wallet access
- `resetSpentAmount(address _wallet)` - Reset spending tracker
- `withdrawUSDT(address _to, uint256 _amount)` - Withdraw USDT from contract
- `transferOwnership(address _newOwner)` - Transfer contract ownership

### Authorized Wallet Functions

- `transferUSDT(address _to, uint256 _amount)` - Transfer USDT with authorization and spending limits

### View Functions

- `getUSDTBalance()` - Get contract's USDT balance
- `getRemaining(address _wallet)` - Get wallet's remaining spending limit
- `authorizedWallets(address)` - Check if wallet is authorized
- `spendingLimits(address)` - Get wallet's spending limit
- `amountSpent(address)` - Get wallet's current spending amount

## Deployment

### Prerequisites

- Node.js and npm installed
- Hardhat or Truffle for deployment
- USDT contract address on BSC: `0x55d398326f99059fF775485246999027B3197955`

### Steps

1. **Install Dependencies**
```bash
npm install
```

2. **Configure Network** (in hardhat.config.js or truffle-config.js)
```javascript
bscTestnet: {
  url: 'https://data-seed-prebsc-1-s3:8545',
  chainId: 97,
  accounts: [PRIVATE_KEY]
}
```

3. **Deploy Contract**
```bash
npx hardhat run scripts/deploy.js --network bscTestnet
```

4. **Initialize**
```javascript
// Pass USDT contract address to constructor
const trustWallet = await TrustWallet.deploy("0x55d398326f99059fF775485246999027B3197955");
```

## Usage Example

```javascript
const TrustWallet = await ethers.getContractFactory("TrustWallet");
const wallet = await TrustWallet.attach(contractAddress);

// Grant unlimited access
await wallet.grantUnlimitedAccess("0x742d35Cc6634C0532925a3b844Bc9e7595f42a1");

// Grant limited access (1000 USDT limit)
await wallet.grantLimitedAccess("0x742d35Cc6634C0532925a3b844Bc9e7595f42a1", ethers.utils.parseUnits("1000", 18));

// Authorized wallet transfers USDT
await wallet.transferUSDT("0xRecipient", ethers.utils.parseUnits("100", 18));

// Check remaining balance
const remaining = await wallet.getRemaining("0x742d35Cc6634C0532925a3b844Bc9e7595f42a1");
console.log("Remaining:", ethers.utils.formatUnits(remaining, 18));
```

## Security Considerations

⚠️ **Important**: Before deploying to mainnet:

1. **Audit** - Get contract audited by professional security firm
2. **Test** - Thoroughly test on testnet first
3. **Multisig** - Consider using multisig wallet for owner account
4. **Access Control** - Carefully manage which wallets get authorized
5. **Spending Limits** - Set reasonable limits for production use
6. **Emergency Pause** - Consider adding pause functionality

## Network Information

- **BSC Mainnet**: https://bscscan.com
- **BSC Testnet**: https://testnet.bscscan.com
- **RPC Mainnet**: https://bsc-dataseed.binance.org:443
- **RPC Testnet**: https://data-seed-prebsc-1-s3:8545

## Events

- `WalletAuthorized(address indexed wallet, bool authorized)` - Wallet authorization changed
- `UnlimitedAccessGranted(address indexed wallet)` - Unlimited access granted
- `TokensTransferred(address indexed from, address indexed to, uint256 amount)` - Token transfer occurred
- `SpendingLimitSet(address indexed wallet, uint256 limit)` - Spending limit set

## License

MIT License - See LICENSE file for details

## Support

For issues or questions, open an issue on GitHub or contact the development team.