// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducationalVideoRewards {
    address public owner;
    uint256 public rewardPerVideo;
    mapping(address => uint256) public rewards;
    mapping(string => bool) public videoHashes;

    event VideoSubmitted(address indexed creator, string videoHash);
    event RewardClaimed(address indexed creator, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor(uint256 _rewardPerVideo) {
        require(_rewardPerVideo > 0, "Reward per video must be greater than zero.");
        owner = msg.sender;
        rewardPerVideo = _rewardPerVideo;
    }

    function setRewardPerVideo(uint256 _rewardPerVideo) external onlyOwner {
        require(_rewardPerVideo > 0, "Reward per video must be greater than zero.");
        rewardPerVideo = _rewardPerVideo;
    }

    function submitVideo(string memory videoHash) external {
        require(!videoHashes[videoHash], "This video has already been submitted.");
        require(bytes(videoHash).length > 0, "Video hash cannot be empty.");

        videoHashes[videoHash] = true;
        rewards[msg.sender] += rewardPerVideo;

        emit VideoSubmitted(msg.sender, videoHash);
    }

    function claimRewards() external {
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No rewards available to claim.");
        require(address(this).balance >= reward, "Insufficient contract balance to pay rewards.");

        rewards[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: reward}("");
        require(success, "Reward transfer failed.");

        emit RewardClaimed(msg.sender, reward);
    }

    function fundContract() external payable onlyOwner {
        require(msg.value > 0, "Funding amount must be greater than zero.");
    }

    fallback() external payable {}
    receive() external payable {}
}
