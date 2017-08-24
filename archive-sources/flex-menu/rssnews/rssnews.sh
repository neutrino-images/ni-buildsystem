#!/bin/sh
#
# RSS-Feeds
# by theobald123 , mod by bazi98
# Version: 2.1 Coolstream HD1
# alte Version by musicus
#
# rssnews.sh  mit Rechten 755 nach /var/plugins/ kopieren
# benötigt shellexec
#-------------------------------------------------------------------------------------
# Eintragsbeispiel in shellexec.conf vom Flexmenü ohne (#)!

#MENU=RSS-NEWS
#	ACTION=&Discountfan,/var/plugins/rssnews.sh "http://www.discountfan.de/rss.xml"
#	ACTION=&Sport,/var/plugins/rssnews.sh "http://feeds.feedburner.com/SportTelegramm.xml"
#	ACTION=&News,/var/plugins/rssnews.sh "http://www.morgenweb.de/rss/newsticker.xml"
#	ACTION=&Ebay,/var/plugins/rssnews.sh "http://shop.ebay.de/i.html?_nkw=coolstream&_rss=1"
#ENDMENU

# für weitere Feeds die http-Adresse und die Beschreibung zwischen "&" und "," ändern
#-------------------------------------------------------------------------------------


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
sed -e 's/Ã¤/ä/g'  -e 's/&auml;/ä/g'  -e 's/&#228;/ä/g' -e 's/$#xe4;/ä/g' -e 's/&#xe4;/ä/g' \
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
    -e 's/&quot;/\"/g' -e 's/&bdquo;/\"/g' -e 's/&ldquo;/\"/g' -e "s/'/\"/g" -e 's/&apos;/ /g' \
	-e 's/&gt;/>/g'  -e 's/â€//g' -e 's/Â//g' \
	-e 's/&lt;/</g'   \
	-e 's/&nbsp;/ /g' \
	-e 's/&plusmn;/+\/-/g' \
	-e 's/&euro;/EUR/g'  -e 's/â‚¬/EUR/g' \
	-e 's/<br>/ /g'   \
	-e 's/<[^>]*>//g' \
	-e '/^[^0-9a-zA-Z!-\/]*$/d' \
	$1 > $2
}

# *-----------------------------------------------------------------------------------*
# *      RSS-Feed anfordern                                                           *
# *************************************************************************************
wget -O /tmp/rss.txt  "$1"
echo $(cat /tmp/rss.txt) > /tmp/rss0.txt

# *-----------------------------------------------------------------------------------*
# *      Feed-Inhalt extrahieren und Anzahl Items ermitteln                           *
# *************************************************************************************
sed -e 's/<\/channel>/\n<\/channel>\n/g' -e 's/<channel>/\n<channel>\n/g' \
    -e 's/<\/image>/\n<\/image>\n/g' -e 's/<image>/\n<image>\n/g' \
    -e 's/<\/item>/\n<\/item>\n/g' -e 's/<item>/\n<item>\n/g' \
    -e 's/<\!\[CDATA\[//g' -e 's/\]\]>//g'                          /tmp/rss0.txt > /tmp/rss1.txt
sed -n -e "/<channel>/,/<\/channel>/ p"                             /tmp/rss1.txt > /tmp/rss2.txt
sed    -e "/<image>/,/<\/image>/ d"                                 /tmp/rss2.txt > /tmp/rss3.txt
sed -e 's/<\/description>/<\/description>\n/g' \
	-e 's/<description>/\n|description| /g' \
	-e 's/<\/title>/<\/title>\n/g' \
	-e 's/\"//g' \
	-e 's/<title>/\n|title| /g'                                     /tmp/rss3.txt > /tmp/rss4.txt
Substitution                                                        /tmp/rss4.txt   /tmp/rss5.txt
sed -n -e "/^|description|/ p" -n -e "/^|title|/ p"                 /tmp/rss5.txt > /tmp/rss6.txt
Zeilen=`sed -n -e "/^|title|/ ="                                    /tmp/rss6.txt`
Parameter $Zeilen
Zeilen=$pn


# *-----------------------------------------------------------------------------------*
# *      Script für Zeilenumbruch und Newsausgabe                                     *
# *      Eigene Formatierung für Ebay-Artikel enthalten                               *
# *-----------------------------------------------------------------------------------*
echo "#!/bin/sh"                                                                                >  /tmp/wrap.sh
echo ""                                                                                         >> /tmp/wrap.sh
echo "echo \$2  >  /tmp/wrap.txt"                                                               >> /tmp/wrap.sh
echo "ebay=\`sed -n -e \"/| Zur Liste der beobachteten Artikel hinzufügen/ =\" /tmp/wrap.txt\`" >> /tmp/wrap.sh
echo "astra1=\`sed -n -e \"/Service-Typ:/ =\"                                  /tmp/wrap.txt\`" >> /tmp/wrap.sh
echo "astra2=\`sed -n -e \"/Orbitalposition:/ =\"                              /tmp/wrap.txt\`" >> /tmp/wrap.sh
echo "astra3=\`sed -n -e \"/Transponder-Nummer:/ =\"                           /tmp/wrap.txt\`" >> /tmp/wrap.sh
echo "if [ -n \$astra1 -a -n \$astra2 -a -n \$astra3 ]; then"                                   >> /tmp/wrap.sh
echo "	sed -e 's/Standard:/\nStandard:/g' -e 's/Sprache:/\nSprache:/g' -e 's/Orbitalposition:/\nOrbitalposition:/g' -e 's/Transponder-Nummer:/\nTransponder-Nummer:/g' -e 's/Frequenz (MHz):/\nFrequenz (MHz):/g' -e 's/Service Website:/\nService Website:/g' /tmp/wrap.txt > /tmp/wrap3.txt" >> /tmp/wrap.sh
echo "else"                                                                                     >> /tmp/wrap.sh
echo "	if [ \"\$ebay\" != \"\" ]; then"                                                        >> /tmp/wrap.sh
echo "		sed -e 's/Angebotsende:/\nAngebotsende:/g' -e 's/Sofort-Kaufen/\nSofort-Kaufen/g' -e 's/Jetzt bieten/\nJetzt bieten/g' /tmp/wrap.txt > /tmp/wrap1.txt" >> /tmp/wrap.sh
echo "		sed -e \"/Jetzt bieten |/ d\"  /tmp/wrap1.txt > /tmp/wrap2.txt"                     >> /tmp/wrap.sh
echo "		sed -e \"/Sofort-Kaufen |/ d\" /tmp/wrap2.txt > /tmp/wrap3.txt"                     >> /tmp/wrap.sh
echo "	else"                                                                                   >> /tmp/wrap.sh
echo "		sed -e 's/.\{55\} /&\n/g'      /tmp/wrap.txt  > /tmp/wrap3.txt"                     >> /tmp/wrap.sh
echo "	fi"                                                                                     >> /tmp/wrap.sh
echo "fi"                                                                                       >> /tmp/wrap.sh
echo "echo FONT=/share/fonts/neutrino.ttf     >  /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "echo FONTSIZE=28                        >> /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "echo HIGHT=480                          >> /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "echo WIDTH=800                          >> /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "echo LINESPP=15                         >> /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "echo MENU=                              >> /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "echo COMMENT=\$1                         >> /tmp/wrap4.txt"                               >> /tmp/wrap.sh
echo "echo COMMENT=*                          >> /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "sed -e 's/^/COMMENT= /g' /tmp/wrap3.txt >> /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "echo ENDMENU                            >> /tmp/wrap4.txt"                                >> /tmp/wrap.sh
echo "shellexec /tmp/wrap4.txt"                                                                 >> /tmp/wrap.sh
echo ""                                                                                         >> /tmp/wrap.sh
echo "rm /tmp/wrap*.txt"                                                                        >> /tmp/wrap.sh
echo "exit 0;"                                                                                  >> /tmp/wrap.sh
chmod 755                                                                                          /tmp/wrap.sh


# *-----------------------------------------------------------------------------------*
# *      Aufbau der Datei für Shellexec                                               *
# *-----------------------------------------------------------------------------------*
title=`sed -n -e "1 s/|title| // p" /tmp/rss6.txt`
echo FONT=/share/fonts/neutrino.ttf                              >  /tmp/rssconfig.conf
echo FONTSIZE=24                                                 >> /tmp/rssconfig.conf
echo HIGHT=480                                                   >> /tmp/rssconfig.conf
echo WIDTH=800                                                   >> /tmp/rssconfig.conf
echo LINESPP=15                                                  >> /tmp/rssconfig.conf
echo MENU=$title                                                 >> /tmp/rssconfig.conf
count=2;ind1=3;ind2=4;
while [ "$count" -le "$Zeilen" ]; do
	a1=`sed -n -e "$ind1 s/|title| // p"                            /tmp/rss6.txt`
	a2=`sed -n -e "$ind2 s/|description| // p"                      /tmp/rss6.txt`
    count=`expr "$count" + 1`; ind1=`expr "$ind1" + 2`; ind2=`expr "$ind2" + 2`;
    echo "ACTION=&'$a1',/tmp/wrap.sh '$a1' '$a2'"                >> /tmp/rssconfig.conf
done
echo "ENDMENU"                                                   >> /tmp/rssconfig.conf

# *-----------------------------------------------------------------------------------*
# *      Ausgabe auf Bildschirm                                                       *
# *-----------------------------------------------------------------------------------*
shellexec /tmp/rssconfig.conf

# *-----------------------------------------------------------------------------------*
# *      temporäre Dateien löschen                                                    *
# *-----------------------------------------------------------------------------------*
rm /tmp/rss*
rm /tmp/wrap.sh
exit 0;
