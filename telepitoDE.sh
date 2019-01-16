#!/bin/bash

####Megkérdezi, melyik könyvtárba telepítsen és ellenőrzi, hogy létezik-e a megjelölt könyvtár.####
echo "Melyik könyvtárba telepítsek?"
read INSTALLDIR

if [ -d ${INSTALLDIR} ]
then
    echo "A könyvtár létezik."
else
    echo "A könyvtár nem létezik."
    exit 1
fi

####Bekéri a felhasználótól, hogy kinek (user, group) a jogosultságait kapják meg az újonnan telepített programok (start.sh, stop.sh), valamint ellenőrzi, hogy a megadott user és group létezik-e.####
echo "Melyik felhasználó futtatja a programot?"
read UNEV

FOG=`grep -w ^${UNEV} /etc/passwd | wc -c`
if test ${FOG} -gt 0
    then
    echo "A felhasználó létezik."

else 
    echo "A felhasználó nem létezik."
    exit 1
fi

echo "Melyik csoport futtatja a programot?"
read GNEV

FOG=`grep -w ^${GNEV} /etc/group | wc -c`
if test ${FOG} -gt 0
    then
    echo "A csoport létezik."

else 
    echo "A csoport nem létezik."
    exit 1
fi

####Ellenőrzi, hogy a root felhasználó próbálja-e lefuttatni a telepítő scriptet.####
USER=$(whoami)

if [[ "${USER}" = "root" ]];
then
    echo "A root felhasználó futtatja a scriptet."

else	
    echo "A root felhasználó jogosult futtatni a scriptet."
    exit 1
fi	

####Ellenőrzi, hogy az unzip program fel van-e telepítve, ha nem, megpróbálja feltelepíteni.####
if which unzip >/dev/null; then
    echo "Az unzip program rendelkezésre áll."
 
else
    echo "Az unzip program nem áll rendelkezésre, telepítsem? (i/n)"
    read ANSWER
    if [[ "${ANSWER}" = "i" ]] || [[ "${ANSWER}" = "I" ]]
	then
	    yum install unzip -y >/dev/null
	    echo "Az unzip program rendelkezésre áll."
	else
	    echo "Az unzip program továbbra sem áll rendelkezésre."
	    exit 1
	fi
fi 

####Összegző leírás####

echo "Telepítési könyvtár: "${INSTALLDIR}
echo "Programot futtató csoport: "${GNEV}
echo "Programot futtató felhasználó: "${UNEV}

####Rákérdez, hogy indulhat -e a tesztprogram.zip telepítése, nemleges válasz esetén kilép. Ellenőrzi, hogy a telepítő script és a telepítendő fájl ugyanabban a könyvtárban van-e.####
echo "Indulhat a tesztprogram.zip telepítése? (i/n)"
read ANSWER

if [ ! -f tesztprogram.zip ]
then 
	echo "A telepítő script és a telepítendő fájl eltérő könyvtárban van."	
	exit 1
fi


if [[ "${ANSWER}" = "i" ]] || [[ "${ANSWER}" = "I" ]]
then
    unzip tesztprogram -d ${INSTALLDIR}
    chown -R ${UNEV}:${GNEV} ${INSTALLDIR}/bin
    chmod -R ug+x ${INSTALLDIR}/bin
    echo "A program rendelkezésre áll."
else	
    echo "A telepítés nem sikerült."	
    exit 2
fi

