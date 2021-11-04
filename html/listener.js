$(function () {
    window.onload = (e) => {
        /* 'links' the js with the Nui message from main.lua */
        window.addEventListener('message', (event) => {
            var item = event.data;
            if (item !== undefined) {
                if (item.value === "triggerAlarm") {
                    var sound = new Howl({
                        src: ["./audio/panic2.wav"],
                        volume: 0.1
                      });
                      
                      sound.play();

                    // var audio = new Audio()
                    // audio.volume = 1.0
                    // audio.play()
                } else if (item.value === "triggerOwn") {
                    var audio = new Audio("./audio/panic_own.ogg")
                    audio.play()
                } else if (item.value === "respondCode99") {
                    var audio = new Audio("./audio/code_99.wav")
                    audio.volume = 0.1
                    audio.play()
                } else if (item.value === "street") {

                    
                    var audio = new Audio("./audio/streets/" + item.streetname + ".wav")
                    audio.volume = 0.2
                    audio.play()
                } else if (item.value === "play") {
                    var audio = new Audio(item.sound)
                    audio.volume = 0.3
                    audio.play()
                }
            }
        });
    };
});