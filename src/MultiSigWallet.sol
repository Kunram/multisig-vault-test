// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title EVM Multi-Signature Vault
contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    error NotOwner();
    error TxNotExists();
    error TxAlreadyExecuted();
    error TxAlreadyConfirmed();
    error TxNotConfirmed();
    error QuorumNotReached();
    error TxFailed();
    error InvalidConfiguration();

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public isConfirmed;

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    modifier txExists(uint _txIndex) {
        if (_txIndex >= transactions.length) revert TxNotExists();
        _;
    }

    modifier notExecuted(uint _txIndex) {
        if (transactions[_txIndex].executed) revert TxAlreadyExecuted();
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        if (isConfirmed[_txIndex][msg.sender]) revert TxAlreadyConfirmed();
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        if (_owners.length == 0 || _numConfirmationsRequired == 0 || _numConfirmationsRequired > _owners.length) {
            revert InvalidConfiguration();
        }

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            if (owner == address(0) || isOwner[owner]) revert InvalidConfiguration();
            
            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function submitTransaction(address _to, uint _value, bytes calldata _data) external onlyOwner {
        uint txIndex = transactions.length;
        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint _txIndex)
        external
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        transactions[_txIndex].numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex)
        external
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage txn = transactions[_txIndex];
        if (txn.numConfirmations < numConfirmationsRequired) revert QuorumNotReached();

        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        if (!success) revert TxFailed();

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        external
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        if (!isConfirmed[_txIndex][msg.sender]) revert TxNotConfirmed();

        transactions[_txIndex].numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }
}
