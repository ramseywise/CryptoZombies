pragma solidity >=0.5.0 <0.6.0;

import "./zombiefactory.sol";

/*
In lesson 2, we're going to make our app more game-like: We're going to make it multi-player, and we'll 
also be adding a more fun way to create zombies instead of just generating them randomly.

How will we create new zombies? By having our zombies "feed" on other lifeforms!

When a zombie feeds, it infects the host with a virus. The virus then turns the host into a new zombie 
that joins your army. The new zombie's DNA will be calculated from the previous zombie's DNA and the 
host's DNA.
*/

contract KittyInterface {
    // Create interface to interact with other contracts to handle multiple return values
        function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {
  // Initialize contract inherited from Zombie Factory using address from Kitty interface
  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  KittyInterface kittyContract = KittyInterface(ckAddress);

  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
    /// Verify zombie owner 
    require(msg.sender == zombieToOwner[_zombieId]);
    /// Add zombie id to storage
    Zombie storage myZombie = zombies[_zombieId];
    /// Take only last 16 digits of dna.
    _targetDna = _targetDna % dnaModulus;
    /// Declare new dna as average.
    uint newDna = (myZombie.dna + _targetDna) / 2;
    /// If dna is a cat, replace last two digits with 99 (cats have 9 lives)
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    /// Returns values for new zombies
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}