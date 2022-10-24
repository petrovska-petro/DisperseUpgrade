import pytest

from brownie import web3, interface, Disperse


@pytest.fixture
def deployer(accounts):
    return accounts[0]


@pytest.fixture
def current_payee_dfd(accounts):
    return accounts.at("0x5b5cF8620292249669e1DCC73B753d01543D6Ac7", force=True)


@pytest.fixture
def current_payee_badger(accounts):
    return accounts.at("0xB65cef03b9B89f99517643226d76e286ee999e77", force=True)


@pytest.fixture
def new_payee_badger(accounts):
    return accounts.at("0x042B32Ac6b453485e357938bdC38e0340d4b9276", force=True)


@pytest.fixture
def ibbtc_sink():
    return interface.IDisperse("0x3B823864cd0CBad8a1f2B65d4807906775BecAa7")


@pytest.fixture
def proxy_admin(accounts):
    return accounts.at("0xCF7346A5E41b0821b80D5B3fdc385EEB6Dc59F44", force=True)


@pytest.fixture
def proxy():
    return interface.IProxyAdmin("0xbf0e27fdf5ef7519a9540df401cce0a7a4cd75bc")


@pytest.fixture
def disperse(deployer):
    return Disperse.deploy({"from": deployer})


@pytest.fixture(autouse=True)
def upgrade_proxy_implementation(ibbtc_sink, proxy, disperse, proxy_admin):
    IMPLEMENTATION_SLOT = (
        "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc"
    )

    proxy.upgrade(ibbtc_sink.address, disperse.address, {"from": proxy_admin})

    # check new implementation address
    assert web3.toChecksumAddress(
        web3.eth.getStorageAt(ibbtc_sink.address, IMPLEMENTATION_SLOT).hex()
    ) == web3.toChecksumAddress(disperse.address)
    # check gov new variable if set
    assert ibbtc_sink.governance() == "0xCF7346A5E41b0821b80D5B3fdc385EEB6Dc59F44"
