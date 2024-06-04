// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

struct Request {
    uint id;
    address author;
    string title;
    string description;
    string contact;
    uint timestamp;
    uint goal;
    uint balance;
    bool open;
}

contract FloodHelp{

    uint public lastId = 0;
    mapping(uint => Request) public requests;//melhor que array

//abrir requisição
    function openRequest(string memory title, string memory description, string memory contact, uint goal) public {
        lastId++;
        requests[lastId] = Request({
            id: lastId,
            title: title,
            description: description,
            contact: contact,
            goal: goal,
            balance: 0,
            timestamp: block.timestamp, 
            author: msg.sender,//retorna o endereço da carteira cripto
            open: true
        });
    }

//fechar requisição
    function closedRequest(uint id) public{
        address author = requests[id].author;
        uint balance = requests[id].balance;
        uint goal = requests[id].goal;
        require(requests[id].open && (msg.sender == author || balance >= goal), unicode"Você não poe fechare este pedido");

        requests[id].open = false;
        if(balance > 0){
            requests[id].balance = 0;
           payable(author).transfer(balance);
        }
    }

//para doar
    function donate(uint id)public payable{
        requests[id].balance += msg.value;
        //se atingiu meta fecho escolha da regra do negocio!
        if(requests[id].balance >= requests[id].goal)
        closedRequest(id);
    }

 //lista de abertas
    function getOpenRequest(uint startId, uint quantity)public view returns(Request[]memory) {
        Request[] memory result = new Request[](quantity);
        uint id = startId;
        uint count = 0;
        do{
            if(requests[id].open){
                result[count] = requests[id];
                count++;
            }
            id++;
         }while(count < quantity && id <= lastId);
         return result;
                
    }


}   