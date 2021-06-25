const AllowlistUtils = require('../scripts/allowlist_utils');
const fs = require('fs') 
const Admin = artifacts.require("./Admin.sol");

module.exports = async(deployer, network) => {
    // exit early if we are NOT redeploying this contract
    let retainCurrentRulesContract = AllowlistUtils.getRetainAdminContract();
    if (retainCurrentRulesContract) {
        console.log("not deploying Admin Rules because retain=" + retainCurrentRulesContract);
        return;
    }
    await deployer.deploy(Admin);
    console.log("   > Admin contract deployed with address = " + Admin.address);
    fs.writeFile('AdminContractAddress.txt', "Admin contract deployed with address = " + Admin.address, (err) => { 
        // In case of a error throw err. 
        if (err) throw err; 
    }) 

    let instance = await Admin.deployed();

    if(AllowlistUtils.isInitialAdminAccountsAvailable()) {
        console.log("   > Adding Initial Admin Accounts ...");
        let initialAdminAccounts = AllowlistUtils.getInitialAdminAccounts();
        if (initialAdminAccounts.length > 0) {
            let adminAddedResult = await instance.addAdmins(initialAdminAccounts);
            console.log ("   > Initial admin accounts added : " + initialAdminAccounts); 
        }
    } 
}
