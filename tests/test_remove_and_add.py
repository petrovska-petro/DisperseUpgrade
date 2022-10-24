from brownie import reverts, ZERO_ADDRESS


def test_remove_governance(ibbtc_sink, current_payee_badger, proxy_admin):
    before_total_share = ibbtc_sink.totalShares()
    ibbtc_sink.removePayee(current_payee_badger, 0, {"from": proxy_admin})
    after_total_share = ibbtc_sink.totalShares()

    assert current_payee_badger not in ibbtc_sink.payees()
    assert after_total_share < before_total_share
    assert not ibbtc_sink.isPayee(current_payee_badger)


def test_remove_random_account(ibbtc_sink, accounts):
    with reverts("PaymentSplitter: not governance"):
        ibbtc_sink.removePayee(ZERO_ADDRESS, 0, {"from": accounts[3]})


def test_remove_not_right_account(ibbtc_sink, current_payee_badger, proxy_admin):
    ibbtc_sink.addPayee(current_payee_badger, 2000, {"from": proxy_admin})
    with reverts("PaymentSplitter: account to remove not matching"):
        ibbtc_sink.removePayee(current_payee_badger, 0, {"from": proxy_admin})


def test_remove_not_shares(ibbtc_sink, proxy_admin):
    with reverts("PaymentSplitter: account has not shares"):
        ibbtc_sink.removePayee(ZERO_ADDRESS, 0, {"from": proxy_admin})


def test_add_governance(ibbtc_sink, new_payee_badger, proxy_admin):
    SHARE = 5000

    before_total_share = ibbtc_sink.totalShares()
    ibbtc_sink.addPayee(new_payee_badger, SHARE, {"from": proxy_admin})
    after_total_share = ibbtc_sink.totalShares()

    assert new_payee_badger in ibbtc_sink.payees()
    assert after_total_share > before_total_share
    assert ibbtc_sink.isPayee(new_payee_badger)
    assert ibbtc_sink.shares(new_payee_badger) == SHARE
