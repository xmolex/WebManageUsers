function join() {
    var login; login = $("#form-login").val();
    var pass;  pass  = $("#form-pass").val();
    
    if (login.length < 3) {
        alert("Логин должен состоять не менее, чем из 3х символов");
        return
    }
    var letter = login.substring(0,1);
    var reg = new RegExp("^.*[^A-zА-яЁё].*$");
    if(reg.test(letter)) {
        alert("Логин должен начинаться с буквы");
        return
    }
    if (pass.length < 3) {
        alert("Пароль должен состоять не менее, чем из 3х символов");
        return
    }
    $.ajax({
        type: 'POST',
        data: ({ "login" : login, "pass" : pass }),
        async: true,
        url: '/join',
        success: function (data, textStatus) {
            var json = JSON.parse(data);
            if (json.result == 1) {
                alert('Авторизация прошла успешна, теперь можно авторизоваться.');
                window.location = '/login';
            }
            else {
                alert('Ошибка: ' + json.error);
            }
        }
   });
}

function login_auth() {
    var login; login = $("#form-login").val();
    var pass;  pass  = $("#form-pass").val();
    
    $.ajax({
        type: 'POST',
        data: ({ "login" : login, "pass" : pass }),
        async: true,
        url: '/login',
        success: function (data, textStatus) {
            var json = JSON.parse(data);
            if (json.result == 1) {
                var from = getCookie('from');
                if (!from) {from = '/';}
                window.location = from;
            }
            else {
                alert('Ошибка: комбинация не верна');
            }
        }
   });
}

// возвращает cookie с именем name, если есть, если нет, то undefined
function getCookie(name) {
  var matches = document.cookie.match(new RegExp(
    "(?:^|; )" + name.replace(/([\.$?*|{}\(\)\[\]\\\/\+^])/g, '\\$1') + "=([^;]*)"
  ));
  return matches ? decodeURIComponent(matches[1]) : undefined;
}