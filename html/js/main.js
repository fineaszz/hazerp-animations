const Root = document.querySelector(":root");
var chuj = []
var isOpen = false
window.onload = function(e) {
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case 'openui':
                chuj = event.data.data.table
                isOpen = true
                EpicAninMenu.setup(event.data.data.table);
                break;
            case 'closeui':
                isOpen = false
                $('#card').fadeOut();
                break;
            case 'helpnotify':
                if (event.data.data.status == true) {
                    $('#helpnotify').fadeIn();
                } else {
                    $('#helpnotify').fadeOut();
                }
                break;
            case 'updateColor':
                UpdateColor(event.data.data);
                break;
            default:
                break;
        }
    })
}

var allanim = [];
let categories = [];
var EpicAninMenu = {
    setup: function(p) {
        allanim = [];
        $('#search').val('');
        $('#card').fadeIn();
        categories = []
        $('#groups').html(``);
        $('.button-back').hide();

        for (let key in p)
        {
            let icon = chuj[key].icon
            let desc = chuj[key].desc

            if (!(icon)) {
                icon = ''
            }
            if (!(desc)) {
                desc = 'Brak'
            }

            EpicAninMenu.addCategory(key, chuj[key].label, icon, desc);

            for (let i=1; i < chuj[key].items.length + 1; i++) {
                let anim = chuj[key].items[i - 1]
    
                allanim.push(anim)
            }
        }
        $(".category-button").on("click", function() {
            EpicAninMenu.addElements($(this)[0].id);
        });
    },
    addCategory: function(categoryIndex, name, icon, desc) {
        $("#groups").append(`
        <a href="#active" id="penis">      
            <div class="col d-flex justify-content-center category-button" id="${categoryIndex}">
                <div class="category">
                    <div class="category-body">
                        <div class="row">
                            <div class="col-2">
                                <div class="mb-0 d-flex justify-content-center align-items-center" id="icon">
                                    <i class="${icon}"></i>
                                </div>
                            </div>
                            <div class="col-10">
                                <h4 class="title">${name}</h4>
                                <span class="desc">${desc}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
         </a>`);
    },
    addElements: function(categoryIndex){
        $('.button-back').show();
        $('#groups').html(`<div class="animations-box"></div>`);

        for (let i=1; i < chuj[categoryIndex].items.length + 1; i++) {
            let anim = chuj[categoryIndex].items[i - 1]

            if (!(anim.hide)) {
                $(".animations-box").append(`
                <div class="animations-list" id="${i-1}">
                    <span>${anim.label} <span class="snipped">/e ${anim.keyword}</span></span>
                </div>
                `);
            }
        }

        $(".animations-list").on("click", function() {
            let anim = chuj[categoryIndex].items[$(this)[0].id]

            $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
                animData: anim,
            }))
        })
    },
    close: function () {
        isOpen = false
        $('#card').fadeOut();
        $.post(`https://${GetParentResourceName()}/closeui`, JSON.stringify({}))
    },
}

$(".button-close").on("click", function() {
    EpicAninMenu.close();
});

$(".button-back").on("click", function() {
    EpicAninMenu.setup(chuj);
});

$("#search").on("click", function() {
    $.post(`https://${GetParentResourceName()}/focus`, 'true')
});

$('#search').on('keypress', function (e) {
    if(e.which === 13){
        $.post(`https://${GetParentResourceName()}/focus`, 'false')

        const text = $(this).val()
        const findValue = [];

        for (let i=0; i < allanim.length; i++) {
            let animText = allanim[i].keyword

            if (!(animText.search(text) == -1)) {
                findValue.push(allanim[i])
            }
        }
        if (!(findValue.length == 0)) {
            $('.button-back').show();
            $('#groups').html(`<div class="animations-box"></div>`);

            for (let i=0; i < findValue.length; i++) {
                $(".animations-box").append(`
                    <div class="animations-list-search" id="${i}">
                        <span>${findValue[i].label} <span class="snipped">/e ${findValue[i].keyword}</span></span>
                    </div>
                `);
            }
            $(".animations-list-search").on("click", function() {

                $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({
                    animData: findValue[$(this)[0].id],
                }))
            });
        }
    }
});

window.addEventListener("keydown", function(e) {
    if (e.key == "Escape" && isOpen == true) {
        EpicAninMenu.close();
    }
});

function UpdateColor(data) {
    Root.style.setProperty("--mainColor", data.mainColor);
    Root.style.setProperty("--secondaryColor", data.secondaryColor + 'f4');
    Root.style.setProperty("--textColor", data.textColor);

    Root.style.setProperty("--borderColor", data.secondaryColor + '80');
}