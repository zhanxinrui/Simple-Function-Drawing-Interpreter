$(()=>{

		var originX=0,originY=0;
		var angle = 0;
		var scaleX=1,scaleY=1;
		var para = 't'; 
		var from = 0, to  = 0,step=0;
		var color = "#000000";
		var width = 0.4;
		var PointsX = [],PointsY = [];
		var c = $("#pic")[0];
		var ctx = c.getContext("2d");

		function calcExprVal(expr,stepX=0){//0并没有什么用只是为了在函数内递归调用不出错
			let val = 0;
			console.log("calcExprVal invoked");
			console.log("typeof(expr)",typeof(expr));
			if(!expr instanceof String && !expr instanceof Number&&typeof(expr)!="number"&&!isNaN(expr)||typeof(expr)=="object"||expr.__proto__===Object){//有root的情况
				console.log("expr is an obj",expr);

				if(expr.root=='+'){
					return calcExprVal(expr.left,stepX)+calcExprVal(expr.right,stepX);
				}
				else if(expr.root=='-'){
					return calcExprVal(expr.left,stepX)-calcExprVal(expr.right,stepX);
				}
				else if(expr.root=='/'){
					return calcExprVal(expr.left,stepX)/calcExprVal(expr.right,stepX);

				}else if(expr.root=='*'){
					console.log("*  invoked");
					return calcExprVal(expr.left,stepX)*calcExprVal(expr.right, stepX)
				}else if(expr.root=='**'){
					return calcExprVal(expr.left,stepX)**calcExprVal(expr.right,stepX);
				}
			}
			else if(expr instanceof String || expr instanceof Number || typeof(expr)==="string"||typeof(expr)==="number"){
				console.log("expr is an val");
				console.log("vallll",expr);
				 if(!isNaN(expr)){
					console.log("数值值",expr);
					return expr;
				}else if(expr === para || expr.toLowerCase() === para.toLowerCase()){
					// console.log("vallll",expr);
					// console.log(expr.toLowerCase(), para.toLowerCase(),para.toLowerCase()===expr.toLowerCase());
					// console.log(para);
// 
					// console.log("yes get para");
					return stepX;
				}	
			}

		}
		function calcPaintPoints(exprX,exprY){
			PointsX = [],PointsY = [];
			for(let i = from; i < to ; i+=step){
				PointsX.push(calcExprVal(exprX,i));
				PointsY.push(calcExprVal(exprY,i));
			}

		}
		function paint(){
			console.log("PointsX",PointsX);
			console.log("PointsY",PointsY);
			ctx.lineWidth = width;
			ctx.beginPath();
			ctx.moveTo(PointsX[0],PointsY[0]);

			for(let i = 0; i < PointsX.length; i++){
				ctx.lineTo(PointsX[i],PointsY[i]);
				ctx.moveTo(PointsX[i],PointsY[i])
			}
			console.log("originX,originY:",originX,originY);
			console.log("scaleX,scaleY",scaleX,scaleY);
			console.log("angle:",angle);
			// console.log();
			ctx.translate(originX,originY);
			ctx.scale(scaleX,scaleY);
			ctx.rotate(angle);
			ctx.strokeStyle = color;
			ctx.stroke();

		}
		setInterval(()=>{	
			$("#ast").text("");
			$("#PEGinfo").text("");
			// c.width = c.width;
			console.log("c.width",c.width);

			var userInput = $("#inputarea").val();
			// console.log("got a ",a);}, 
			// console.log(Object.keys(a));
			// userInput.
			var lines = userInput.split("\n"); 
	        for(i=0;i<lines.length;i++){ 
				if(lines[i]==null||lines[i]=="") {
					lines.splice(i,1);
					continue;
				}
				console.log("lines[",i,"]",lines[i]);
				try{
					var jsonAst = window.my_parser.parse(lines[i]);
				}catch(e){
					$("#PEGinfo").html(e);

				}
				if(jsonAst.origin){
					// console.log("SEMATICS origin: ");
					// console.log("result originX:",jsonAst.origin.x);
					// console.log("result originY:",jsonAst.origin.y);
					originX = calcExprVal(jsonAst.origin.x);
					originY = calcExprVal(jsonAst.origin.y);
					console.log("result originX:",originX);
					console.log("result originY:",originY);

				}


				else if(jsonAst.color){
					console.log("SEMATICS color: ");
					let r = calcExprVal(jsonAst.color.r);
					let g = calcExprVal(jsonAst.color.g);
					let b = calcExprVal(jsonAst.color.b);
					color = "#"+r.toString(16)+g.toString(16)+b.toString(16)
					console.log(color);
				}	
				else if(jsonAst.width){
					console.log("sematics width:");
					width = jsonAst.width;
					console.log(jsonAst.width);
				}
				else if(jsonAst.scale){
					console.log("SEMATICS scale: ");
					scaleX = calcExprVal(jsonAst.scale.x);
					scaleY = calcExprVal(jsonAst.scale.y);
					console.log("result scaleX:",scaleX);
					console.log("result scaleY:",scaleY);


				}				
				else if(jsonAst.rot){
					console.log("SEMATICS rot: ");
					angle = calcExprVal(jsonAst.rot.angle);
					console.log("result angle:",angle);
				}
				else if(jsonAst.for){
					console.log("SEMATICS for: ");
					para = jsonAst.for.para;
					from = calcExprVal(jsonAst.for.from);
					to = calcExprVal(jsonAst.for.to);
					step = calcExprVal(jsonAst.for.step);
					calcPaintPoints(jsonAst.for.func_x,jsonAst.for.func_y);
					console.log("result para:",para);
					console.log("result from:",from);
					console.log("result to:",to);
					console.log("result step:",step);
					// console.log("result funcX:",);
					// console.log("");
					// PointsX = [0,15,20,30];
					// PointsY = PointsX;
					// funcY = calcPaintPoints(jsonAst.for.func_y);

					// ctx.fillStyle="#FF0000";
					paint();



				}
				// jsonAst.
				let strTmp = $("#ast").text();
				$("#ast").html(strTmp+JSON.stringify(jsonAst,null,"   ")+"\n");
	        } 

			// console.log(jsonAst);	
			},
			5000);
	})
