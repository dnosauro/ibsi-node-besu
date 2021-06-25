pragma solidity 0.5.9;



contract AdminList {

    event AdminAdded(
        bool adminAdded,
        address account,
        string message
    );

    event AdminRemoved(
        bool adminRemoved,
        address account
    );

    //BlackList
    event BlackListAdded(
        bool adminAdded,
        address account,
        string message
    );

    event BlackListRemoved(
        bool adminRemoved,
        address account
    );

    address[] public allowlist;
    mapping (address => uint256) private indexOf; //1 based indexing. 0 means non-existent

    // Black list
    address[] public blacklist;
    mapping (address => uint256) private blacklistindexOf; //1 based indexing. 0 means non-existent

    function size() internal view returns (uint256) {
        return allowlist.length;
    }

    // Black list
    function sizeBlackList() internal view returns (uint256) {
        return blacklist.length;
    }

    function exists(address _account) internal view returns (bool) {
        return indexOf[_account] != 0;
    }

    // Black list
    function existsInBlackList(address _account) internal view returns (bool) {
        return blacklistindexOf[_account] != 0;
    }

    function add(address _account) internal returns (bool) {
        if (indexOf[_account] == 0) {
            indexOf[_account] = allowlist.push(_account);
            return true;
        }
        return false;
    }

    // Black list
    function addInBlackList(address _account) internal returns (bool) {
        if (blacklistindexOf[_account] == 0) {
            blacklistindexOf[_account] = blacklist.push(_account);
            return true;
        }
        return false;
    }

    function addAll(address[] memory accounts) internal returns (bool) {
        bool allAdded = true;
        for (uint i = 0; i<accounts.length; i++) {
            if (msg.sender == accounts[i]) {
                emit AdminAdded(false, accounts[i], "Adding own account as Admin is not permitted");
                allAdded = allAdded && false;
            } else if (exists(accounts[i])) {
                emit AdminAdded(false, accounts[i], "Account is already an Admin");
                allAdded = allAdded && false;
            }  else {
                bool result = add(accounts[i]);
                string memory message = result ? "Admin account added successfully" : "Account is already an Admin";
                emit AdminAdded(result, accounts[i], message);
                allAdded = allAdded && result;
            }
        }

        return allAdded;
    }

    // Black list
    function addBlackListAll(address[] memory accounts) internal returns (bool) {
        bool allAdded = true;
        for (uint i = 0; i<accounts.length; i++) {
            if (msg.sender == accounts[i]) {
                emit BlackListAdded(false, accounts[i], "Adding in black list is not permitted");
                allAdded = allAdded && false;
            } else if (existsInBlackList(accounts[i])) {
                emit BlackListAdded(false, accounts[i], "Account is already in black list");
                allAdded = allAdded && false;
            }  else {
                bool result = addInBlackList (accounts[i]);
                string memory message = result ? "account added successfully in black list" : "Account is already in black list";
                emit BlackListAdded(result, accounts[i], message);
                allAdded = allAdded && result;
            }
        }
        return allAdded;
    }

    function remove(address _account) internal returns (bool) {
        uint256 index = indexOf[_account];
        if (index > 0 && index <= allowlist.length) { //1-based indexing
            //move last address into index being vacated (unless we are dealing with last index)
            if (index != allowlist.length) {
                address lastAccount = allowlist[allowlist.length - 1];
                allowlist[index - 1] = lastAccount;
                indexOf[lastAccount] = index;
            }

            //shrink array
            allowlist.length -= 1; // mythx-disable-line SWC-101
            indexOf[_account] = 0;
            return true;
        }
        return false;
    }

    // Black list
    function removeInBlackList(address _account) internal returns (bool) {
        uint256 index = blacklistindexOf[_account];
        if (index > 0 && index <= blacklist.length) { //1-based indexing
            //move last address into index being vacated (unless we are dealing with last index)
            if (index != blacklist.length) {
                address lastAccount = blacklist[blacklist.length - 1];
                blacklist[index - 1] = lastAccount;
                blacklistindexOf[lastAccount] = index;
            }

            //shrink array
            blacklist.length -= 1; // mythx-disable-line SWC-101
            blacklistindexOf[_account] = 0;
            return true;
        }
        return false;
    }
}
