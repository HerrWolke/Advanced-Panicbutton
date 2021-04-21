$(function(){
	window.onload = (e) => {
        /* 'links' the js with the Nui message from main.lua */
		window.addEventListener('message', (event) => {
			var item = event.data;
			if (item !== undefined) {
                if (item.value === "triggerAlarm") {
                    var audio = new Audio("./audio/panic.ogg")
                    audio.play()
                } else  if (item.value === "triggerOwn") {
                    var audio = new Audio("./audio/panic_own.ogg")
                    audio.play()
                }
			}
		});
	};
});