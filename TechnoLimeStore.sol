//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract TechnoLimeStore {
     struct Product {
        bool isAdded;
        string name;
        uint quantity;
        mapping(address => bool) clients;
    }

    modifier onlyOwner() {
        require(msg.sender == manager);
        _;
    }

    address public manager;
    uint private endBlock;
    uint private duration = 100;
    mapping(string => Product) private products;
    string[] private productId;
    mapping(address => bool) inserted;
    address[] private clients;

    constructor() {
        manager = msg.sender;
        endBlock = block.number + duration;
    }

    function addProduct(string calldata name, uint quantity) public onlyOwner() {
        Product storage prod = products[name];

        if (!prod.isAdded) {
            prod.isAdded = true;
            prod.name = name;
            prod.quantity = quantity;
            productId.push(name);
        } else {
            prod.quantity = prod.quantity + quantity;
        }
    }

    function buyProduct(uint id) public {
        Product storage product = products[productId[id]];
        require(!product.clients[msg.sender], "Cannot buy the same product twice");
        require(product.quantity > 0, "Product out of stock");

        if (!inserted[msg.sender]) {
            inserted[msg.sender] = true;
            clients.push(msg.sender);
        }

        product.clients[msg.sender] = true;
        product.quantity--;
    }

    function returnProduct(uint id) public {
        Product storage product = products[productId[id]];
        require(block.number < endBlock, "Reached end of time for returning product!");
        require(product.clients[msg.sender], "Cannot return non-existent product");

        product.clients[msg.sender] = false;
        product.quantity++;
    }

    function getProductById(uint id) public view returns(string memory, uint) {
        require(id < productId.length, "Unavailable product ID");
        return (products[productId[id]].name, products[productId[id]].quantity);
    }

    function getClients() public view returns(address[] memory) {
        return clients;
    }
}