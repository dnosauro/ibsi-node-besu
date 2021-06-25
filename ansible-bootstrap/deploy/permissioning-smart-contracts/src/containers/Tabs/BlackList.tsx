// Libs
import React from 'react';
import PropTypes from 'prop-types';
import { isAddress } from 'web3-utils';
import idx from 'idx';
// Context
import { useBlackListData } from '../../context/blacklistData';
// Utils
import useTab from './useTab';
import { errorToast } from '../../util/tabTools';
// Components
import BlackListTab from '../../components/BlackListTab/BlackListTab';
import LoadingPage from '../../components/LoadingPage/LoadingPage';
import NoContract from '../../components/Flashes/NoContract';
// Constants
import {
  PENDING_ADDITION,
  FAIL_ADDITION,
  PENDING_REMOVAL,
  FAIL_REMOVAL,
  SUCCESS,
  FAIL
} from '../../constants/transactions';

type BlackListTabContainerProps = {
  isOpen: boolean;
};

type Admin = {
  address: string;
  identifier: string;
  status: string;
};

const BlackListTabContainer: React.FC<BlackListTabContainerProps> = ({ isOpen }) => {
  const { blacklists, isAdmin, userAddress, dataReady, adminContract } = useBlackListData();
  const { list, modals, toggleModal, addTransaction, updateTransaction, deleteTransaction, openToast } = useTab(
    blacklists || [],
    (identifier: string) => ({ address: identifier })
  );


  if (!!adminContract) {

    const handleAdd = async (value: string) => {
      try {
        alert( value )
        const tx = await adminContract!.functions.addBlackList( value );
        toggleModal('add')(false);
        addTransaction(value, PENDING_ADDITION);
        const receipt = await tx.wait(1); // wait on receipt confirmations
        const addEvent = receipt.events!.filter(e => e.event && e.event === 'BlackListAdded').pop();
        if (!addEvent) {
          openToast(value, FAIL, `Error while processing Admin account: ${value}`);
        } else {
          const addSuccessResult = idx(addEvent, _ => _.args[0]);
          if (addSuccessResult === undefined) {
            openToast(value, FAIL, `Error while processing Admin account: ${value}`);
          } else if (Boolean(addSuccessResult)) {
            openToast(value, SUCCESS, `New Admin account processed: ${value}`);
          } else {
            const message = idx(addEvent, _ => _.args[2]);
            openToast(value, FAIL, message);
          }
        }
        deleteTransaction(value);
      } catch (e) {
        alert( e.message );
        toggleModal('add')(false);
        updateTransaction(value, FAIL_ADDITION);
        errorToast(e, value, openToast, () =>
        
          openToast(value, FAIL, 'Could not add account in black list', `${e} was unable to be added. Please try again.`)
        );
      }
    };

    const handleRemove = async (value: string) => {
      try {
        const est = await adminContract!.estimate.removeBlackList(value);
        const tx = await adminContract!.functions.removeBlackList(value, { gasLimit: est.toNumber() * 2 });
        toggleModal('remove')(false);
        addTransaction(value, PENDING_REMOVAL);
        await tx.wait(1); // wait on receipt confirmations
        openToast(value, SUCCESS, `Removal of blacklist account processed: ${value}`);
        deleteTransaction(value);
      } catch (e) {
        toggleModal('remove')(false);
        updateTransaction(value, FAIL_REMOVAL);
        errorToast(e, value, openToast, () =>
          openToast(
            value,
            FAIL,
            'Could not remove blacklist account',
            `${value} was unable to be removed. Please try again.`
          )
        );
      }
    };

    const isValidAdmin = (address: string) => {

      let isValidAddress = isAddress(address);
      if (!isValidAddress) {
        return {
          valid: false
        };
      }

      let isAdmin = list.filter((item: Admin) => item.address.toLowerCase() === address.toLowerCase()).length > 0;
      if (isAdmin) {
        return {
          valid: false,
          msg: 'Account address is already in blacklist.'
        };
      }

      return {
        valid: true
      };
    };

    if (isOpen && dataReady) {
      return (
        <BlackListTab
          list={list}
          userAddress={userAddress}
          modals={modals}
          toggleModal={toggleModal}
          handleAdd={handleAdd}
          handleRemove={handleRemove}
          isAdmin={isAdmin}
          deleteTransaction={deleteTransaction}
          isValid={isValidAdmin}
          isOpen={isOpen}
        />
      );
    } else if (isOpen && !dataReady) {
      return <LoadingPage />;
    } else {
      return <div />;
    }
  } else if (isOpen && !adminContract) {
    alert("no contract");
    return <NoContract tabName="Admin" />;
  } else {
    return <div />;
  }
};

BlackListTabContainer.propTypes = {
  isOpen: PropTypes.bool.isRequired
};

export default BlackListTabContainer;
