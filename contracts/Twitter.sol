// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Twitter{

    //STRUCT
    struct Tweet {
        uint id;
        address author;
        string content;
        uint timestamp;
        uint likes;
    }

    // VARIABLES
    uint16 public MAX_TWEET_LIMIT = 200;
    address public owner;

    // MAPPINGS
    mapping(address => Tweet[]) public tweets;
    mapping(address => address[]) public followers;
    mapping(address => address[]) public following;

    // CONSTRUCTOR
    constructor(){
        owner = msg.sender;
    }

    // MODIFIERS
    modifier onlyOwner(){
        require(msg.sender == owner, "YOU'RE NOT THE OWNER");
        _;
    }

    // EVENTS
    event TweetCreated(uint id, address indexed author, string content, uint timestamp, uint likes);
    event TweetLengthChanged(address indexed owner, uint16 tweetlength);
    event TweetLiked(address indexed author, uint likes);
    event TweetUnLiked(address indexed author, uint likes);
    event UserFollowed(address indexed follower, address indexed followed);
    event UserUnfollowed(address indexed follower, address indexed unfollowed);

    // FUNCTIONS

    function createTweet(string memory _tweet) public {
        require(bytes(_tweet).length > 0, "NO CONTENT, PLEASE WRITE SOMETHING");
        require(tweets[msg.sender].length < MAX_TWEET_LIMIT, "THE MAXIMUM TWEETS REACHED");

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);
        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp, newTweet.likes);
    }

    function numberOfTweets() public view returns (uint) {
        return tweets[msg.sender].length;    
    }

    function viewTweet(address _owner, uint _i) public view returns(Tweet memory){
        return tweets[_owner][_i];
    }

    function getAllTweets(address _owner) public view returns(Tweet[] memory){
        return tweets[_owner];
    }

    function changeTweetLength(uint16 _newTweetLength) public onlyOwner {
        MAX_TWEET_LIMIT = _newTweetLength;
        emit TweetLengthChanged(msg.sender, _newTweetLength);
    }

    function likeTweet(address author, uint id) public {
        require(tweets[author][id].id == id, "TWEET DOESN'T EXIST");
        tweets[author][id].likes++;

        emit TweetLiked(author, tweets[author][id].likes);
    }

    function unLlikeTweet(address author, uint id) public {
        require(tweets[author][id].id == id, "TWEET DOESN'T EXIST");
        require(tweets[author][id].likes > 0, "THERE ARE NO LIKES");
        tweets[author][id].likes--;

        emit TweetUnLiked(author, tweets[author][id].likes);
    }

    // FOLLOW FEATURE
    function followUser(address _user) public {
        require(_user != msg.sender, "YOU CANNOT FOLLOW YOURSELF");

        // Ensure the user isn't already following
        for (uint i = 0; i < following[msg.sender].length; i++) {
            require(following[msg.sender][i] != _user, "ALREADY FOLLOWING");
        }

        following[msg.sender].push(_user);
        followers[_user].push(msg.sender);

        emit UserFollowed(msg.sender, _user);
    }

    function unfollowUser(address _user) public {
        require(_user != msg.sender, "YOU CANNOT UNFOLLOW YOURSELF");

        // Remove from following list
        for (uint i = 0; i < following[msg.sender].length; i++) {
            if (following[msg.sender][i] == _user) {
                following[msg.sender][i] = following[msg.sender][following[msg.sender].length - 1];
                following[msg.sender].pop();
                break;
            }
        }

        // Remove from followers list
        for (uint i = 0; i < followers[_user].length; i++) {
            if (followers[_user][i] == msg.sender) {
                followers[_user][i] = followers[_user][followers[_user].length - 1];
                followers[_user].pop();
                break;
            }
        }

        emit UserUnfollowed(msg.sender, _user);
    }

    function getFollowers(address _user) public view returns (address[] memory) {
        return followers[_user];
    }

    function getFollowing(address _user) public view returns (address[] memory) {
        return following[_user];
    }
}
