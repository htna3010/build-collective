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
    return users[msg.sender];
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
  }

  mapping(address => Company) private companies;

  event CompanySignedUp(address indexed companyAddress, Company indexed company);

  function company(address companyAddress) public view returns (Company memory){
    return companies[companyAddress];
  }

  function createCompany(string memory companyName, uint256 balance) public returns (Company memory){
    require(bytes(companyName).length > 0);
    require(users[msg.sender].registered);
    companies[msg.sender] = Company(companyName, msg.sender, balance, true);
    emit CompanySignedUp(msg.sender, companies[msg.sender]);
    return companies[msg.sender];
  }

  struct Project{
    uint id;
    string name;
    address owner;
    uint256 balance;
  }

  uint internal projectCount;

  mapping(address => Project[]) public projects;
  mapping(uint => mapping(address => User)) public contributors;

  event ProjectCreated(address indexed ownerAddress, Project indexed project);

  function project(address ownerAddress) public view returns (Project[] memory){
    return projects[ownerAddress];
  }

  function createProject(string memory projectName, uint balance) public returns (Project memory) {
    require(bytes(projectName).length > 0);
    require(users[msg.sender].registered);
    projectCount ++;
    projects[msg.sender].push(Project(projectCount, projectName, msg.sender, balance));
    emit ProjectCreated(msg.sender, projects[msg.sender][projectCount-1]);
    return projects[msg.sender][projectCount-1];
  }

  //Users can give money for sponsoring
  function sponsorProject(uint projectId, address projectOwnerAddress, uint256 amount) external payable{
    require(users[msg.sender].registered && users[msg.sender].balance >= amount);
    require(users[projectOwnerAddress].registered);
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
    require(projectId >= 0 && projectId < projects[msg.sender].length);
    for(uint i = 0; i < projects[msg.sender].length;i++){
      if(projects[msg.sender][i].id == projectId){
        contributors[i][msg.sender] = users[contributor];
      }
    }
    return true;
  }

  //Project can send money to their contributor
  function sendToContributor(uint projectId, address toContributor, uint256 amount) external payable{
    require(users[msg.sender].registered);
    require(projects[msg.sender][projectId-1].balance >= amount);
    for(uint i = 0; i < projects[msg.sender].length;i++){
      if(projects[msg.sender][i].id == projectId){
        projects[msg.sender][i].balance -= amount;
        contributors[i][msg.sender].balance += amount;
      }
    }
  }

  struct Bounty{
    uint id;
    string content;
    uint256 reward;
    bool done;
  }

  uint bountyCount;

  mapping(uint => Bounty[]) public bounties;

  event BountyCreated(uint indexed bountyId, Bounty indexed bounty);

  function bounty(uint projectId) public view returns (Bounty[] memory) {
    return bounties[projectId];
  }

  function createBounty(string memory content, uint256 reward, uint projectId) public returns(Bounty memory){
    require(bytes(content).length > 0);
    require(users[msg.sender].registered);
    bountyCount++;
    bounties[projectId].push(Bounty(bountyCount, content, reward, false));
    emit BountyCreated(projectId, bounties[projectId][bountyCount - 1]);
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