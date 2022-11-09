certoraRun \
contracts/testing/liquid-staking/MockLiquidStakingManager.sol \
contracts/smart-wallet/OwnableSmartWallet.sol \
    --verify MockLiquidStakingManager:certora/specs/liquid-staking/LiquidStakingManager/LiquidStakingManager.spec \
    --loop_iter 1 --optimistic_loop \
    --msg "LiquidStakingManagerMock" \
    --packages @blockswaplab=node_modules/@blockswaplab @openzeppelin=node_modules/@openzeppelin \
    --send_only \
    --optimize 1 \
    --rule_sanity basic
