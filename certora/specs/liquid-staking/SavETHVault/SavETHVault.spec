
methods {
    indexOwnedByTheVault() returns uint256 envfree
    getBalance(address) returns uint256
    getContractBalance() returns uint256
    burnLPTokensByBLS(bytes[], uint256[])

    execute(address, bytes, uint256) returns bytes => DISPATCHER(true)
    execute() returns bool => DISPATCHER(true)
}

rule shouldWithdrawETHForStaking(env e, address smartWallet, uint256 amount) {
    uint256 smartWalletBalanceBefore = getBalance(e, smartWallet);
    uint256 contractBalanceBefore = getContractBalance(e);
    withdrawETHForStaking(e, smartWallet, amount);
    uint256 smartWalletBalanceAfter = getBalance(e, smartWallet);
    uint256 contractBalanceAfter = getContractBalance(e);

    assert smartWalletBalanceAfter - smartWalletBalanceBefore == amount, "Incorrect wallet transfer amount";
    assert contractBalanceBefore - contractBalanceAfter >= amount, "Incorrect contract balance change";
}

rule shouldDepositETHForStaking(env e, bytes blsPublicKey) {
    require e.msg.value > 0;
    require blsPublicKey.length == 64;
    uint256 amount = e.msg.value;
    require amount <= 24000000000000000000;

    uint256 userBalanceBefore = getBalance(e, e.msg.sender);
    uint256 savETHVaultBalanceBefore = getContractBalance(e);
    
    depositETHForStaking(e, blsPublicKey, amount);
    
    uint256 userBalanceAfter = getBalance(e, e.msg.sender);
    uint256 savETHVaultBalanceAfter = getContractBalance(e);
    uint256 userLPTokenBalance = getLPTokenBalanceByBLSPublicKey(e, blsPublicKey, e.msg.sender);

    assert savETHVaultBalanceAfter - savETHVaultBalanceBefore == amount, "Invalid transfer to savETH vault";
    assert userBalanceBefore - userBalanceAfter >= amount, "Invalid balance reduction";
    assert userLPTokenBalance == amount, "Incorrect LP token minting";
}

rule shouldBurnLPTokenByBLS(env e, bytes blsPublicKey) {
    require blsPublicKey.length == 64;
    uint256 amount = e.msg.value;
    require amount <= 24000000000000000000;

    uint256 userBalanceBeforeDeposit = getBalance(e, e.msg.sender);
    uint256 savETHVaultBalanceBeforeDeposit = getContractBalance(e);
    uint256 userLPTokenBalanceBeforeDeposit = getLPTokenBalanceByBLSPublicKey(e, blsPublicKey, e.msg.sender);
    uint256 lpTokenTotalSupplyBeforeDeposit = getTotalSupplyOfLPTokenByBLSPublicKey(e, blsPublicKey);
    
    depositETHForStaking(e, blsPublicKey, amount);
    
    uint256 userBalanceAfterDeposit = getBalance(e, e.msg.sender);
    uint256 savETHVaultBalanceAfterDeposit = getContractBalance(e);
    uint256 userLPTokenBalanceAfterDeposit = getLPTokenBalanceByBLSPublicKey(e, blsPublicKey, e.msg.sender);
    uint256 lpTokenTotalSupplyAfterDeposit = getTotalSupplyOfLPTokenByBLSPublicKey(e, blsPublicKey);

    assert savETHVaultBalanceAfterDeposit - savETHVaultBalanceBeforeDeposit == amount, "Invalid transfer to savETH vault";
    assert userBalanceBeforeDeposit - userBalanceAfterDeposit >= amount, "Invalid balance reduction";
    assert userLPTokenBalanceAfterDeposit - userLPTokenBalanceBeforeDeposit == amount, "Incorrect LP token minting";
    assert lpTokenTotalSupplyAfterDeposit - lpTokenTotalSupplyBeforeDeposit == amount, "Incorrect change in LP token total supply";

    bytes[] blsPublicKeyArray = [blsPublicKey];
    uint256[] amountArray = [amount];
    uint256 userBalanceBeforeBurn = getBalance(e, e.msg.sender);

    burnLPTokensByBLS(e, blsPublicKeyArray, amountArray);

    uint256 userLPTokenBalanceAfterBurn = getLPTokenBalanceByBLSPublicKey(e, blsPublicKey, e.msg.sender);
    uint256 savETHVaultBalanceAfterBurn = getContractBalance(e);
    uint256 lpTokenTotalSupplyAfterBurn = getTotalSupplyOfLPTokenByBLSPublicKey(e, blsPublicKey);
    uint256 userBalanceAfterBurn = getBalance(e, e.msg.sender);

    assert lpTokenTotalSupplyAfterDeposit - lpTokenTotalSupplyAfterBurn == amount, "Incorrect LP token supply reduction";
    assert userLPTokenBalanceAfterDeposit - userLPTokenBalanceAfterBurn == amount, "Incorrect LP token burn for user";
    assert userBalanceAfterBurn - userBalanceAfterDeposit == amount, "Incorrect ETH redeemed after burn";
    assert savETHVaultBalanceAfterDeposit - savETHVaultBalanceAfterBurn == amount, "Incorrect ETH sent from savETH vault";
}
