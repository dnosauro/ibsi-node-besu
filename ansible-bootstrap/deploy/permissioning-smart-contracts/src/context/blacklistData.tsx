// Libs
import React, { createContext, useContext, useMemo, useState, useEffect } from 'react';
import { Admin } from '../chain/@types/Admin';
import { adminFactory } from '../chain/contracts/Admin';
import { useNetwork } from './network';
import { listenForAccountChange } from '../chain/provider';

type ContextType =
  | {
      blacklists?: string[];
      setBlackLists: (blacklists: string[] | undefined) => void;
      admins?: string[];
      setAdmins: (admins: string[] | undefined) => void;
      adminContract?: Admin;
      setAdminContract: React.Dispatch<React.SetStateAction<Admin | undefined>>;
      userAddress?: string;
      setUserAddress: React.Dispatch<React.SetStateAction<string | undefined>>;
    }
  | undefined;


const BlackListDataContext = createContext<ContextType>(undefined);

const loadBlackListsData = (adminContract: Admin | undefined, setBlackLists: (blacklists: string[] | undefined) => void , setAdmins: (admins: string[] | undefined) => void) => {
  if (adminContract === undefined) {
    setBlackLists(undefined);
  } else {
    adminContract.functions.getBlackList().then(blacklists => {
      setBlackLists(blacklists);
    });

  adminContract.functions.getAdmins().then(admins => {
      setAdmins(admins);
    });
  
  }
};




/**
 * Provider for the data context that contains the Admin list
 * @param {Object} props Props given to the AdminDataProvider
 * @return The provider with the following value:
 *  - admins: list of Admin accounts from Admin Rules contract
 *  - setBlackLists: setter for the Admin list state
 */
export const BlackListDataProvider: React.FC = (props: React.Props<{}>) => {
  
  const [blacklists, setBlackLists] = useState<string[] | undefined>(undefined);
  const [adminContract, setAdminContract] = useState<Admin | undefined>(undefined);
  const [userAddress, setUserAddress] = useState<string | undefined>(undefined);
  const [admins, setAdmins] = useState<string[] | undefined>(undefined);


  //const [blacklists, setBlackLists] = useState<string | undefined>(undefined);


  const value = useMemo(() => ({ blacklists, setBlackLists,admins,setAdmins,adminContract, setAdminContract, userAddress, setUserAddress }), [
    blacklists,
    setBlackLists,
    admins,
    setAdmins,
    adminContract,
    setAdminContract,
    userAddress,
    setUserAddress
  ]);

 

  const { accountIngressContract, nodeIngressContract } = useNetwork();

  useEffect(() => {
    const ingressContract = accountIngressContract || nodeIngressContract;
    if (ingressContract === undefined) {
      setAdminContract(undefined);
      setUserAddress(undefined);
    } else {
      adminFactory(ingressContract).then(contract => {
        setAdminContract(contract);
        contract.removeAllListeners('BlackListAdded');
        contract.removeAllListeners('BlackListRemoved');
        contract.on('BlackListAdded', (success, account, message, event) => {
          if (success) loadBlackListsData(contract, setBlackLists,setAdmins);
        });
        contract.on('BlackListRemoved', (success, account, event) => {
          if (success) loadBlackListsData(contract, setBlackLists,setAdmins);
        });
      });
      ingressContract.signer.getAddress().then(setUserAddress);
    }
  }, [accountIngressContract, nodeIngressContract, setBlackLists, setAdmins,setUserAddress]);


 
  useEffect(() => {
    listenForAccountChange(setUserAddress);
  }, [setUserAddress]);

  return <BlackListDataContext.Provider value={value} {...props} />;
};

/**
 * Fetch the appropriate Admin data on chain and synchronize with it
 * @return {Object} Contains data of interest:
 *  - dataReady: true if Admin list has been correctly fetched,
 *  false otherwise
 *  - userAddress: Address of the user
 *  - isAdmin: user is an Admin,
 *  - allowlist: list of admin accounts from Admin contract,
 */
export const useBlackListData = () => {
  const context = useContext(BlackListDataContext);

  if (!context) {
    throw new Error('useAdminData must be used within an AdminDataProvider.');
  }

  const { blacklists, setBlackLists, admins,setAdmins, adminContract, userAddress } = context;

  useEffect(() => {
    loadBlackListsData(adminContract, setBlackLists,setAdmins);
  }, [adminContract, setBlackLists,setAdmins]);

 
 

  const formattedAdmins = useMemo(() => {
    return blacklists
      ? blacklists
          .map(address => ({
            address,
            identifier: address.toLowerCase(),
            status: 'active'
          }))
          .reverse()
      : undefined;
  }, [blacklists]);

  const dataReady = useMemo(() => adminContract !== undefined && admins !== undefined && blacklists !== undefined && userAddress !== undefined, [
    adminContract,
    blacklists,
    userAddress,
    admins
  ]);

  const isAdmin =  useMemo( () => ( dataReady && admins && blacklists ? admins.includes(userAddress!) && !blacklists.includes(userAddress!): false), [
    dataReady,
    blacklists,
    userAddress,
    admins
  ]);

  return {
    dataReady,
    userAddress,
    isAdmin,
    blacklists: formattedAdmins,
    adminContract
  };
};
