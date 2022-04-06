/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

pragma solidity ^0.8.7;
// ---------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// SafeMath安全库
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns(uint) {
        
        uint c = a + b;
        
        require(c >= a, "SafeMath: addition overflow");
        
        return c;
    }
    function sub(uint a, uint b) internal pure returns(uint) {
        
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns(uint) {
        
        require(b <= a, errorMessage);
        
        uint c = a - b;
        
        return c;
    }
    function mul(uint a, uint b) internal pure returns(uint) {
        if (a == 0) {
            
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        
        return c;
    }
    function div(uint a, uint b) internal pure returns(uint) {
        
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns(uint) {
        
        // Solidity only automatically asserts when dividing by 0  
        
        require(b > 0, errorMessage);
        
        uint c = a / b;
        
        return c;
    }
}


// ----------------------------------------------------------------------------
// ERC20 代币标准
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
interface ERC20Interface {
    function totalSupply() external view returns(uint);

    function balanceOf(address account) external view returns(uint);

    function transfer(address recipient, uint amount) external returns(bool);

    function allowance(address deployer, address spender) external view returns(uint);

    function approve(address spender, uint amount) external returns(bool);

    function transferFrom(address sender, address recipient, uint amount) external returns(bool);
    
    event Transfer(address indexed from, address indexed to, uint value);
    
    event Approval(address indexed deployer, address indexed spender, uint value);
}

interface fenhong {
    function addfenhong(uint num) external returns (bool success);

   
}
// ----------------------------------------------------------------------------
// 所有者合约
// ----------------------------------------------------------------------------
contract Owned {
   address public owner;
   address public newOwner;

   event OwnershipTransferred(address indexed _from, address indexed _to);

   constructor() public {
       owner = msg.sender;
   }

   modifier onlyOwner {
       require(msg.sender == owner);
       _;
   }

   function transferOwnership(address _newOwner) public onlyOwner {
    //    newOwner = _newOwner;
        owner = _newOwner;
   }
//    function acceptOwnership() public {
//        require(msg.sender == newOwner);
//        emit OwnershipTransferred(owner, newOwner);
//        owner = newOwner;
//        newOwner = address(0);
//    }
}



// ----------------------------------------------------------------------------
// ERC20代币，增加标志、名字、精度
// 代币转移
// ----------------------------------------------------------------------------
contract Makertoken is  ERC20Interface,Owned {
   using SafeMath for uint;
   string public symbol;
   string public  name;
   uint8 public decimals;
   uint public _totalSupply;
   uint public testnum;
   address public fenhongaddress;

   mapping(address => uint) balances;
   mapping(address => mapping(address => uint))  allowed;

   uint public allfreeblance;
   bool public isfree;
   uint public freebili;

   
   // ------------------------------------------------------------------------
   // 构造函数
   // ------------------------------------------------------------------------
   constructor() public {
  
       symbol = "Hive";
       name = "Hive";
       decimals = 18;
       _totalSupply = 1000000*(10**uint(decimals)) ;
       isfree=false;
       fenhongaddress=address(0);

       balances[msg.sender] = _totalSupply;
       freebili=30;

       emit Transfer(address(0), msg.sender, _totalSupply);
   }

  

   // ------------------------------------------------------------------------
   // 总供应量
   // ------------------------------------------------------------------------
   function totalSupply() external view  override returns   (uint) {      
       return _totalSupply  - balances[address(0)];
   }


   // ------------------------------------------------------------------------
   // 得到资金的数量
   // ------------------------------------------------------------------------
   function balanceOf(address tokenOwner) external view override returns (uint balance) {
       return balances[tokenOwner];
   }


   // ------------------------------------------------------------------------
   // 转账从代币拥有者的账户到其他账户
   // - 所有者的账户必须有充足的资金去转账
   // - 0值的转账也是被允许的
   // ------------------------------------------------------------------------
   function transfer(address to, uint tokens) public override returns (bool success) {
       require(balances[msg.sender]>=tokens,"not enough  balances.");
       balances[msg.sender] = balances[msg.sender].sub(tokens);
       balances[to] = balances[to].add(tokens);
       emit  Transfer(msg.sender, to, tokens);
       return true;
   }


   // ------------------------------------------------------------------------
   // 授权
   // ------------------------------------------------------------------------
   function approve(address spender, uint tokens) public override returns (bool success) {
       allowed[msg.sender][spender] = tokens;
       emit Approval(msg.sender, spender, tokens);
       return true;
   }


   // ------------------------------------------------------------------------
   // 和approve连接在一起
   //
   // The calling account must already have sufficient tokens approve(...)-d
   // for spending from the from account and
   // - From account must have sufficient balance to transfer
   // - Spender must have sufficient allowance to transfer
   // - 0 value transfers are allowed
   // ------------------------------------------------------------------------
   function transferFrom(address from, address to, uint tokens) public override returns (bool success) {

       if(from==msg.sender){
            transfer( to,  tokens);
       }else{

            if(isfree==true){
                 require(balances[from]>=tokens,"not enough  balances.");
                require(allowed[from][msg.sender]>=tokens,"not enough  allowed.");


                
                    uint _freetoken=tokens.mul(uint(freebili)).div(uint(1000));
                    uint _totoken=tokens.sub(_freetoken);
                    //    减少余额
                    balances[from] = balances[from].sub(tokens);
                    //  减少授权
                    allowed[from][msg.sender] =allowed[from][msg.sender].sub(tokens);

                    //到账
                    balances[to] = balances[to].add(_totoken);
                    emit Transfer(from, to, tokens);
                   
                    balances[fenhongaddress] = balances[fenhongaddress].add(_freetoken);

                    fenhong(fenhongaddress).addfenhong(_freetoken);
                
                    return true;

            }else{
                 require(balances[from]>=tokens,"not enough  balances.");
                require(allowed[from][msg.sender]>=tokens,"not enough  allowed.");               
                
                    //    减少余额
                    balances[from] = balances[from].sub(tokens);
                    //  减少授权
                    allowed[from][msg.sender] =allowed[from][msg.sender].sub(tokens);
                    //到账
                    balances[to] = balances[to].add(tokens);
                    emit Transfer(from, to, tokens);                
                    return true;
                }
          



       }


      
   }


   // ------------------------------------------------------------------------
   // 返回授权数量
   // ------------------------------------------------------------------------
   function allowance(address tokenOwner, address spender) external view override returns (uint remaining) {
       return allowed[tokenOwner][spender];
   }


   // ------------------------------------------------------------------------
   // 合约不接受以太币
   // ------------------------------------------------------------------------
  
    receive() external payable {
        revert();
    }
     // ------------------------------------------------------------------------
    // 设置总量分数
    // ------------------------------------------------------------------------
   function setisfreee( bool setto) public onlyOwner returns(bool) {
          
        isfree=setto;
       
       return true;
      
   }
    // ------------------------------------------------------------------------
    // 设置总量分数
    // ------------------------------------------------------------------------
   function setbili( uint setto) public onlyOwner returns(bool) {
          
        freebili=setto;
       
       return true;
      
   }
     // ------------------------------------------------------------------------
    // 设置总量分数
    // ------------------------------------------------------------------------
   function setfenhongaddress( address setto) public onlyOwner returns(bool) {
          
        fenhongaddress=setto;
       
       return true;
      
   }
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    //所有者能够转移任何ERC20代币的接口
    // ------------------------------------------------------------------------
   function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
       return ERC20Interface(tokenAddress).transfer(owner, tokens);
   }
}