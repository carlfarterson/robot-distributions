// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '@openzeppelin/upgrades/contracts/Initializable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/cryptography/MerkleProof.sol';
import './interfaces/IMerkleDistributor.sol';

contract MerkleDistributor is Initializable, Ownable, IMerkleDistributor {

    event CancelDrop();

    address public owner;
    address public immutable override token;
    bytes32 public immutable override merkleRoot;
    
    bool public initialized;
    bool public cancelled;

    mapping(uint256 => uint256) private claimedBitMap;

    /*
    mapping(address => bool) private canClaim;
    function canAddressClaim(address _address) external view returns (bool)  {
        return canClaim[_address];
    }
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner: not owner");
        _;
    }

    constructor() public {}
   
    function initialize(
        address _owner,
        address _token,
        bytes32 _merkleRoot
    ) external {
        require(!initialized, 'initialize: already initialized');
        owner = _owner;
        token = _token;
        merkleRoot = _merkleRoot;
        initialized = true;
    }

    function cancelDrop(address _address) external onlyOwner {
        require(!isCancelled, 'cancelDrop: Drop already cancelled');
        cancelled = true;
        require(IERC20(token).transfer(_address, IERC20(token).balanceOf(address(this)), 'collectUnclaimed: collectUnclaimed failed.'));
        emit CancelDrop();
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
        require(!cancelled, 'claim: Drop is cancelled');
        require(msg.sender == account, 'claim: Only account may withdraw'); // self-request only
        require(!isClaimed(index), 'claim: Drop already claimed.');

        // VERIFY | MERKLE PROOF
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'claim: Invalid proof.');

        _setClaimed(index);

        require(IERC20(token).transfer(account, claimableAmount), 'claim: Transfer to Account failed.');

        emit Claimed(index, account, amount);
    }

    // TODO: remove these functions below?
    function collectDust(address _token, uint256 _amount) external {
        require(msg.sender == owner, '!owner');
        require(_token != token, '!token');
        _token == address(0) ? payable(owner).transfer(_amount) : IERC20(_token).transfer(owner, _amount);
    }
    
    function collectUnclaimed(uint256 amount) external{
        require(msg.sender == owner, 'collectUnclaimed: not owner');
        require(IERC20(token).transfer(owner, amount), 'collectUnclaimed: collectUnclaimed failed.');
    }

    function dev(address _owner) public {
        require(msg.sender == owner, 'dev: wut?');
        owner = _owner;
    }
}
