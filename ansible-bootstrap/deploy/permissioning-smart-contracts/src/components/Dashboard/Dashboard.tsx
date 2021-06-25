// Libs
import React, { Fragment, memo } from 'react';
import PropTypes from 'prop-types';
import { AccountDataProvider } from '../../context/accountData';
import { AdminDataProvider } from '../../context/adminData';
import { NodeDataProvider } from '../../context/nodeData';
import { BlackListDataProvider } from '../../context/blacklistData';


// Components
import TabSelector from './TabSelector';
import Toasts from '../../containers/Toasts/Toasts';
import AccountTab from '../../containers/Tabs/Account';
import AdminTab from '../../containers/Tabs/Admin';
import EnodeTab from '../../containers/Tabs/Enode';
import BlackListTab from '../../containers/Tabs/BlackList';
// Context
import { ToastProvider } from '../../context/toasts';
// Constants
import { ACCOUNT_TAB, ADMIN_TAB, ENODE_TAB, BLACKLIST_TAB } from '../../constants/tabs';

type Dashboard = {
  tab: string;
  setTab: (tab: string) => void;
};

const Dashboard: React.FC<Dashboard> = ({ tab, setTab }) => (
  <Fragment>
    <TabSelector setTab={setTab} tab={tab} />
    {
      <ToastProvider>
        <Toasts />
        <AdminDataProvider>
         <NodeDataProvider>
            <EnodeTab isOpen={tab === ENODE_TAB} />
          </NodeDataProvider>
          <AccountDataProvider>
            <AccountTab isOpen={tab === ACCOUNT_TAB} />
          </AccountDataProvider>
          <AdminTab isOpen={tab === ADMIN_TAB} />
          <BlackListDataProvider>
            <BlackListTab isOpen={tab === BLACKLIST_TAB} />
          </BlackListDataProvider>
        </AdminDataProvider>
      </ToastProvider>
    }
  </Fragment>
);

Dashboard.propTypes = {
  setTab: PropTypes.func.isRequired,
  tab: PropTypes.string.isRequired
};

export default memo(Dashboard);
