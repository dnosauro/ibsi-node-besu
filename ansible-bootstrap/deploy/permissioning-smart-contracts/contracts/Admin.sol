pragma solidity 0.5.9;

import "./AdminProxy.sol";
import "./AdminList.sol";


contract Admin is AdminProxy, AdminList {
    modifier onlyAdmin() {
        require(isAuthorized(msg.sender), "Sender not authorized");
        _;
    }

    modifier notSelf(address _address) {
        require(msg.sender != _address, "Cannot invoke method with own account as parameter");
        _;
    }

    constructor() public {
        add(msg.sender);
    }

    function isAuthorized(address _address) public view returns (bool) {
        return exists(_address);
    }

    // BlackList
    function isBlackListed(address _address) public view returns (bool) {
        return existsInBlackList(_address);
    }

    function addAdmin(address _address) public onlyAdmin returns (bool) {
        if (msg.sender == _address) {
            emit AdminAdded(false, _address, "Adding own account as Admin is not permitted");
            return false;
        } else if ( isBlackListed(_address) ) {
            // non aggiungo agli admin un account in blacklist
            emit AdminAdded(false, _address, "Adding account blacklisted as Admin is not permitted");
            return false;
	} else {
            bool result = add(_address);
            string memory message = result ? "Admin account added successfully" : "Account is already an Admin or BlackListed";
            emit AdminAdded(result, _address, message);
            return result;
        }
    }

    // BlackList
    function addBlackList(address _address) public onlyAdmin returns (bool) {
        if (msg.sender == _address) {
            emit BlackListAdded(false, _address, "Adding own account as BlackListed is not permitted");
            return false;
        } else {
            // rimuovo i permessi di admin all'account che sto inserendo in blacklist
            removeAdmin(_address);
            bool result = addInBlackList(_address);
            string memory message = result ? "BlackList account added successfully" : "Account is already an BlackList";
            emit BlackListAdded(result, _address, message);
            return result;
        }
    }

    function removeAdmin(address _address) public onlyAdmin notSelf(_address) returns (bool) {
        bool removed = remove(_address);
        emit AdminRemoved(removed, _address);
        return removed;
    }

    // BlackList
    function removeBlackList(address _address) public onlyAdmin notSelf(_address) returns (bool) {
        bool removed = removeInBlackList(_address);
        emit BlackListRemoved(removed, _address);
        return removed;
    }

    function getAdmins() public view returns (address[] memory){
        return allowlist;
    }

    // BlackList
    function getBlackList() public view returns (address[] memory){
        return blacklist;
    }

    function addAdmins(address[] memory accounts) public onlyAdmin returns (bool) {
        return addAll(accounts);
    }

    // BlackList
    function addInBlackList(address[] memory accounts) public onlyAdmin returns (bool) {
        return addBlackListAll(accounts);
    }

}
