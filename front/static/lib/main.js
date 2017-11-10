window.onload = function(){
	
	var fullscr = document.getElementById('fullscr');
	fullscr.onclick = function(){
		console.log("fullScren~~~");
		editor.setOption("fullScreen",true);
	    alert("~退出全屏请按F11~");
	}

	var theme1 = document.getElementById('blackboard');
	theme1.onclick = function(){
		console.log("blackboard~~~");
		editor.setOption("theme","blackboard");
		console.log("blackboard load succeed~~~");
	    //alert("~成功更换主题1~");
	}

	var theme2 = document.getElementById('eclipse');
	theme2.onclick = function(){
		console.log("eclipse~~~");
		editor.setOption("theme",'eclipse');
		console.log("eclipse load succeed~~~");
	    //alert("~成功更换主题2~");
	}

	var theme3 = document.getElementById('monokai');
	theme3.onclick = function(){
		console.log("monokai~~~");
		editor.setOption("theme",'monokai');
		console.log("monokai load succeed~~~");
	    //alert("~成功更换主题3~");
	}

	var theme4 = document.getElementById('night');
	theme4.onclick = function(){
		console.log("night~~~");
		editor.setOption("theme",'night');
		console.log("night load succeed~~~");
	    //alert("~成功更换主题4~");
	}

	var theme5 = document.getElementById('seti');
	theme5.onclick = function(){
		console.log("seti~~~");
		editor.setOption("theme",'seti');
		console.log("seti load succeed~~~");
	    //alert("~成功更换主题5~");
	}


};
// function fullScr()
// {
// 	console.log("fullScren~~~");
// 	editor.setOption("fullScreen",true);
// 	alert("~退出全屏请按F11~");
// }