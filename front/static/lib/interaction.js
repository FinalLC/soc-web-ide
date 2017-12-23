window.onload = function(){

	const path = require('path');
	const {exec} = require('child_process');
	var path_head = path.join(__dirname, 'code/');
	var path1;
	var result = document.getElementById('resultarea')

	var newFile = document.getElementById('new');
	newFile.onclick = function () {
		// body...
		console.log("new file~~~");
		editor.setValue("");
		console.log("new file succeed~~~");
	}

	//本地文件的读取
	var lopenf = document.getElementById('import');
	lopenf.onclick = function(){
		document.getElementById('files').click();
	}
	var fileRead = document.getElementById('files');
	fileRead.onchange = function(){
		console.log('reading file begins!!!')
		var selectedFile = document.getElementById("files").files[0];
		//获取读取的File对象
    	name = selectedFile.name;//读取选中文件的文件名
    	path1= path_head+name;//把路径中的\全部换成/
    	//console.log(path1);
    	var size = selectedFile.size;//读取选中文件的大小

    	var reader = new FileReader();//这里是核心！！！读取操作就是由它完成的。
    	reader.readAsText(selectedFile);//读取文件的内容

    	reader.onloadend = function(){
    		//console.log(this.result);//当读取完成之后会回调这个函数，
        	//然后此时文件的内容存储到了result中。直接操作即可。
        	editor.setValue(this.result);
        };
    }

    var fileWrite = document.getElementById('export');
    fileWrite.onclick = function(){
    	console.log('writing file begins!!!');

    	var content = editor.getValue();
    	var name = 'newFile.c';
    	var	file = new File([content],name,{type:"text/plain;charset=utf-8"});

    	saveAs(file);
    	console.log('writing file succeed!!!');
    }

    var exit = document.getElementById('exit');//theme----seti
    exit.onclick = function(){
    	console.log("function exit begin~~~");
    	if(confirm("您确定要关闭本应用吗？")){
    		window.location.href="about:blank";
    		window.close();
    	}
    	else{
    	}
    	console.log("function exit succeed~~~");
	    //alert("~成功更换主题5~");
	}

		//全屏功能的实现
		var fullscr = document.getElementById('fullscr');
		fullscr.onclick = function(){
			console.log("fullScren~~~");
			editor.setOption("fullScreen",true);
			alert("~退出全屏请按F11~");
		}

		var compiler = document.getElementById('compiler');
		compiler.onclick = function () {
		// body...
		console.log("complier~~~");
		//console.log(name);
		
		
		//var path1 = path.join(__dirname, 'run/assembler/MyAssembler1.exe');
		//var path2 = path.join(__dirname, 'run/assembler/test.asm');
  		// var path2 = path.join(__dirname, 'run/MyAssembler1.exe');
  		
  		//编译
  		exec('.\\compiler.exe '+path1, {
  			cwd: path.join(__dirname, 'run/compiler/')
  		}, (error, stdout, stderr) => {
  			if (error) {
  				console.error(`exec error: ${error}`);  				
  				result.value=`error: ${error}`;
  				return;
  			}
  			if(stdout){
  				result.value=`${stdout}`;
  				console.log(result.value);
  				//汇编
  				exec('.\\MyAssembler1.exe ..\\compiler\\a.s', {
  					cwd: path.join(__dirname, 'run/assembler/')
  				}, (error, stdout, stderr) => {
  					if (error) {
  						console.error(`exec error: ${error}`);
  						result.value= result.value+`error: ${error}`;
  						return;
  					}
  					if(stdout){
  						console.log(result.value);
  						result.value= result.value+`${stdout}`;
  						console.log(result.value);
  						return;
  					}
  					if(stderr){
  						result.value= result.value+`stderr: ${stderr}`;
  						return;
  					}
  				});
  				return;

  			}
  			if(stderr){
  				result.value=`stderr: ${stderr}`;
  				return;
  			}
  			// console.log(`stdout: ${stdout}`);
  			// console.log(`stderr: ${stderr}`);
  		});

  		console.log("compiler completed~~~");
  	}

  	var help = document.getElementById('help');
  	help.onclick = function () {
  		exec('使用说明.txt', {
  			cwd: path.join(__dirname, 'run/mannul/')
  		}, (error, stdout, stderr) => {
  			if (error) {
  				console.error(`exec error: ${error}`);
  						//result.value= result.value+`error: ${error}`;
  						return;
  					}
  					if(stdout){
  						console.log(`${stdout}`);
  						return;
  					}
  					if(stderr){
  						console.log(`${stderr}`);
  						return;
  					}
  				});
  	}


	//5种主题的设置
	var theme1 = document.getElementById('blackboard');//theme----blackboard
	theme1.onclick = function(){
		console.log("blackboard~~~");
		editor.setOption("theme","blackboard");
		console.log("blackboard load succeed~~~");
	    //alert("~成功更换主题1~");
	}

	var theme2 = document.getElementById('eclipse');//theme----eclipse
	theme2.onclick = function(){
		console.log("eclipse~~~");
		editor.setOption("theme",'eclipse');
		console.log("eclipse load succeed~~~");
	    //alert("~成功更换主题2~");
	}

	var theme3 = document.getElementById('monokai');//theme----monokai
	theme3.onclick = function(){
		console.log("monokai~~~");
		editor.setOption("theme",'monokai');
		console.log("monokai load succeed~~~");
	    //alert("~成功更换主题3~");
	}

	var theme4 = document.getElementById('night');//theme----night
	theme4.onclick = function(){
		console.log("night~~~");
		editor.setOption("theme",'night');
		console.log("night load succeed~~~");
	    //alert("~成功更换主题4~");
	}

	var theme5 = document.getElementById('seti');//theme----seti
	theme5.onclick = function(){
		console.log("seti~~~");
		editor.setOption("theme",'seti');
		console.log("seti load succeed~~~");
	    //alert("~成功更换主题5~");
	}

}

// function fullScr()
// {
// 	console.log("fullScren~~~");
// 	editor.setOption("fullScreen",true);
// 	alert("~退出全屏请按F11~");
// }