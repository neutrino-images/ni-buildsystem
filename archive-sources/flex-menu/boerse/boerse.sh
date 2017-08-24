#!/bin/sh
# Boerse Plugin
# by theobald123 for coolstream
# VERSION=1.3

# *************************************************************************************
# *      Datenzeile in einzelne Parameter aufteilen                                   *
# *-----------------------------------------------------------------------------------*
# *      Übergabeparameter : Datenzeile                                               *
# *************************************************************************************
Parameter ()
{ pn=$#;p1=$1;p2=$2;p3=$3;p4=$4;p5=$5;p6=$6;p7=$7;p8=$8;p9=$9;p10=$10; }

# *************************************************************************************
# *      exit-Steuerung                                                               *
# *************************************************************************************
Beenden ()
{
if [ $? = 0 ]; then
	break
fi
}

# *************************************************************************************
# *      Zeichen ersetzen, HTML-Tags entfernen, Leerzeilen entfernen                  *
# *-----------------------------------------------------------------------------------*
# *      Übergabeparameter : Eingabedatei Ausgabedatei                                *
# *************************************************************************************
Substitution ()
{
sed -e 's/Ã¤/ä/g' -e 's/&auml;/ä/g'  -e 's/&#228;/ä/g' \
	-e 's/Ã¶/ö/g' -e 's/&ouml;/ö/g'  -e 's/&#246;/ö/g' \
	-e 's/Ã¼/ü/g' -e 's/&uuml;/ü/g'  -e 's/&#252;/ü/g' \
	-e 's/Ã„/Ä/g' -e 's/&Auml;/Ä/g'  -e 's/&#196;/Ä/g' \
	-e 's/Ã–/Ö/g' -e 's/&Ouml;/Ö/g'  -e 's/&#214;/Ö/g' \
	-e 's/Ãœ/Ü/g' -e 's/&Uuml;/Ü/g'  -e 's/&#220;/Ü/g' \
	-e 's/ÃŸ/ß/g' -e 's/&szlig;/ß/g' -e 's/&#223;/ß/g' \
	-e 's/ss¡/+/g' \
	-e 's/é/e/g'  -e 's/Ã©/e/g' \
    -e 's/&#48;/0/g' -e 's/&#49;/1/g'  -e 's/&#50;/2/g'  -e 's/&#51;/3/g'  -e 's/&#52;/4/g'  -e 's/&#53;/5/g'  -e 's/&#54;/6/g'  -e 's/&#55;/7/g'  -e 's/&#56;/8/g'  -e 's/&#57;/9/g' \
    -e 's/&#65;/A/g' -e 's/&#66;/B/g'  -e 's/&#67;/C/g'  -e 's/&#68;/D/g'  -e 's/&#69;/E/g'  -e 's/&#70;/F/g'  -e 's/&#71;/G/g'  -e 's/&#72;/H/g'  -e 's/&#73;/I/g'  -e 's/&#74;/J/g'  -e 's/&#75;/K/g'  -e 's/&#76;/L/g'  -e 's/&#77;/M/g'  -e 's/&#78;/N/g'  -e 's/&#79;/O/g'  -e 's/&#80;/P/g'  -e 's/&#81;/Q/g'  -e 's/&#82;/R/g'  -e 's/&#83;/S/g'  -e 's/&#84;/T/g'  -e 's/&#85;/U/g'  -e 's/&#86;/V/g'  -e 's/&#87;/W/g'  -e 's/&#88;/X/g'  -e 's/&#89;/Y/g'  -e 's/&#90;/Z/g' \
    -e 's/&#97;/a/g' -e 's/&#98;/b/g'  -e 's/&#99;/c/g'  -e 's/&#100;/d/g' -e 's/&#101;/e/g' -e 's/&#102;/f/g' -e 's/&#103;/g/g' -e 's/&#104;/h/g' -e 's/&#105;/i/g' -e 's/&#106;/j/g' -e 's/&#107;/k/g' -e 's/&#108;/l/g' -e 's/&#109;/m/g' -e 's/&#110;/n/g' -e 's/&#111;/o/g' -e 's/&#112;/p/g' -e 's/&#113;/q/g' -e 's/&#114;/r/g' -e 's/&#115;/s/g' -e 's/&#116;/t/g' -e 's/&#117;/u/g' -e 's/&#118;/v/g' -e 's/&#119;/w/g' -e 's/&#120;/x/g' -e 's/&#121;/y/g' -e 's/&#122;/z/g' \
    -e 's/&#176;/°/g' -e 's/&deg;/°/g' \
    -e 's/&amp;/\&/g' \
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

while :; do
# *-----------------------------------------------------------------------------------*
# *      Index anfordern                                                              *
# *-----------------------------------------------------------------------------------*
	auswahl=1
	while :; do
		msgbox title="Indexauswahl" size=28 order=1 msg="~cBitte ausw~ahlen!" select="DAX,SDAX,MDAX,TecDAX" default=$auswahl
		auswahl=$?
		case $auswahl	in
		1)
			Index=159096
			;;
		2)
			Index=159191
			;;
		3)
			Index=159090
			;;
		4)
			Index=158375
			;;
		*)
			exit
			;;
		esac
		wget -O /tmp/boerse.txt  "http://kurse.boerse.ard.de/ard/indizes_einzelkurs_uebersicht.htn?u=5534156&i=$Index&sektion=einzelwerte"
		Substitution /tmp/boerse.txt /tmp/boerse1.txt

# *-----------------------------------------------------------------------------------*
# *      Daten auswählen und Liste aufbauen                                           *
# *-----------------------------------------------------------------------------------*
		Anfang=`sed -n -e "/Bezeichnung/ ="	/tmp/boerse1.txt`; Anfang=`expr "$Anfang" + 1`
		Ende=`sed -n -e "/Performance/ ="		/tmp/boerse1.txt`; Parameter $Ende;  Ende=$p2
		tab1=$Anfang; tab2=`expr "$Anfang" + 1`; tab3=`expr "$Anfang" + 2`; tab4=`expr "$Anfang" + 3`; tab5=`expr "$Anfang" + 4`; tab6=`expr "$Anfang" + 5`; step=7
		a1=`sed -n -e "$tab1"p /tmp/boerse1.txt`; a1=`echo $a1`		# Bezeichnung
		a2=`sed -n -e "$tab2"p /tmp/boerse1.txt`; a2=`echo $a2`		# aktuell
		Head="$a1 : $a2"
		tab1=`expr "$tab1" + $step`; tab2=`expr "$tab2" + $step`; tab3=`expr "$tab3" + $step`; tab4=`expr "$tab4" + $step`; tab5=`expr "$tab5" + $step`; tab6=`expr "$tab6" + $step`
		while [ "$tab6" -lt "$Ende" ]; do
			count=1
			echo ~T0100Bezeichnung~T0500aktuell~T0650+/-~T0750%~T0850Zeit~T0950Umsatz in EUR >  /tmp/boerse2.txt
			while [ $count -le 10 -a "$tab6" -le "$Ende" ]; do
				a1=`sed -n -e "$tab1"p /tmp/boerse1.txt`; a1=`echo $a1`		# Bezeichnung
				a2=`sed -n -e "$tab2"p /tmp/boerse1.txt`; a2=`echo $a2`		# aktuell
				a3=`sed -n -e "$tab3"p /tmp/boerse1.txt`; a3=`echo $a3`		# +/-
				a4=`sed -n -e "$tab4"p /tmp/boerse1.txt`; a4=`echo $a4`		# %
				a5=`sed -n -e "$tab5"p /tmp/boerse1.txt`; a5=`echo $a5`		# Zeit
				a6=`sed -n -e "$tab6"p /tmp/boerse1.txt`; a6=`echo $a6`		# Umsatz
				echo ~T0100$a1~T0500$a2~T0650$a3~T0750$a4~T0850$a5~T0950$a6 >> /tmp/boerse2.txt
				count=`expr "$count" + 1`
				tab1=`expr "$tab1" + $step`; tab2=`expr "$tab2" + $step`; tab3=`expr "$tab3" + $step`; tab4=`expr "$tab4" + $step`; tab5=`expr "$tab5" + $step`; tab6=`expr "$tab6" + $step`
			done

# *-----------------------------------------------------------------------------------*
# *      Daten ausgeben (Framebuffer)                                                 *
# *-----------------------------------------------------------------------------------*

			if [ $tab6 -le $Ende ] ; then
				msgbox title="$Head" size=26 timeout=180 msg=/tmp/boerse2.txt
			else
				msgbox title="$Head" size=26 timeout=180 popup=/tmp/boerse2.txt
			fi
			Beenden
		done
	done
done

# *-----------------------------------------------------------------------------------*
# *      TMP-Dateien loeschen                                                         *
# *-----------------------------------------------------------------------------------*
rm /tmp/boerse*.txt

