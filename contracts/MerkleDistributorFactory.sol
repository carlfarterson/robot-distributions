pragma solidity ^0.8.0;

import "./MerkleDistributor.sol";

contract MerkleDistributorFactory is Ownable {
  
  event CreateDrop(address drop);
  event CancelDrop(address drop);

  address public owner;
  address public template;

  address[] public drops;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  constructor(address _template) {
    owner = msg.sender;
    template = _template;
  }

  function createDrop(address _token, bytes32 _merkleRoot) external onlyOwner returns (MerkleDistributor) {
    MerkleDistributor merkleDistributor = MerkleDistributor(createClone(template));
    merkleDistributor.initialize(address(this), _token, _merkleRoot);

    // append to drops
    drops.push(merkleDistributor);

    emit CreateDrop(merkleDistributor);
  }

  function cancelDrop(address _address) external onlyOwner returns (bool) {
    for (i=0; drops.length; i++) {
      if (drops[i] == _address) {
        MerkleDistributor merkleDistributor = MerkleDistributor(_address);
        merkleDistributor.cancelDrop();
        delete drops[i];
        emit CancelDrop(_address);
        return true;
      }
    }
    return false;
  }

  function createClone(address target) internal returns (address result) {
    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function setTemplate(address _template) external onlyOwner {
    template = _template;
  }

  function getNumDrops() view external returns (uint256) {
    return drops.length;
  }
}