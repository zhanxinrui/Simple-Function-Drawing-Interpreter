# Simple-Function-Drawing-Interpreter

### All functions that have implemented 
rot is 0;			-- set the rotation arc(angle is 0)  

scale is (1, 1);		-- set the ratio of Horizontal and vertical coordinates  

color is (100,100,100);  --set R,G,B color  

width is 2;		 --set the lineWidth  

for T from 0 to 200 step 1 draw (t, 0);  -- Horizontal trace（0）  

for T from 0 to 150 step 10 draw (0, -t);  -- coordinates trace （0）  

for T from 0 to 5 step 1 draw (t, -t);      


--- 
###PEGJS
- PEG: parsing expression grammar close to CFG
- using PEGJS :https://pegjs.org/   You can find some example here
- and build the .pegjs at https://pegjs.org/online conviently. (if you don't use node you can simpley input the Parser variable:window.MY_PARSER_NAME and then export the .js ,finally use the <script src="..">to load)
- call the parser: window.MY_PARSER_NAME.parse(str_wait_to_parse) which returns a json.

view the effect http://zhanxinrui.top/media/html/sfdi/index.html


