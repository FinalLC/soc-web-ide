window.onload = function(){
	//全屏功能的实现
	var fullscr = document.getElementById('fullscr');
	fullscr.onclick = function(){
		console.log("fullScren~~~");
		editor.setOption("fullScreen",true);
		alert("~退出全屏请按F11~");
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

	//本地文件的读取
	var lopenf = document.getElementById('import');
	lopenf.onclick = function(){
		document.getElementById('files').click();
	}
	var file = document.getElementById('files');
	file.onchange = function(){
		console.log('reading file begins!!!')
		var selectedFile = document.getElementById("files").files[0];
		//获取读取的File对象
		console.log(selectedFile);
    	var name = selectedFile.name;//读取选中文件的文件名
    	var size = selectedFile.size;//读取选中文件的大小
    	console.log("文件名:"+name+"大小："+size);

    	var reader = new FileReader();//这里是核心！！！读取操作就是由它完成的。
    	reader.readAsText(selectedFile);//读取文件的内容

    	reader.onload = function(){
        	//console.log(this.result);//当读取完成之后会回调这个函数，
        	//然后此时文件的内容存储到了result中。直接操作即可。
        	editor.setValue(this.result);
    	};
    }
}

// function fullScr()
// {
// 	console.log("fullScren~~~");
// 	editor.setOption("fullScreen",true);
// 	alert("~退出全屏请按F11~");
// }