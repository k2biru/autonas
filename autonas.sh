#!/bin/bash
# Oleh Bayu Aditya H. <b@yuah.web.id>
# inspirasi dari skrip dari Maz Zulhaj (http://blog.ub.ac.id/mightymonkey/)
# Versi  : 2015-05-30 10:30:10 WIB
# Revisi : 2015-06-01 08:40:07 WIB
# Revisi : 2016-10-19 16:01:04 WIB

# Variabel.
MASUK_USER="XXXXXXX"
MASUK_PASS="XXXXX"
JEDA_PERIKSA=15;
TETELE=0

# Periksa.
# Harap berikan ptotokol. Misal: http://example.com/
# URL_PERIKSA="http://ba.yuah.web.id/"
URL_PERIKSA="http://fhu.hiroshima.ppijepang.org/"
# URL_PERIKSA="http://elektro.ub.ac.id/"
# URL_PERIKSA="https://www.facebook.com"
# URL_PERIKSA="https://takada.oke/"

# Autonas.
# Alamat IP 175.45.189.132 sudah mati.

# URL_TERMAUTH="http://nas.ub.ac.id/termauth/"
# URL_WEBAUTH="http://nas.ub.ac.id/webAuth/"
# URL_LOGOUT="http://nas.ub.ac.id/ajaxlogout"

# Rev. 2016-10-19
URL_TERMAUTH="http://nas.ub.ac.id/index.htm"
URL_WEBAUTH="http://nas.ub.ac.id/ac_portal/login.php"
URL_LOGOUT="http://nas.ub.ac.id/ajaxlogout"
URL_ASAL="http://www.google.com/"

# Standar.
# Variabel.
PROG=${0##*/}
PROG_=${0##*/}:
TMP_FILE=$(mktemp -t "autonas_XXXXXXXXXXX")
TMP_RESP=$(mktemp -t "autonas_XXXXXXXXXXX")

# Fungsi.
function hapus_sebaris(){
	local panjang=$(tput cols)
	echo -en "\r"
	for (( i=0; i<$panjang; i++ ));
	do
		echo -ne " "
	done
}

function tampil_sebaris(){
	local huruf="$1"
	local panjang=${#huruf}
	local lebar_layar=$(tput cols)
	local lebar_kosong=$(($lebar_layar-$panjang))
	
	echo -en "\r"
	echo -en "${huruf}"
	for (( i=0; i<$lebar_kosong; i++ ));
	do
		echo -ne " "
	done
	echo -en "\r"
	
}
# Memeriksa kode keluar wget.
check_wget_code(){
	local code=$1
	case "$code" in
	0)
		echo "$PROG_ Tidak ditemukan kesalahan.";
		;;
	1)
		echo "Kode kesalahan umum.";
		;;
	2)
		echo "$PROG_ Gagal memecah perintah.";
		;;
	3)
		echo "$PROG_ Kesalahan I/O.";
		;;
	4)
		echo "$PROG_ Kesalahan jaringan.";
		;;
	5)
		echo "$PROG_ Kesalahan sertifikat SSL.";
		;;
	6)
		echo "$PROG_ Pengenal nama/sandi salah.";
		;;
	7)
		echo "$PROG_ Galat protokol.";
		;;
	8)
		echo "$PROG_ Peladen mengeluarkan kode kesalahan.";
		;;
	*)
		echo "$PROG_ Kesalahan tidak diketahui.";
		;;
	esac
}

# Argumen dasar WGET.
echo -ne "" > "${TMP_FILE}"
cat > "${TMP_FILE}" << ARG
	--proxy=off
	--user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0"
	--header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
	--header="Accept-Language: id,en-US;q=0.9,en;q=0.7,ar;q=0.6,ja;q=0.4,fr;q=0.3,de;q=0.1"
	--header="Accept-Encoding: gzip, deflate"
	--header="DNT: 1"
	--output-document "${TMP_FILE}"
	--no-check-certificate
	--server-response 
ARG
wget_arg=$(cat "${TMP_FILE}")
echo -ne "" > "${TMP_FILE}"

# Khusus cek.
wget_arg_cek="$wget_arg --debug"

# Tingkat tetele.
if [ $TETELE -le 0 ]
then
	wget_arg="$wget_arg --quiet"
fi
if [ $TETELE -ge 2 ]
then
	wget_arg="--debug ${wget_arg}"
fi

# Variabel tambahan.
URL_PERIKSA_RANAH=$(echo "${URL_PERIKSA}"| cut -d/ -f 3| cut -d: -f 1)
wget_arg_termauth="${wget_arg} --post-data=\"check_id=on&submit=Continue&clause=yes\" --tries=1 --referer=\"${URL_ASAL}\""

# Panjang.
wget_arg_webauth="${wget_arg}"
wget_arg_webauth="${wget_arg_webauth} --random-wait --tries=5 --read-timeout=900 "
wget_arg_webauth="${wget_arg_webauth} --referer=\"${URL_WEBAUTH}\""

# wget_arg_webauth="${wget_arg_webauth} --post-data=\"username=${MASUK_USER}&password=${MASUK_PASS}&pwd=${MASUK_PASS}&secret=true\""

# Rev. 2016-10-19
wget_arg_webauth="${wget_arg_webauth} --post-data=\"opr=pwdLogin&rememberPwd=0&userName=${MASUK_USER}&pwd=${MASUK_PASS}\""

# Mulai.
echo "Menjalankan autonas..."
if [ $TETELE -ge 1 ]
then
	echo "Berkas sementara: '${TMP_FILE}'."
	echo "Berkas sementara: '${TMP_RESP}'."
fi

JALAN=1;
while [ $JALAN -eq 1 ]
do
	do_autonas=0
	
	# Awal.
	tampil_sebaris "$PROG_ Memeriksa sambungan Internet.."
	tampil_sebaris "$PROG_ Mohon tunggu.."
	eval wget ${wget_arg_cek} \
		"${URL_PERIKSA}" >& "$TMP_RESP"
	wget_status=$(echo $?)
	
	if [ $wget_status -eq 0 ]
	then
		tampil_sebaris "\r$PROG_ `date` Masih terhubung.\r";
		balasan=$(cat "$TMP_RESP")
		inang=$(perl -wpe 's/\r//g' "$TMP_RESP"|grep Host|tail -n 1 | cut -d: -f 2| tr -d '[[:space:]]')
		if [ "$URL_PERIKSA_RANAH" != "$inang" ]
		then
			echo "Ranah '$URL_PERIKSA_RANAH' berubah menjadi '$inang'."
			do_autonas=1
		fi
	else
		hapus_sebaris
		echo -en "\r$PROG_ `date` Gagal menguhubungi '${URL_PERIKSA}'...\n";
		echo "$PROG_ Kode kesalahan: WGET_$wget_status";
		check_wget_code $wget_status;
		cat "$TMP_RESP"
		do_autonas=1
	fi
	
	if [ $do_autonas -eq 1 ]
	then
		hapus_sebaris
		echo -ne "\r$PROG_ Mulai autonas untuk '${MASUK_USER}'...\n";
		
		# Mulai kirim.
		echo "$PROG_ Logout...";
		echo -ne "" > "${TMP_FILE}"
		eval wget ${wget_arg} \
			"${URL_LOGOUT}"
		wget_status=$(echo $?)
		echo "$PROG_ Selesai. Kode WGET_$wget_status.";
		check_wget_code $wget_status;
		
		txt=$(cat ${TMP_FILE})
		if [ ! -z "$txt"  ]
		then
			echo "$txt"
		fi
		
		echo "$PROG_ Termauth...";
		echo "" > ${TMP_FILE}
		eval wget ${wget_arg_termauth} \
			"${URL_TERMAUTH}"
		wget_status=$(echo $?)
		echo "$PROG_ Selesai. Kode WGET_$wget_status.";
		check_wget_code $wget_status;
		
		txt=$(cat ${TMP_FILE})
		if [ ! -z "$txt"  ]
		then
			echo "$txt"
		fi
		
		echo "$PROG_ Webauth...";
		echo "" > ${TMP_FILE}
		eval wget ${wget_arg_webauth} \
			"${URL_WEBAUTH}"
		wget_status=$(echo $?)
		echo "$PROG_ Selesai. Kode WGET_$wget_status.";
		check_wget_code $wget_status;
		
		txt=$(cat ${TMP_FILE})
		if [ ! -z "$txt"  ]
		then
			echo "$txt"
		fi
		
		echo "$PROG_ Selesai autonas.";
	fi
	
	tunggu=$JEDA_PERIKSA
	while [ $tunggu -gt 0 ] 
	do
		tampil_sebaris "$PROG_ `date` Masih terhubung. Menunggu selama $tunggu detik...";
		tunggu=$(($tunggu-1))
		sleep 1;
	done
	tampil_sebaris "$PROG_ `date` Masih terhubung. Mengulangi kembali pemeriksaan.";
done

