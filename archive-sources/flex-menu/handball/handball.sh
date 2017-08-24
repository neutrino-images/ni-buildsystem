#! /bin/sh
# Handball-Ergebnisse und Tabellen in Messagebox anzeigen
# by theobald123
# Version: 1.2 Coolstream HD1

# *************************************************************************************
# *      Datenzeile in einzelne Parameter aufteilen                                   *
# *-----------------------------------------------------------------------------------*
# *      Übergabeparameter : Datenzeile                                               *
# *************************************************************************************
Parameter ()
{ pn=$#;p1=$1;p2=$2;p3=$3;p4=$4;p5=$5;p6=$6;p7=$7;p8=$8;p9=$9;p10=$10; }

# *************************************************************************************
# *      Zeichen ersetzen, HTML-Tags entfernen, Leerzeilen entfernen                  *
# *-----------------------------------------------------------------------------------*
# *      Übergabeparameter : Eingabedatei Ausgabedatei                                *
# *************************************************************************************
Substitution ()
{
sed -e 's/Ã¤/ä/g'  -e 's/&auml;/ä/g'  -e 's/&#228;/ä/g' -e 's/&#xe4;/ä/g' \
	-e 's/Ã¶/ö/g'  -e 's/&ouml;/ö/g'  -e 's/&#246;/ö/g' -e 's/&#xf6;/ö/g' \
	-e 's/Ã¼/ü/g'  -e 's/&uuml;/ü/g'  -e 's/&#252;/ü/g' -e 's/&#xfc;/ü/g' \
	-e 's/Ã„/Ä/g'  -e 's/&Auml;/Ä/g'  -e 's/&#196;/Ä/g' -e 's/&#xc4;/Ä/g' \
	-e 's/Ã–/Ö/g'  -e 's/&Ouml;/Ö/g'  -e 's/&#214;/Ö/g' -e 's/&#xd6;/Ö/g' \
	-e 's/Ãœ/Ü/g'  -e 's/&Uuml;/Ü/g'  -e 's/&#220;/Ü/g' -e 's/&#xdc;/Ü/g' \
	-e 's/&#224;/a/g' -e 's/&#225;/a/g' -e 's/&#226;/a/g' -e 's/&#227;/a/g' -e 's/&#229;/a/g' -e 's/&#230;/ae/g' \
	-e 's/&#xe0;/a/g' -e 's/&#xe1;/a/g' -e 's/&#xe2;/a/g' -e 's/&#xe3;/a/g' -e 's/&#xe5;/a/g' -e 's/&#xe6;/ae/g' \
	-e 's/&#192;/A/g' -e 's/&#193;/A/g' -e 's/&#194;/A/g' -e 's/&#195;/A/g' -e 's/&#197;/A/g' -e 's/&#198;/AE/g' \
	-e 's/&#xc0;/A/g' -e 's/&#xc1;/A/g' -e 's/&#xc2;/A/g' -e 's/&#xc3;/A/g' -e 's/&#xc5;/A/g' -e 's/&#xc6;/AE/g' \
	-e 's/&#xe7;/c/g' -e 's/&#231;/c/g' \
	-e 's/&#xc7;/C/g' -e 's/&#199;/C/g' \
	-e 's/&#232;/e/g' -e 's/&#233;/e/g' -e 's/&#234;/e/g' -e 's/&#235;/e/g' \
	-e 's/&#xe8;/e/g' -e 's/&#xe9;/e/g' -e 's/&#xea;/e/g' -e 's/&#xeb;/e/g' \
	-e 's/&#200;/E/g' -e 's/&#201;/E/g' -e 's/&#202;/E/g' -e 's/&#203;/E/g' \
	-e 's/&#xc8;/E/g' -e 's/&#xc9;/E/g' -e 's/&#xca;/E/g' -e 's/&#xcb;/E/g' \
	-e 's/&#236;/i/g' -e 's/&#237;/i/g' -e 's/&#238;/i/g' -e 's/&#239;/i/g' \
	-e 's/&#xec;/i/g' -e 's/&#xed;/i/g' -e 's/&#xee;/i/g' -e 's/&#xef;/i/g' \
	-e 's/&#204;/I/g' -e 's/&#205;/I/g' -e 's/&#206;/I/g' -e 's/&#207;/I/g' \
	-e 's/&#xcc;/I/g' -e 's/&#xcd;/I/g' -e 's/&#xce;/I/g' -e 's/&#xcf;/I/g' \
	-e 's/&#xf1;/n/g' -e 's/&#241;/n/g' \
	-e 's/&#xd1;/N/g' -e 's/&#209;/N/g' \
	-e 's/&#242;/o/g' -e 's/&#243;/o/g' -e 's/&#244;/o/g' -e 's/&#245;/o/g' -e 's/&#248;/o/g' \
	-e 's/&#xf2;/o/g' -e 's/&#xf3;/o/g' -e 's/&#xf4;/o/g' -e 's/&#xf5;/o/g' -e 's/&#xf8;/o/g' \
	-e 's/&#210;/O/g' -e 's/&#211;/O/g' -e 's/&#212;/O/g' -e 's/&#213;/O/g' -e 's/&#216;/O/g' \
	-e 's/&#xd2;/O/g' -e 's/&#xd3;/O/g' -e 's/&#xd4;/O/g' -e 's/&#xd5;/O/g' -e 's/&#xd7;/O/g' \
	-e 's/&#249;/u/g' -e 's/&#250;/u/g' -e 's/&#251;/u/g' \
	-e 's/&#xf9;/u/g' -e 's/&#xfa;/u/g' -e 's/&#xfb;/u/g' \
	-e 's/&#xfd;/y/g' -e 's/&#253;/y/g' \
	-e 's/&#217;/U/g' -e 's/&#218;/U/g' -e 's/&#219;/U/g' \
	-e 's/&#xd8;/U/g' -e 's/&#xd9;/U/g' -e 's/&#xda;/U/g' \
	-e 's/&#xdc;/Y/g' -e 's/&#221;/Y/g' \
	-e 's/ÃŸ/ß/g'  -e 's/&szlig;/ß/g' -e 's/&#223;/ß/g' -e 's/&#xdf;/ß/g' \
	-e 's/ss¡/+/g' -e 's/â€ž//g' -e 's/â€œ//g' \
	-e 's/é/e/g'   -e 's/Ã©/e/g' -e 's/Ã‰/E/g' -e 's/Ã¡/a/g' -e 's/Ã®/i/g' -e 's/Ã±/n/g' \
	-e 's/&#48;/0/g' -e 's/&#49;/1/g'  -e 's/&#50;/2/g'  -e 's/&#51;/3/g'  -e 's/&#52;/4/g'  -e 's/&#53;/5/g'  -e 's/&#54;/6/g'  -e 's/&#55;/7/g'  -e 's/&#56;/8/g'  -e 's/&#57;/9/g' \
	-e 's/&#65;/A/g' -e 's/&#66;/B/g'  -e 's/&#67;/C/g'  -e 's/&#68;/D/g'  -e 's/&#69;/E/g'  -e 's/&#70;/F/g'  -e 's/&#71;/G/g'  -e 's/&#72;/H/g'  -e 's/&#73;/I/g'  -e 's/&#74;/J/g'  -e 's/&#75;/K/g'  -e 's/&#76;/L/g'  -e 's/&#77;/M/g'  -e 's/&#78;/N/g'  -e 's/&#79;/O/g'  -e 's/&#80;/P/g'  -e 's/&#81;/Q/g'  -e 's/&#82;/R/g'  -e 's/&#83;/S/g'  -e 's/&#84;/T/g'  -e 's/&#85;/U/g'  -e 's/&#86;/V/g'  -e 's/&#87;/W/g'  -e 's/&#88;/X/g'  -e 's/&#89;/Y/g'  -e 's/&#90;/Z/g' \
	-e 's/&#97;/a/g' -e 's/&#98;/b/g'  -e 's/&#99;/c/g'  -e 's/&#100;/d/g' -e 's/&#101;/e/g' -e 's/&#102;/f/g' -e 's/&#103;/g/g' -e 's/&#104;/h/g' -e 's/&#105;/i/g' -e 's/&#106;/j/g' -e 's/&#107;/k/g' -e 's/&#108;/l/g' -e 's/&#109;/m/g' -e 's/&#110;/n/g' -e 's/&#111;/o/g' -e 's/&#112;/p/g' -e 's/&#113;/q/g' -e 's/&#114;/r/g' -e 's/&#115;/s/g' -e 's/&#116;/t/g' -e 's/&#117;/u/g' -e 's/&#118;/v/g' -e 's/&#119;/w/g' -e 's/&#120;/x/g' -e 's/&#121;/y/g' -e 's/&#122;/z/g' \
	-e 's/&#176;/°/g' -e 's/&deg;/°/g' -e 's/Â°/°/g' \
	-e 's/&amp;/\&/g' \
	-e 's/&quot;/\"/g' -e 's/&bdquo;/\"/g' -e 's/&ldquo;/\"/g' -e "s/'/\"/g" -e 's/&apos;/\"/g' \
	-e 's/&gt;/>/g'   \
	-e 's/&lt;/</g'   \
	-e 's/&nbsp;/ /g' \
	-e 's/&plusmn;/+\/-/g' \
	-e 's/&euro;/EUR/g' \
	-e 's/<br>/ /g'   \
	-e 's/<[^>]*>//g' \
	-e '/^[^0-9a-zA-Z!-\/]*$/d' \
	$1 > $2
}

# *************************************************************************************
# *    Funktion zur Anzeige der Ergebnisse (copyright PauleFoul)                      *
# *-----------------------------------------------------------------------------------*
# *    Übergabeparameter 1: Anzeigedateiname                                          *
# *    Übergabeparameter 2: Fontgröße für Anzeige                                     *
# *************************************************************************************

Ergebnisse ()
{
	cp $1 /tmp/anzeige_neu.txt
	if [ $msg_on -eq 0 ]; then
		if [ $aktu -eq 1 ]; then
			msgbox title="$Head" size=$2 timeout=-1 popup=/tmp/anzeige_neu.txt &
		else
			msgbox title="$Head" size=$2 msg=/tmp/anzeige_neu.txt
			rm /tmp/anzeige_*.txt; rm /tmp/test*.txt
			ende=1
			wait=0
		fi
	fi

	#Wartezeit bis zum Refresh
	if [ $ende -eq 0 ]; then
		while [ $timer -le $wait ]; do
			if pidof msgbox > /dev/null; then                                      #Messagebox aktiv?
				msg_on=1
			else
				rm /tmp/anzeige_*.txt; rm /tmp/test*.txt
				ende=1
				wait=0
			fi
			sleep 1
			timer=`expr "$timer" + 1`
		done
	fi
	timer=0
}

# *************************************************************************************
# *        Funktion zum Erstellen der Tabelle für die Ligen                           *
# *-----------------------------------------------------------------------------------*
# * Übergabeparameter 1: Internet-Adresse                                             *
# *************************************************************************************

Tabelle ()
{
	rm /tmp/test*.txt
	wget -q -O /tmp/test1.txt $1
	sed -n '/Gesamt-Tabelle/,/Letzte Aktualisierung/ p'   /tmp/test1.txt > /tmp/test2.txt
	Substitution                                          /tmp/test2.txt   /tmp/test3.txt
	sed -e '/-->/d'                                       /tmp/test3.txt > /tmp/test4.txt
	schluss=`sed -ne "$ =" /tmp/test4.txt`
	echo  "~T0200Pl.~T0250Team~T0550Sp.~T0600Punkte~T0700Tore~T0820Diff." >> /tmp/test5.txt
	tab1=13; tab2=14; tab3=15; tab4=19; tab5=20; tab6=21; tab7=22; step=11
	while [ $tab7 -le $schluss ]; do
		a1=`sed -n "$tab1"p /tmp/test4.txt`;a1=`echo $a1`                                          # Platz
		a2=`sed -n "$tab2"p /tmp/test4.txt`;a2=`echo $a2`                                          # Team
		a3=`sed -n "$tab3"p /tmp/test4.txt`;a3=`echo $a3`                                          # Spiele
		a4=`sed -n "$tab4"p /tmp/test4.txt|sed -e 's/ //g' -e 's/:/~T0630:~T0650/g'`;a4=`echo $a4` # Punkte
		a5=`sed -n "$tab5"p /tmp/test4.txt`;a5=`echo $a5`                                          # +
		a6=`sed -n "$tab6"p /tmp/test4.txt`;a6=`echo $a6`                                          # -
		a7=`sed -n "$tab7"p /tmp/test4.txt`;a7=`echo $a7`                                          # Tordifferenz
		echo  "~T0200$a1~T0250$a2~T0550$a3~T0600$a4~T0700$a5~T0740:~T0760$a6~T0820$a7" >> /tmp/test5.txt
		tab1=`expr "$tab1" + $step`; tab2=`expr "$tab2" + $step`; tab3=`expr "$tab3" + $step`; tab4=`expr "$tab4" + $step`; tab5=`expr "$tab5" + $step`; tab6=`expr "$tab6" + $step`; tab7=`expr "$tab7" + $step`
	done
	msgbox title="Tabelle der $2" size=22 timeout=600 popup=/tmp/test5.txt  #Tabelle anzeigen

	#TMP-Dateien loeschen
	rm /tmp/test*.txt
}

# *************************************************************************************
# *      1. Position der Spieldaten pro Abschnitt ermitteln                           *
# *-----------------------------------------------------------------------------------*
# *      Übergabeparameter : Suchstring                                               *
# *************************************************************************************
Anfang ()
{
a1=""
while [ "$1" != "" ]; do
	a1=$1
	shift
done
}

# *************************************************************************************
# *      Spielpaarungen auslesen                                                      *
# *************************************************************************************
Paarungen ()
{
rm /tmp/test5*.txt
tab1=`expr "$1" + 1`; tab2=`expr "$1" + 2`; tab3=`expr "$1" + 3`; tab4=`expr "$1" + 4`; step=4; count=1
stop=$2
while [ $tab4 -le $stop ]; do
	a1=`sed -n "$tab1"p /tmp/test4.txt`                                 # Heimmannschaft
	a2=`sed -n "$tab2"p /tmp/test4.txt|sed -e 's/:/~T0930:~T0950/g'`    # Spielstand
	a3=`sed -n "$tab3"p /tmp/test4.txt`                                 # Gastmannschaft
	a4=`sed -n "$tab4"p /tmp/test4.txt`                                 # Termin
	Rest=`expr "$count" % 2`
	if [ $Rest -eq 0 ]; then
		echo  "~T0190$a4~T0350$a1~T0620-~T0630$a3~T0900$a2" >> /tmp/test5R.txt
	else
		echo  "~T0190$a4~T0350$a1~T0620-~T0630$a3~T0900$a2" >> /tmp/test5L.txt
	fi
	tab1=`expr "$tab1" + $step`; tab2=`expr "$tab2" + $step`; tab3=`expr "$tab3" + $step`; tab4=`expr "$tab4" + $step`; count=`expr "$count" + 1`
done
cat /tmp/test5L.txt /tmp/test5R.txt >> /tmp/test6.txt
}

# *************************************************************************************
# *        Funktion zum Erstellen der Ergebnisse für die Ligen                        *
# *-----------------------------------------------------------------------------------*
# * Übergabeparameter 1: Internet-Adresse                                             *
# *************************************************************************************

Spiele ()
{
rm /tmp/test*.txt
ende=0
while [ $ende -eq 0 ]; do
	wget -q -O /tmp/test1.txt $1
	sed -n  '/LIVETICKER/,$ p'        /tmp/test1.txt > /tmp/test2.txt
	sed -ne '3p' \
	    -ne '/LIVE/ p' \
	    -ne '/COMING/ p' \
	    -ne '/OVER/  p' \
	    -ne '/class=\"inhalt bold/ p' /tmp/test2.txt > /tmp/test3.txt
	Substitution                      /tmp/test3.txt   /tmp/test4.txt
	Head=`sed -n '2p'                 /tmp/test4.txt`
	LIVE=`sed -ne "/^LIVE$/ ="        /tmp/test4.txt`
	Anfang $LIVE
	LIVE=$a1
	COMING=`sed -ne "/^COMING$/ ="    /tmp/test4.txt`
	Anfang $COMING
	COMING=$a1
	OVER=`sed -ne "/^OVER$/ ="        /tmp/test4.txt`
	Anfang $OVER
	OVER=$a1
	schluss=`sed -ne "$ ="            /tmp/test4.txt`
	rm /tmp/test6.txt
#	LIVE-Spiele
	p1=$LIVE
	if [ "$COMING" != "" ]; then
		p2=$COMING
	elif [ "$OVER" != "" ]; then
		p2=$OVER
	else
		p2=$schluss
	fi
	if [ "$p1" != "" ]; then
		echo ~cLIVE >> /tmp/test6.txt
		Paarungen $p1 $p2
	fi
#	nächste Spiele
	p1=$COMING
	if [ "$OVER" != "" ]; then
		p2=$OVER
	else
		p2=$schluss
	fi
	echo "COMING:" $p1 $p2
	if [ "$p1" != "" ]; then
		echo ~cn~achste Spiele >> /tmp/test6.txt
		Paarungen $p1 $p2
	fi
#	letzte Spiele
	p1=$OVER
	p2=$schluss
	echo "OVER:" $p1 $p2
	if [ "$p1" != "" ]; then
		echo ~cletzte Spiele >> /tmp/test6.txt
		Paarungen $p1 $p2
	fi
	Ergebnisse /tmp/test6.txt 22
done
rm /tmp/test*.txt
}

# *************************************************************************************
# *        Liga ausw~ahlen und Daten aus Internet in eine lokale Datei einlesen       *
# *************************************************************************************

auswahl=1
while true; do
	msg_on=0
	timer=0
	wait=20
	aktu=1                                                                                        #Bei 1 ist automatische Aktualisierung ein
	msgbox title="Handball Live-Ergebnisse" size=28 order=2 msg="~cBitte eine Liga ausw~ahlen!" select="1.Liga,Tabelle,2.Liga,Tabelle" default=$auswahl
	auswahl=$?

	case $auswahl	in
	1)
		Spiele  "http://liveticker.dkb-handball-bundesliga.de/uebersicht_erste.html"
		;;

	2)
		Tabelle "http://www.dkb-handball-bundesliga.de/handball/tabelle.php?liga=1" "DKB Handball-Bundesliga"
		;;

	3)
		Spiele  "http://liveticker.dkb-handball-bundesliga.de/uebersicht_zweite.html"
		;;

	4)
		Tabelle "http://www.dkb-handball-bundesliga.de/handball/tabelle.php?liga=2" "2. Handball-Bundesliga"
		;;

	*)
		rm /tmp/test*.txt;
		exit
		;;

	esac
done

exit
