pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import { StringUtils } from "./StringUtils.sol";

/**
 * Implementacao de contrato inteligente para registro de propriedade
 * intelectual de arquivos e venda de licencas de utilizacao.
 *
 * @author Cirilo Xavier
 * @author Jorge Melo
 * @author Lennon Jesus
 * @author Kedson Kede
 * @author Paula Nazareth
 */ 
contract EyeContract {

    string[] internal registeredFiles;
    
    string[] internal licenses;
    
    mapping(string => OriginalFile) internal filesMap;
    
    mapping(address => License) internal licensesMap;

    struct OriginalFile {
        uint index; 
        string md5; // hash que garante que o arquivo e unico
        string base64; // arquivo em formato base64
        address payable author; // autor do arquivo
        uint licensePrice;
    }
    
    struct License {
        uint index; 
        OriginalFile file; // arquivo
        address owner; // dono da licenca
    }

    /**
     * Representa o registro de propriedade de um arquivo
     * 
     * @param author o proprietario original do arquivo
     * @param file o arquivo registrado
     */ 
    event RegisteredOriginalFileEvent (address author, OriginalFile file);

    /**
     * Representa a emissao de uma nova licenca
     * 
     * @param owner o adquirente da licenca
     * @param license a chave da licenca
     */ 
    event RegisteredLicenseEvent (address owner, address license);

    /**
     * Registra um novo arquivo como propriedade intelectual e o disponibiliza para licenciamento 
     * por outros usuarios
     * 
     * @param _md5 o md5 do arquivo a ser registrado como propriedade intelectual
     * @param _base64 o conteudo do arquivo em formato Base64
     * @param _licensePrice o valor da licenca em ETH
     */
    function registrarPropriedade(string memory _md5, string memory _base64, uint _licensePrice) public fileMustNotExists(_md5) {
        OriginalFile storage file = filesMap[_md5];
        
        file.md5 = _md5;
        file.base64 = _base64;
        file.author = msg.sender;
        file.licensePrice = _licensePrice * 1 ether;
        
        registeredFiles.push(_md5);
        uint registeredFilesIndex = registeredFiles.length - 1;
        file.index = registeredFilesIndex + 1;
        
        emit RegisteredOriginalFileEvent(msg.sender, file);
    }
    
    /**
     * Registra uma licenca de uso de um arquivo devidamente registrado para um usuario
     *
     * @param _md5 o md5 do arquivo a ser licenciado
     */
    function comprarLicenca(string memory _md5) public fileMustExists(_md5) payable {
        
        OriginalFile memory file = getOriginalFileByKey(_md5);
        
        require(msg.value >= file.licensePrice, "Saldo insuficiente.");
        
        uint change = msg.value - file.licensePrice;
        
        if (change > 0) {
            msg.sender.transfer(change);
        }
        
        file.author.transfer(file.licensePrice);
        
        address licenseKey = generateKey();
        
        License storage license = licensesMap[licenseKey];
        
        license.file = file;
        license.owner = msg.sender;
        
        licenses.push(_md5);
        uint licensesIndex = licenses.length - 1;
        license.index = licensesIndex + 1;

        emit RegisteredLicenseEvent(msg.sender, licenseKey);
    }
    
    /**
     * Verifica se o usuario tem direito em um arquivo devidamente registrado
     * 
     * @param _md5 o md5 do arquivo a verificado
     * @return true se o usuario for o autor do arquivo
     */
    function verificarDireito(string memory _md5) public view fileMustExists(_md5) returns (bool) {
        OriginalFile memory file = getOriginalFileByKey(_md5);
        
        return file.author == msg.sender;
    }
    
    /**
     * Verifica se uma determinada licenca eh valida para o usuario em um arquivo devidamente registrado
     * 
     * @param _md5 o md5 do arquivo a verificado
     * @param _license a chave da licenca a ser validada para o arquivo informado
     * @return true se 
     *   - a licenca for valida para o arquivo informado
     *   - o usuario for o dono da licenca
     */
    function verificarDireito(string memory _md5, address _license) public view fileMustExists(_md5) licenseMustExists(_license) returns (bool) {
        License memory license = getLicense(_license);
        require(license.owner == msg.sender, "Usuario nao eh o dono da licenca");
        
        OriginalFile memory file = getOriginalFileByKey(_md5);
        require(StringUtils.equal(license.file.md5, file.md5), "Licenca eh de outro arquivo");
        
        return true;
    }
    
    /**
     * Retorna uma chave de licenca unica gerada aleatoriamente
     *
     * @return chave de licenca
     */
    function generateKey() private view returns(address) {
        uint seed = now * uint(msg.sender);
        
        address key = address(uint160(uint(keccak256(abi.encodePacked(seed, blockhash(block.number))))));
        
        return key;
    }
    
    /**
     * Verifica se uma determinado arquivo esta registrado
     * 
     * @param _key o md5 do arquivo a ser localizado
     * @return true se o arquivo existir e false caso nao exista
     */
    function fileExists(string memory _key) private view returns (bool) {
        return filesMap[_key].index > 0;
    }
    
    /**
     * Retorna um arquivo registrado
     * 
     * @param _key o md5 do arquivo a ser localizado
     * @return o arquivo registrado, se existir
     */
    function getOriginalFileByKey(string memory _key) private view returns (OriginalFile memory) {
        return filesMap[_key];
    }
    
    /**
     * Verifica se uma determinada licenca esta registrada
     * 
     * @param _license a chave da licenca
     * @return true se a licenca existir e false caso nao exista
     */
    function licenseExists(address _license) private view returns (bool) {
        return licensesMap[_license].index > 0;
    }
    
    /**
     * Retorna uma licenca registrada
     * 
     * @param _license licenca a ser localizada
     * @return a licenca registrada, se existir
     */ 
    function getLicense(address _license) private view returns (License memory) {
        return licensesMap[_license];
    }
    
    /**
     * O arquivo informado deve existir
     */
    modifier fileMustExists(string memory _md5) {
        require(fileExists(_md5), "O arquivo nao existe");
        _;
    }
    
    /**
     * O arquivo informado nao deve existir
     */
    modifier fileMustNotExists(string memory _md5) {
        require(fileExists(_md5) == false, "Arquivo ja registrado!");
        _;
    }
    
    /**
     * A licenca informada deve existir
     */
    modifier licenseMustExists(address _license) {
        require(licenseExists(_license), "A licensa informada nao existe");    
        _;
    }
    
}
