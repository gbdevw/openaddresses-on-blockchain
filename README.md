# Belgian addresses on blockchain
A smart contract which shows how blockchain can be leveraged to bring open data about addresses one step further.

### Data source

Open data about belgian addresses can be found on the [SPF BOSA site](https://opendata.bosa.be/index.fr.html).

### Principles

- The application provides a decentralized registry for belgian addresses.
- The maintainer of the registry can add, remove and update addresses.
- The consumers can use the registry as a trustable data source for belgian addresses
- When addresses are added, removed or updated, actionable events are be emitted to allow consumers to react.
- Addresses removed from the registry remain accessible in the history of data.
- Consumers are be able to query the full data history and registry in a easy way.

### Personnas

Two personnas are defined for the application :

- The maintainer, who deploys the smart contract and manages the addresses.
- Consumers, who use the functionalities provided by the smart contract to use the blockchain as a database and as an event publishing system for events related to address management (insertions, deletions & updates)

![](./documentation/images/poc_blockchain_addresses-Personnas.jpg)

### Use cases & requirements

- [Add an address](./documentation/add_address.md)
- [Remove an address](./documentation/rm_address.md)
- [Update an address](./documentation/upd_address.md)
- [Search addresses](./documentation/search_address.md)

### Data model

Address data model :

```
struct StreetAddress { 
    bytes32 addressId;
    string streetName;
    string postcode;
    string houseNumber;
    string boxNumber;
    string latitude;
    string longitude;
}
```

### Data structures

Three data structures are managed by the contract :
- A map which uses the address ID as key and the address as value
- A map which uses the postcode as key and a list of all ids of addresses related to that postcode as value
- A list of all postcodes which have addresses in the registry

### Lab1: Explore and play with smart contract using Remix

#### Lab requirements

- Internet connection
- Web browser

#### Instructions

See [Lab1.md](Lab1.md)

### Lab2: Openaddresses on blockchain

#### Lab requirements

- Internet connection
- Web browser
- Docker CLI

The lab has been tested with a virtual machine with 2vCPU, 8GB of RAM and 30GB of disk space

#### Instructions

See [Lab2.md](Lab2.md)