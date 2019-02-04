{
	// Color; // 绘图颜色
	// Origin_x, Origin_y; // 横、纵平移距离 , 缺省不平移
	// Scale_x, Scale_y; // 横、纵比例因子，缺省不缩放
	// rot_angle; // 旋转角度，缺省不旋转
	// myT_storage; // 语义分析器提供的 T 值的存储位置

	// COMMENT, // 用于处理行注释
	// ID, // 用于进一步区分各保留字、常量名、函数名  通过查符号表来区分
	// ORIGIN, SCALE, ROT, IS, TO, // 保留字
	// STEP, DRAW, FOR, FROM, // 保留字
	// T, // 参数
	// COLOR, // 增加的关键字，用于颜色设置语句
	// SEMICO, L_B, R_B, COMMA, // 分隔符号
	// PLUS, MINUS, MUL, DIV, POWER, // 运算符
	// FUNC, // 函数
	// CONST_ID, // 常数
	// NONTOKEN, // 空记号
	// ERRTOKEN // 出错记号
	// tmp_x,tmp_y,
	// angleList = new Array();//放角度的数组
	// var varStack = [];
	// var varObj = {}; 
	// varObj["PI"]=math.PI;
	// varObj["E"]=2.73;
	// varObj["zxr"]=3.18;
	// varObj["fyk"]=6.66;
	// varObj["wqd"]=8.88;
	// var para = [];
}

start
	= res: (COMMENT/ORIGIN/ROT/SCALE/FOR/COLOR/WIDTH){
    	return res;
    }
    
COMMENT //注释的匹配
	= COMMEN .* {
		return {
			"comment":"comment"
		}
	}
WIDTH 
	= "width"i _  "is"i _ num:Expression _ SEMICO _{//NUM
		return {
			"width":num
		}
	}
ORIGIN
	= "origin"i _  "is"i L_B num1:Expression _ COMMA _ num2:Expression R_B _ SEMICO _{//NUM
		return {
			"origin":{"x":num1,"y":num2}
		}
	}
   
COLOR
	= "color"i _ "is"i _ L_B _ num1:Expression _ COMMA _ num2:Expression _ COMMA _ num3:Expression _ R_B _ SEMICO _{//这里只接受rgb的色
    	return {
        	"color":{
            	"r":num1,
                "g":num2,
                "b":num3
            }
        }
    }
ROT 
	= "rot"i _  "is"i _ num:Expression _ SEMICO _{//NUM
		return {
			"rot":{"angle":num}
		}
	}
SCALE
	= "scale"i _  "is"i L_B num1:Expression _  COMMA _ num2:Expression R_B _ SEMICO _{
		return {
			"scale":{"x":num1,"y":num2}
		}
	}
FOR

    = _ "for"i _  para:letter _ "from" _  num1:Expression _ "to" _  num2:Expression _"step"_  num3:Expression _"draw"i_ L_B _ func_x:Expression _ ","_ func_y:Expression R_B _ SEMICO _{
			//type = 1; //设置type为1时修改for对应的列表,要清楚标识,否则很乱
			return {
				"for":{
                    "from": num1,
                    "to": num2,
                    "step":num3,
                    "func_x":func_x,//不一定是函数,也有可能是值而已
                    "func_y":func_y,
					"para":para
                }//得到对应的返回值..
			}
	}
//可增加color width opacity
Expression
	= head:Term tail:( _ ( "+"/ "-") _ Term)*{
        return tail.reduce(function(result, element) {//tail是指匹配了多次的结果，比如1+1+1,必须使用一个正则匹配，因为为了匹配左右操作数。只有一个时不用reduce应该也是ok的
		//array.reduce(function(total, currentValue, currentIndex, arr), initialValue)
        if (element[1] === "+") { 
            return {
                left: result,
                    root: "+",
                    right:element[3]
            } 
        }
        if (element[1] === "-") { 
            return {
            left: result,
            root: "-",
            right:element[3]
            } 
        }
        else{
        	return head;
        }
        }, head);
	}

Term    
    = head:Factor tail:(_("*"/"/")_ Factor)*{
        return tail.reduce(function(result, element) {
        if (element[1] === "*") { 
            return {
                left: result,
                    root: "*",
                    right:element[3]
            } 
            }
        if (element[1] === "/") { 
            return {
            left: result,
            root: "/",
            right:element[3]
            } 
        }
        else{
        	return head;
        }
        }, head);
    }
Factor
    =_"+"_ tail:(Factor)+_{//
         return tail.reduce(function(result,element){
            return{
				left:result,
                root:"+",
                right:element//一元+也可以加0
            }
        },0);
    }
    /_"-"_ tail:(Factor)+_{//
        return tail.reduce(function(result,element){
            return{
                left:result,
                root:"-",
                right:element//因为只有一个匹配所以不需要用数组，所以直接element就可以表示
            }
        },0);
    }
    / com:Component{
    return com;}
    // "(" _expr:Expression _ ")" {return expr;}
Component
    = head:Atom tail:(_"**"_ Component)*{
        return tail.reduce(function(result,element){
			return {
            left:head,
            root:"**",
            right:element[3]
			}	
		},head);
    }

Atom
	= CONST_ID//常数
    / p:(_ PARA _/ _ CONST_VAR _){//参数 和 常量
         if(p[1]) return p[1];
         else if(p[4]) return p[4];
	}
	/*
		varObj["PI"]=math.PI;
	varObj["E"]=2.73;
	varObj["zxr"]=3.18;
	varObj["fyk"]=6.66;
	varObj["wqd"]=8.88;
	*/
    / f:FUNC _ '('_ expr:Expression _ ")" {
		return {
			root:f,
			right:expr,
			type:"func"
		};
	}
    / "(" _ expr:Expression _ ")" { return expr; }


PARA  "parameter"
 	= l:("T"i / "I"i / "theta"i){
		return l.toString();
 	}
CONST_VAR "the const value"
	= l:("PI"i/"E"i/"zxr"i/"wqd"i/"fyk"i){
		if(l.toLowerCase()==="pi")
			return Math.PI;
		else if(l.toLowerCase()==="E")
			return Math.E;
		else if(l.toLowerCase()==="zxr")
			return 3.18;
		else if(l.toLowerCase()==="wqd")
			return 6.66;
		else if(l.toLowerCase()==="fyk")
			return 8.88;
	}

CONST_ID "const float"
	= l: (digit+(".")?( digit*)?){
    var part = [];
    for(var i=0; i < l.length; i++){
    var isFunction;
    try{
      //这里的代码需要用try一下,因为当showFace为定义时会抛出异常
      isFunction = typeof(eval('l[i].join'))=="function";
    }catch(e){}
    	if(l[i]&&l[i][0]&&isFunction){//[0]一般是有的
    		part.push(l[i].join(""));
            }
        else if(l[i]&&isFunction ){
        	part.push(l[i].join(""));
        }
        else{
        	part.push(l[i]);
        }
     }
     if(part)
    	return parseFloat(part.join(""));//捕获到的是第一组
}
WordWithNumeric
	= l:ALPHA_NUMERIC_CHARS+ {
	return l.join('');
}
FUNC 
    =l:("cos"i/"sin"i/"tan"i/"exp"i){
		return l.toString();
	}
ALPHA_NUMERIC_CHARS
  = [a-zA-Z0-9]
letter    
	= l:[a-zA-Z_]{return l.toString();}
digit    
	= [0-9] 
COMMEN "返回一个注释"    
	= "//" / "--"

_ "whitespace"
    = [\t \n \r \f \v]*(" ")*
SEMICO        
	= ";"
L_B     
	= _ "("_
R_B
	= _ ")" _
COMMA         
	= "," 
PLUS          
	= "+"
MINUS         
	= "-"
MUL          
	= "*"
DIV           
	= "/"
POWER         
	= "**"
ID            
	= letter+ (letter/digit)*


