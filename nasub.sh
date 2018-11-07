#!/bin/bash
# info lebih lanjut dapat dilihat pada laman :
# http://ristie.ub.ac.id/proyek/134-login-nas-ub-ac-id-tanpa-web-browser.html

#Variable
USERNAME="XXXXXXX"
PASSWORD="XXXXX"
URL_LOGIN = "http://nas.ub.ac.id/ac_portal/login.php"
curl --data "opr=pwdLogin&userName=${USERNAME}&pwd=${PASSWORD}&rememberPwd=1" ${URL_LOGIN}
