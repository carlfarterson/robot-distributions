pragma solidity ^0.8.0;

contract RobotDistributor is IMerkleDistributor {

    event CancelDrop();
    event NewDrop();

    address public owner;
    address public immutable override token;
    bytes32 public override merkleRoot;
    
    bool public cancelled;

    mapping(uint256 => uint256) private claimedBitMap;
    uint256[] private claimedBitIndices;

    modifier onlyOwner() {
        require(msg.sender == owner, "onlyOwner: not owner");
        _;
    }

    constructor(
        address _token,
        bytes32 _merkleRoot
    ) {
        owner = msg.sender;
        token = _token;
        merkleRoot = _merkleRoot;
    }

    function newDrop(bytes32 _merkleRoot) external onlyOwner {
        for (uint i = claimedBitIndices.length; i > 0; i--) {
            uint256 index = claimedBitIndices[i];
            delete claimedBitIndices[i];
            claimedBitIndices[index] = 0;
        }
        merkleRoot = _merkleRoot;
        cancelled = false;
        emit NewDrop();
    }

    function cancelDrop(address _address) external onlyOwner {
        require(!cancelled, 'cancelDrop: Drop already cancelled');
        cancelled = true;
        require(IERC20(token).transfer(_address, IERC20(token).balanceOf(address(this))), 'cancelDrop: transfer failed.');
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
        claimedBitIndices.push(claimedWordIndex);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
        require(!cancelled, 'claim: Drop is cancelled');
        require(msg.sender == account, 'claim: Only account may withdraw'); // self-request only
        require(!isClaimed(index), 'claim: Drop already claimed.');

        // VERIFY | MERKLE PROOF
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'claim: Invalid proof.');

        _setClaimed(index);

        require(IERC20(token).transfer(account, amount), 'claim: Transfer to Account failed.');

        emit Claimed(index, account, amount);
    }

}