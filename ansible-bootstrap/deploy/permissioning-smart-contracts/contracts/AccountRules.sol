pragma solidity 0.5.9;

import "./AccountRulesProxy.sol";
import "./AccountRulesList.sol";
import "./AccountIngress.sol";
import "./Admin.sol";


contract AccountRules is AccountRulesProxy, AccountRulesList {

    // in read-only mode rules can't be added/removed
    // this will be used to protect data when upgrading contracts
    bool private readOnlyMode = false;
    // version of this contract: semver like 1.2.14 represented like 001002014
    uint private version = 1000000;

    AccountIngress private ingressContract;

    modifier onlyOnEditMode() {
        require(!readOnlyMode, "In read only mode: rules cannot be modified");
        _;
    }

    modifier onlyAdmin() {
        address adminContractAddress = ingressContract.getContractAddress(ingressContract.ADMIN_CONTRACT());
        require(adminContractAddress != address(0), "Ingress contract must have Admin contract registered");
        require(Admin(adminContractAddress).isAuthorized(msg.sender), "Sender not authorized");
        _;
    }

    constructor (AccountIngress _ingressContract) public {
        ingressContract = _ingressContract;
	// commentare la seguente riga per non inserire l'account amministratore nella lista degli amministratori degli smartcontract
        //add(msg.sender);
    }

    // VERSION
    function getContractVersion() public view returns (uint) {
        return version;
    }

    // READ ONLY MODE
    function isReadOnly() public view returns (bool) {
        return readOnlyMode;
    }

    function enterReadOnly() public onlyAdmin returns (bool) {
        require(readOnlyMode == false, "Already in read only mode");
        readOnlyMode = true;
        return true;
    }

    function exitReadOnly() public onlyAdmin returns (bool) {
        require(readOnlyMode == true, "Not in read only mode");
        readOnlyMode = false;
        return true;
    }

    function transactionAllowed(
        address sender,
        address target, // target
        uint256, // value
        uint256, // gasPrice
        uint256, // gasLimit
        bytes memory // payload
    ) public view returns (bool) {

        address blacklistContractAddress = ingressContract.getContractAddress(ingressContract.ADMIN_CONTRACT());
        if (Admin(blacklistContractAddress).isBlackListed(sender)) {
	    //FALSE, l'account e' nella blacklist non puo' fare transazioni
            return false;
	} else if (target != 0x0000000000000000000000000000000000000000 ) {
	    //TRUE, la transazione non e' un deploy di smartcontract, ogni account non in blacklist puo' fare transazioni
            return true;
        } else if ( accountPermitted (sender) ) {
	    // TRUE, la transazione e' un deploy di smartcontract e l'account e' nella lista degli amministratori di smartcontract
            return true;
        } else {
	    // FALSE, la transazione e' un deploy di smartcontract ma l'account non e' nella lista degli amministratori di smartcontract
            return false;
        }

    }

    function accountPermitted(
        address _account
    ) public view returns (bool) {
        return exists(_account);
    }

    function addAccount(
        address account
    ) public onlyAdmin onlyOnEditMode returns (bool) {
        bool added = add(account);
        emit AccountAdded(added, account);
        return added;
    }

    function removeAccount(
        address account
    ) public onlyAdmin onlyOnEditMode returns (bool) {
        bool removed = remove(account);
        emit AccountRemoved(removed, account);
        return removed;
    }

    function getSize() public view returns (uint) {
        return size();
    }

    function getByIndex(uint index) public view returns (address account) {
        return allowlist[index];
    }

    function getAccounts() public view returns (address[] memory){
        return allowlist;
    }

    function addAccounts(address[] memory accounts) public onlyAdmin returns (bool) {
        return addAll(accounts);
    }
}
