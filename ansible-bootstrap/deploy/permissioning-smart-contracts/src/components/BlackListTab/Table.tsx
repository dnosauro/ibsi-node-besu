// Libs
import React from 'react';
import PropTypes from 'prop-types';
// Rimble Components
import { Table, Box } from 'rimble-ui';
// Components
import BlackListTableHeader from './TableHeader';
import BlackListRow from './BlackListRow';
// Styles
import styles from './styles.module.scss';

type BlackListTable = {
  list: { address: string; status: string }[];
  toggleModal: (name: 'add' | 'remove' | 'lock') => (value?: boolean | string) => void;
  deleteTransaction: (identifer: string) => void;
  isAdmin: boolean;
  userAddress?: string;
};

const BlackListTable: React.FC<BlackListTable> = ({ list, toggleModal, deleteTransaction, isAdmin, userAddress }) => (
  <Box mt={5}>
    <BlackListTableHeader number={list.length} openAddModal={() => toggleModal('add')(true)} disabledAdd={!isAdmin} />
    <Table mt={4}>
      <thead>
        <tr>
          <th className={styles.headerCell}>BlackList Address</th>
          <th className={styles.headerCell}>Status</th>
        </tr>
      </thead>
      <tbody>
        {list.map(({ address, status }) => (
          <BlackListRow
            key={address}
            address={address}
            status={status}
            isSelf={userAddress === address}
            isAdmin={isAdmin}
            deleteTransaction={deleteTransaction}
            openRemoveModal={toggleModal('remove')}
          />
        ))}
      </tbody>
    </Table>
  </Box>
);

BlackListTable.propTypes = {
  list: PropTypes.array.isRequired,
  toggleModal: PropTypes.func.isRequired,
  deleteTransaction: PropTypes.func.isRequired,
  isAdmin: PropTypes.bool.isRequired,
  userAddress: PropTypes.string
};

export default BlackListTable;
