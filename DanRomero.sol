//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.12;


// ██████╗░░█████╗░███╗░░██╗  ██████╗░░█████╗░███╗░░░███╗███████╗██████╗░░█████╗░
// ██╔══██╗██╔══██╗████╗░██║  ██╔══██╗██╔══██╗████╗░████║██╔════╝██╔══██╗██╔══██╗
// ██║░░██║███████║██╔██╗██║  ██████╔╝██║░░██║██╔████╔██║█████╗░░██████╔╝██║░░██║
// ██║░░██║██╔══██║██║╚████║  ██╔══██╗██║░░██║██║╚██╔╝██║██╔══╝░░██╔══██╗██║░░██║
// ██████╔╝██║░░██║██║░╚███║  ██║░░██║╚█████╔╝██║░╚═╝░██║███████╗██║░░██║╚█████╔╝
// ╚═════╝░╚═╝░░╚═╝╚═╝░░╚══╝  ╚═╝░░╚═╝░╚════╝░╚═╝░░░░░╚═╝╚══════╝╚═╝░░╚═╝░╚════╝░


contract DanRomero {

    string private whoAmI;
    string private linkOne;
    string private linkTwo;
    uint private subdomainLength = 10 ** 6;

    constructor(string memory _whoAmI, string memory _linkOne, string memory _linkTwo) {
        whoAmI = _whoAmI;
        linkOne = _linkOne;
        linkTwo = _linkTwo;
    }



    // "Get to know me" function ... 
    // The function will return this website - http://timbabnik.com/dwr

    function Who_are_you() view public returns(string memory) {
        return whoAmI;
    }
    


    // "I will give you a chance" function
    // If you select "True" it will return this website - http://timbabnik.com/130712
    // If you select "False" it will return my new short blog - http://timbabnik.com/903563

    function  I_Will_Give_You_A_Chance(bool _chance) view public returns(string memory) {
        uint yes = uint(keccak256(abi.encodePacked("Dan Romero")));
        uint domain = yes % subdomainLength;

        uint no = uint(keccak256(abi.encodePacked(":(")));
        uint domainTwo = no % subdomainLength;

        if (_chance) {
            return string(abi.encodePacked(linkOne, Strings.toString(domain)));
        } else {
            return string(abi.encodePacked(linkTwo, Strings.toString(domainTwo)));
        }
    }


}