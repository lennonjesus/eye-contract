pragma solidity ^0.5.17;

/**
 * Biblioteca para auxiliar com o tratamento de strings
 * 
 * @dev Odeio o solidity =D
 */ 
library StringUtils {
    /**
     * Retorna verdadeiro ou falso para comparacao de duas strings

     * @param _strA primeira string para comparacao
     * @param _strB segunda string para comparacao
     * @dev Copiei este codigo de um github qualquer, de tanta raiva que fiquei tentando
     * nao precisar disso. :-(
     * @return true se as strings forem consideradas iguais e false se forem diferentes
     */
    function equal(string memory _strA, string memory _strB) public pure returns (bool) {
        return compare(_strA, _strB) == 0;
    }
    
    function compare(string memory _strA, string memory _strB) public pure returns (int) {
        bytes memory strA = bytes(_strA);
        bytes memory strB = bytes(_strB);
        uint minLength = strA.length;
        
        if (strB.length < minLength) minLength = strB.length;
        
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (strA[i] < strB[i])
                return -1;
            else if (strA[i] > strB[i])
                return 1;
        if (strA.length < strB.length)
            return -1;
        else if (strA.length > strB.length)
            return 1;
        else
            return 0;
    }
}
