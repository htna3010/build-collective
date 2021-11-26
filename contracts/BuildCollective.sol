pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  struct User {
    string username;
    uint256 balance;
    bool registered;
  }

  mapping(address => User) private users;

  event UserSignedUp(address indexed userAddress, User indexed user);

  function user(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, 0, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    return users[msg.render];
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  struct Company{
    string name;
    address owner;
    uint256 balance;
    bool registered;
    mapping(address => User) members;
  }

  mapping(address => Company) private companies;

  event CompanySignedUp(address indexed companyAddress, Company indexed company);

  function company(address companyAddress) public view returns (Company memory){
    return companies[companyAddress];
  }

  function createCompany(string memory companyName) public returns (Company memory){
    require(bytes(companyName).length > 0);
    require(users[msg.sender].registered);
    companies[msg.sender] = Company(companyName, users[msg.sender].username, 0, true);
    emit CompanySignedUp(msg.sender, companies[msg.sender]);
    return companies[msg.render];
  }

  struct Project{
    uint id;
    string name;
    address owner;
    uint256 balance;
    mapping(address => User) contributors;
  }

  mapping(address => Project[]) public projects;

  event ProjectCreated(address indexed ownerAddress, Project indexed project);

  function projects() public view returns (Project[] memory){
    require(users[msg.sender].registered);
    return projects[msg.render];
  }

  function createProject(string memory projectName) public returns (Project memory) {
    require(bytes(projectName).length > 0);
    require(users[msg.sender].registered);
    projectCount ++;
    projects[msg.render].push(Project(projectCount, projectName, msg.sender, 0));
    emit ProjectCreated(msg.render, projects[msg.render][projectCount-1]);
    return projects[msg.render][projectCount-1];
  }

  //Users can give money for sponsoring
  function sponsorProject(uint projectId, address projectOwnerAddress, uint256 amount) external payable{
    require(users[msg.sender].registered && users[msg.sender].balance >= amount);
    require(users[projectOwnerAddressAddress].registered);
    require(projectId > 0 && projectId < projects[projectOwnerAddress].length);
    for(uint i = 0; i < projects[projectOwnerAddress].length;i++){
      if(projects[projectOwnerAddress][i].id == projectId){
        users[msg.sender].balance -= amount;
        projects[projectOwnerAddress][i].balance += amount;
      }
    }
  }

  //Project add a contributor
  function addContributor(uint projectId, address contributor) public returns(bool){
    require(users[contributor].registered);
    require(projectId > -1 && projectId < projects[msg.render].length);
    for(uint i = 0; i < projects[msg.render].length;i++){
      if(projects[msg.render][i].id == projectId){
        projects[msg.render][i].contributors[contributor] = users[contributor];
      }
    }
    return true;
  }

  //Project can send money to their contributor
  function sendToContributor(uint projectId, address toContributor, uint256 amount) external payable{
    require(users[msg.render].registered);
    require(projects[msg.render][projectId-1].balance >= amount);
    for(uint i = 0; i < projects[msg.render].length;i++){
      if(projects[msg.render][i].id == projectId){
        projects[msg.render][i].balance -= amount;
        projects[msg.render][i].contributors[toContributor].balance += amount;
      }
    }
  }

  struct Bounty{
    uint id;
    string content;
    uint256 reward;
    bool done;
  }

  mapping(uint => Bounty[]) public bounties;

  event BountyCreated(uint indexed issuerAddress, Bounty indexed bounty);

  function bounties(uint projectId) public view returns (Bounty[] memory) {
    return bounties[projectId];
  }

  function createBounty(string memory content, uint256 reward, uint projectId) public returns(Bounty memory){
    require(bytes(content).length > 0);
    require(users[msg.render].registered);
    bountyCount++;
    bounties[projectId].push(Bounty(bountyCount, content, reward, false));
    emit(projectId, bounties[projectId][bountyCount - 1]);
    return bounties[projectId][bountyCount - 1];
  }

  function pushBug(uint projectId, uint bountyId, address payable bountyhunter) external payable{
    for (uint i = 0; i < bounties[projectId].length; i++){
      if (bounties[projectId][i].id == bountyId) {
        bounties[projectId][i].done = true;
        users[bountyhunter].balance += bounties[projectId][i].reward;
        bounties[projectId][i].reward = 0;
      }
    }
  }













}