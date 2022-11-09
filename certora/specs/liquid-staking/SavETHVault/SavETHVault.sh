certoraRun \
contracts/testing/liquid-staking/MockSavETHVault.sol \
contracts/smart-wallet/OwnableSmartWallet.sol \
    --verify MockSavETHVault:certora/specs/liquid-staking/SavETHVault/SavETHVault.spec \
    --loop_iter 1 --optimistic_loop \
    --msg "SavETHVaultMock" \
    --packages @blockswaplab=node_modules/@blockswaplab @openzeppelin=node_modules/@openzeppelin \
    --send_only \
    --optimize 1 \
    --rule_sanity basic
