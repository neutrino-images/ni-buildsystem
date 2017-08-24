#!/bin/sh
#----------------------------------------------------------------------
#
# f1info.sh
#
# V1.4h
#
# Formel 1 Infos anzeigen
#
# Quelle: http://formel1.motorsport-total.com
#
# Flexmenu Plugin und TuXWetter Plugin muessen installiert sein
#
# Aufruf uebers Flexmenu:
#
# Dreambox:
# ACTION=&Formel 1 Info,/var/script/f1info.sh makemainmenu ; if [ -f /tmp/f1info_main.inc ] ; then /var/bin/shellexec /tmp/f1info_main.inc ; rm /tmp/f1info* ; else msgbox popup='Fehler bei der Erstellung des Menues' timeout=5 ; fi
#
# DBox:
# ACTION=&Formel 1 Info,/var/plugins/f1info.sh makemainmenu ; if [ -f /tmp/f1info_main.inc ] ; then /var/plugins/shellexec /tmp/f1info_main.inc ; rm /tmp/f1info* ; else msgbox popup='Fehler bei der Erstellung des Menues' timeout=5 ; fi
#
# V1.0  erster Versuch Teaminfos
# V1.1  komplett ueberarbeitet und erweitert
# V1.2  Menu Diverses eingebaut
# V1.2a Reglement Seite hinzugefuegt
# V1.2b TV Timer eingebaut
# V1.2c Umlaute gefixt ( Nuerburgring ) , Reihenfolge der Rennen gedreht,
#       nur die beim Aufruf verfuegbaren Renn-Ergebnisse anzeigen
# V1.3  Menu Statistik hinzugefuegt
#
# V1.3a Aenderung der Abfrage fuer den Busybox Fehler echo -e "\r"
#
# V1.4  Aenderungen fuer die Saison 2007
#
# V1.4a Anpassung fuer dbox
#
# V1.4b Aenderung wegen libcurl Suchpfad
#
# V1.4c Aenderungen fuer die Saison 2008
#
# V1.4d Teamkurzinfo -> Anzeige der Fahrzeugbilder geaendert, es werden jetzt gif und jpg Bilder verarbeitet
#
# V1.4e ....
#
# V1.4f  div. Anpassungen wegen Aenderungen im Seitenaufbau von formel1.motorsport-total.com
#
# V1.4g Fehler bereinigt dbox Ausgabe Rekorde, Sounds und 'Coole Sprueche'
#
# V1.4h Anpassungen wegen Aenderungen im Seitenaufbau von formel1.motorsport-total.com
#
# V1.4ha Saison 2010 by FlatTV
#
# V1.5 Saison 2011 by FlatTV (coolstream)
# Ausgabe bei fehlendem Tuxwetter
#
# V1.5a Saison 2012 by zzzZZ
#
# Author: barabas
#----------------------------------------------------------------------
# set -x

#-------------------Boxtyp ermitteln Dreambox/DBox----------------------

#boxtype=`uname -n`
boxtype="dbox"

[ $boxtype != "dreambox" -a $boxtype != "dm7020" ] && boxtype="dbox"

if [ $boxtype = "dbox" ] ; then

    # Pfad zur shellexec, tuxwetter und msgbox
    shellexec="/bin/shellexec"
    msgbox="/bin/msgbox"
    input="/bin/input"
    tuxwetter="/bin/tuxwetter"
    #tuxwetter="/bin/msgbox popup='Anzeige leider nicht m~oglich' timeout=5; exit;"
    local_url="http://localhost"
    libcurl=":"

else

    # Flagdatei fuer TV Progamm und Soundmenu DEPENDON=....
    # Die Menues nur auf Dreamboxen anzeigen
    touch /tmp/f1info_menu.flag

    #  LD_LIBRARY_PATH setzen wegen libcurl Problem auf der Dreambox

    libcurl="export LD_LIBRARY_PATH=/tmp:/var/lib:/lib:/var/bin/tuxwet"
    $libcurl

    #-----------------------------------------------------------------------
    # Dreambox HTTP User Authentifizierung User Passwort hier aendern
    # oder in der Datei pass.txt im Skriptverzeichnis hinterlegen
    #-----------------------------------------------------------------------
    scriptname=`basename $0`
    passfile=`echo $0 | sed "s:$scriptname:pass.txt:"`
    if [ -f $passfile ] ; then
      read auth <$passfile
    else
      auth="root:dreambox"
    fi

    # Pfad zur shellexec, tuxwetter und msgbox
    shellexec="/bin/shellexec"
    msgbox="/bin/msgbox"
    input="/bin/input"
    tuxwetter="/bin/tuxwetter"
    local_url="http://$auth@localhost/root"

    # Volume Offset fuer die Lautstaerkeanhebung bei MP3 Wiedergabe
    #-----------------------------------------------------------------------
    volumeoffset=10

    #-----------------------------------------------------------------------
    # MP3 File lokal ablegen am besten auf hdd wegen Platz
    # geht natuerlich auch auf /mnt/usb etc.
    #-----------------------------------------------------------------------
    mp3dir="/hdd/mp3files"
    #-----------------------------------------------------------------------
    if [ ! -d $mp3dir ]
    then
      mkdir $mp3dir
    fi

fi

# check for widescreen (> 800)
wide=$(cat /var/tuxbox/config/neutrino.conf | grep screen_width= | cut -d'=' -f2)
if [ $wide -gt 800 ]; then
    FONTSIZE=24
    LINESPP=24
else
    FONTSIZE=24
    LINESPP=15
fi

# check echo Fehler busybox
[ `echo "\r" | grep -c "\r"` -gt 0 ] && alias echo="echo -e"

# Steuerzeichen
TAB=`echo "\t"`
CRLF=`echo "\r"`
CR=`echo "\n"`


# Tempfile
tempfile=/tmp/f1info.txt

# Menutitel
menutitel="Formel 1 Infos"

#---------------------------------------------------------------------
# Flexmenu Include Files
#---------------------------------------------------------------------
menumain="/tmp/f1info_main.inc"
menuteamkurz="/tmp/f1info_teamkurz.inc"
menustrecke="/tmp/f1info_strecke.inc"
menustreckendetail="/tmp/f1info_streckendetail.inc"
menufahrerwertung="/tmp/f1info_fahrerwertung.inc"
menufahrerinfo="/tmp/f1info_fahrerinfo.inc"
menuteamwertung="/tmp/f1info_teamwertung.inc"
menuteaminfo="/tmp/f1info_teaminfo.inc"
menuergmain="/tmp/f1info_ergmain.inc"
menuergdetail="/tmp/f1info_ergdetail.inc"
menusoundmain="/tmp/f1info_sound.inc"
menutv="/tmp/f1info_tv.inc"
menustatmain="/tmp/f1info_statmain.inc"
menustatdetail="/tmp/f1info_statdetail.inc"

tuxwetconf="/tmp/f1info_tuxwet.inc"

#---------------------------------------------------------------------
# URL
#---------------------------------------------------------------------
urlbase="http://formel1.motorsport-total.com"
urlteam="http://formel1.motorsport-total.com/f1/saison/teams.html"
urltermin="http://formel1.motorsport-total.com/f1/saison/termin.html"
urlwertung="http://formel1.motorsport-total.com/f1/wmstand.html"
urlergmain="http://formel1.motorsport-total.com/f1/ergeb/"
urlsound="http://formel1.motorsport-total.com/f1/audio/"
urlrekorde="http://formel1.motorsport-total.com/f1/rekorde.html"
urlsprueche="http://formel1.motorsport-total.com/f1/cool/?p=-1"
urlbilder="http://formel1.motorsport-total.com/f1/bilder/"
urlregel="http://formel1.motorsport-total.com/f1/reglement.html"
urltv="http://classic.klack.de/klackFormel1RSS.xml"
urlfahrerstat="http://formel1.motorsport-total.com/f1/db/drivers/stats/index.php"
urlteamstat="http://formel1.motorsport-total.com/f1/db/teams/stats/index.php"
urlenginestat="http://formel1.motorsport-total.com/f1/db/engines/stats/index.php"
urlnews="http://www2.motorsport-total.com/f1/news.html"


#------------------- Hauptmenu zusammenbauen ------------------

makemainmenu () {

     echo "
      FONT=/share/fonts/micron_bold.ttf
      FONTSIZE=$FONTSIZE
      LINESPP=$LINESPP
      MENU=Formel1 2012
      ACTION=&Ergebnisse/Startaufstellung, ( $0 ergmain $urlergmain  ; if [ -f $menuergmain ] ; then  $shellexec $menuergmain  ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
      ACTION=&Termine und Strecken, ( $0 streckeninfo $urltermin  ; if [ -f $menustrecke ] ; then $shellexec $menustrecke ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
      ACTION=&Fahrerwertung und Infos, ( $0 fahrerwertung $urlwertung  ; if [ -f $menufahrerwertung ] ; then $shellexec $menufahrerwertung ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
      ACTION=&Teamwertung und Infos, ( $0 teamwertung $urlwertung  ; if [ -f $menuteamwertung ] ; then $shellexec $menuteamwertung ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
      DEPENDON=&Formel 1 TV Termine, ( $0 tv $urltv ; if [ -f $menutv ] ; then $shellexec $menutv ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi ),/tmp/f1info_menu.flag
      COMMENT=*
      MENU=Statistik
              ACTION=&Fahrerstatistiken, ( $0 statmain $urlfahrerstat "Fahrerstatistiken" ; if [ -f $menustatmain ] ; then $shellexec $menustatmain ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
              ACTION=&Teamstatistiken, ( $0 statmain $urlteamstat "Teamstatistiken" ; if [ -f $menustatmain ] ; then $shellexec $menustatmain ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
              ACTION=&Motorstatistiken, ( $0 statmain $urlenginestat "Motorstatistiken" ; if [ -f $menustatmain ] ; then $shellexec $menustatmain ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
      ENDMENU
      MENU=Diverses
       ACTION=&Bilder aktuelles Rennwochenende, ( $0 picactwe $urlbilder ; if [ -f $tuxwetconf ] ; then $libcurl ; $tuxwetter $tuxwetconf ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
       DEPENDON=&Sounds, ( $0 sounds $urlsound  ; if [ -f $menusoundmain ] ; then $shellexec $menusoundmain ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi ),/tmp/f1info_menu.flag
       ACTION=&Formel 1 Rekorde, ( $0 rekorde $urlrekorde ; if [ -f $tempfile ] ; then $libcurl ; $tuxwetter 'TXTHTML=Rekorde,$local_url/$tempfile|<!-- PM -->|<!-- /PM -->' ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
       ACTION=&Formel 1 Reglement, ( $0 regel $urlregel ; if [ -f $tempfile ] ; then $libcurl ; $tuxwetter 'TXTHTML=Reglement,$local_url$tempfile|<!-- PM -->|<!-- /PM -->' ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
       ACTION=&Coole Spr~uche, $0 sprueche $urlsprueche
      ENDMENU

      ENDMENU" >$menumain

}

#------------------- Teamkurzinfo Menu zusammenbauen ------------------

teamkurzinfo () {

      url="$1"

      echo "FONT=/share/fonts/micron_bold.ttf
      FONTSIZE=$FONTSIZE
      LINESPP=$LINESPP" >$menuteamkurz

       wget -O- $url | sed "# CRLF fix
                               s/$CRLF//g" |\


       #--------------------------------------------------------
       # Menu Fahrer und Teams Menu zusammenbauen
       #--------------------------------------------------------
       sed  " # nur die URL Tags bearbeiten
             /Formel 1: Fahrer &amp; Teams/,/<\!-- \/PM -->/!d

             s/Formel 1: Fahrer &amp; Teams/Teams/g

             # Titel zum Menutitel machen
             s/<b class=u>/ @-@ MENU=/

             # TEAM markieren
             s:<td colspan=2 class=t2b>.*=0> :@-@    ENDMENU\n@-@    MENU=:g

             # Bild markieren
             #s:<img src=\"http\://formel1.motorsport-total.com:http\://formel1.motorsport-total.com:g
             s#<img src=\"# @-@       ACTION=\&Bild vom Fahrzeug, $libcurl ; $tuxwetter \'PICTURE=Fahrzeug Bild,#g

             #s:<td rowspan=5 valign=bottom class=t1>: @-@       ACTION=\&Bild vom Fahrzeug,$tuxwetter \'PICTURE=Fahrzeug Bild,:g

             # Fahrer markieren
             s:<td class=t1b width=140>: @-@       COMMENT=:g

             # Fahrer Land markieren
             s:<td class=t1 width=90>: a@-@ :g

             # Fahrer Alter markieren
             s:<td class=t1 width=55>: a@-@ :g

             # Fahrer Startnummer markieren
             s:<td class=t1 colspan=3>Startnummer:\n@-@       COMMENT=\*Startnummer:g

             # Fahrer Testfahrer markieren
             s:^.*Testfahrer: @-@       COMMENT=\*Testfahrer:g

             # Alle Tags loeschen
             s/<[^>]*>//g

             # alles ausser a und @ am Anfang loeschen
             s/^[^a@]*//g" |\

        sed "# nur die markierten Zeilen ausgeben
             /@-@/!d

             # GIF/JPG URL freitstellen
             s/\.gif.*$/\.gif\'\n/g
             s/\.jpg.*$/\.jpg\'\n/g

             s/&nbsp;//g" |\

             # Falls eine Zeile mit einem "a" beginnt,
             # fuege die vorhergehende hinzu und ersetzt das "a" mit einem Leerzeichen.
        sed -e :a -e '$!N;s/\na/ /;ta' -e 'P;D' |\

             # Markierung am Anfang entfernen
        sed "s/^@-@//g

             # 2.te Zeile ueberfluessiges ENDMENU entfernen
             2d

             # Markierung dazwischen durch * ersetzen
             s/ @-@ / \* /g" >>$menuteamkurz

             # ENDMENU enfuegen
             echo "      ENDMENU"  >>$menuteamkurz

       # ENDMENU Anweisung von Menu Fahrer und Teams
       echo "ENDMENU"  >>$menuteamkurz


}

# ------------------- Termine und Streckeninfos ausgeben -------------------

streckeninfo () {

       url="$1"

       #--------------------------------------------------------
       # Terminkalender zusammenbauen
       #--------------------------------------------------------
       echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Termine und Strecken" >$menustrecke

       wget -O- $url | sed "# CRLF fix
                                  s/$CRLF//g" |\

       sed "/<td>1.<\/td>/,/<\/table>/!d" |\

       sed -e :a -e '/<\/td>$/N; s/<\/td>\n//; ta' |\

       sed "/<a href=/!d

            s/^.*<a href=\"\./@/g
            s/\">/@/g
            s/<[^>]*>/@/g
            s/  *@/@/g
            s/@  */@/g
            s/@@/@/g
            s/^@//
            s/@$//" |\

       # http://formel1.motorsport-total.com/f1/saison/Melbourne.html
       # /Melbourne.html@Australien / Melbourne@16. März 2008@05:30 Uhr@MEZ@

       awk -v script=$0 -v urlbase=$urlbase -v shellexec=$shellexec -v menustreckendetail=$menustreckendetail '
                                             BEGIN {
                                                     FS="@"
                                                   }
                                                   {
                                                     # nur Streckenamen ausgeben wegen Platz
                                                     split($2,strecke,"/")
                                                     gsub(" ","",strecke[2])

      printf("ACTION=&%s %s %s, ( %s streckendetail %s '\''%s'\'' ; %s %s )\n",strecke[2],$3,$4,script ,urlbase "/f1/saison" $1,strecke[2],shellexec,menustreckendetail )

                                                   }'   >>$menustrecke



       # ENDMENU Anweisung Termine und Strecken
       echo "ENDMENU"  >>$menustrecke

       # ENDMENU Anweisung Formel 1 Infos
       echo "ENDMENU=rm /tmp/f1info*"  >>$menustrecke

}

# ------------------- Streckendetails ausgeben -------------------

streckendetail () {

 url="$1"
 strecke="$2"

 # bessere Streckenbilder bei der ARD :-)
 #urlstrepic="http://sport.ard.de/sp/formel1/rennen/img/strecken2006"
 urlstrepic="http://www.sportschau.de/sp/formel1/rennen/img/strecken2006"
 urlstrepic2="http://sport.ard.de/sp/portrait/motorsport/formel1/img/strecken"
 urlstrepic3="http://sport.ard.de/sp/formel1/rennen/img"
 urlstrepic4="http://www.motorsport-total.com/f1/saison/strecken"

 # http://sport.ard.de/sp/portrait/motorsport/formel1/img/strecken/malaysia_g.gif
 # http://sport.ard.de/sp/formel1/rennen/img/strecken2006/bahrain_400q.gif
 #http://sport.ard.de/sp/formel1/rennen/img/fuji_circuit_400.gif

 case "$strecke" in
	*Melbourne*)		picurl="${urlstrepic4}/au_gr.gif" ;;
	*Sepang*)			picurl="${urlstrepic4}/mal_gr.gif" ;;
    *Schanghai*)		picurl="${urlstrepic4}/chi_gr.gif" ;;
    *Manama*)			picurl="${urlstrepic4}/04_bah.jpg";; # "http://www.sportschau.de/sp/portrait/formel1/strecken/img/2011/bahrain_405_250.jpg" ;;
    *Barcelona*)		picurl="${urlstrepic4}/esp_gr.gif" ;;
	*Carlo*)			picurl="${urlstrepic4}/mon_gr.gif" ;;
	*Montr*al*)			picurl="${urlstrepic4}/can_gr.gif" ;;
	*Valencia*)			picurl="${urlstrepic4}/eur_gr.gif" ;;
	*Silverstone*)		picurl="${urlstrepic4}/uk_gr.gif" ;;
	*Hockenheim*)		picurl="${urlstrepic4}/10_deu.jpg";; #"http://www.sportschau.de/sp/portrait/formel1/strecken/img/2011/hockenheim_405_250.jpg" ;;
	*Budapest*)			picurl="${urlstrepic4}/hun_gr.gif" ;;
	*Francorchamps*)	picurl="${urlstrepic4}/bel_gr.gif" ;;
	*Monza*)			picurl="${urlstrepic4}/ita_gr.gif" ;;
	*Singapur*)			picurl="${urlstrepic4}/sin_gr.gif" ;;
	*Suzuka*)			picurl="${urlstrepic4}/jap_gr.gif" ;;
	*Yeongam*)			picurl="${urlstrepic4}/kor_gr.gif" ;;
	*Noida*)			picurl="${urlstrepic4}/in_gr.gif" ;;
	*AbuDhabi*)			picurl="${urlstrepic4}/abu_gr.gif" ;;
	*Austin*)			picurl="${urlstrepic4}/19_usa.jpg";; #"http://www.sportschau.de/sp/portrait/formel1/strecken/img/2011/austin_405.jpg" ;;
	*Paulo*) 			picurl="${urlstrepic4}/bra_gr.gif" ;;

	*Lumpur*) picurl="${urlstrepic2}/malaysia_g.gif" ;;
        *Imola*) picurl="${urlstrepic2}/sanmarino_g.gif" ;;
     *burgring*) picurl="${urlstrepic}/europa_400q.gif" ;;
 *Indianapolis*) picurl="${urlstrepic}/usa_400q.gif" ;;
        *Magny*) picurl="${urlstrepic}/frankreich_400q.gif" ;;
     *Istanbul*) picurl="${urlstrepic}/06_tuerkei_400q.gif" ;;
       *Fuji*) picurl="${urlstrepic3}/fuji_circuit_400.gif" ;;
 esac


 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Streckeninfo $strecke" >$menustreckendetail

 zzdata=$(wget -O- $url | sed "# CRLF fix
                      s/$CRLF//g" |\

                 sed "/Fakten/,/Linktipps/!d

                     s/^[ ]*//g

                     s/^.*<img src=\"http/@-@http/

                     s/^.*<td>/@-@/

                     s/^.*<td style=\"width:100%\">/@-@/

                     s/\&auml;/~a/g
                     s/\&uuml;/~u/g
                     s/'//g
                     s/.gif.*$/.gif/
                     s/<[^>]*>//g" |\

                sed '/@-@/!d' |\

                    # Falls eine Zeile mit einem "@-@" beginnt,
                    # fuege die vorhergehende hinzu
                sed -e :a -e '$!N;s/\n@-@/@-@/;ta' -e 'P;D') # |\

  #neu: @-@Albert Park Melbourne@-@5.303 Meter@-@58@-@307,574 km@-@MEZ +10 Stunden@-@04:00 Uhr MEZ@-@http://www.motorsport-total.com/f1/saison/strecken/au_kl.gif@-@Von 1996 bis 2005 begann

  			if [ "$strecke" != "Noida" ]; then
                echo "$zzdata" | awk  -v tuxwetter=$tuxwetter -v strecke="$strecke" -v picurl=$picurl -v libcurl="$libcurl" 'BEGIN
                                                    {
                                                     FS="@-@"
                                                    }
                                                    {
                                                      split($9,wort," ")
                                                      for(x in wort)
                                                        y=y+1

                                                      for(x=1;x<=y;x++)
                                                         {
                                                          satz=sprintf("%s %s",satz,wort[x])
                                                          if(x==10 || x==20 || x==30 || x==40 || x==50 || x==60 || x==70 || x==80 || x==90 )
                                                            satz=sprintf("%s~n",satz)
                                                         }
                                                      printf("ACTION=&Strecke anzeigen, %s ; %s '\''PICTURE=Strecke anzeigen,%s'\''\n",libcurl,tuxwetter,picurl)
                                                      printf("ACTION=&Portrait,msgbox title='\''Streckenportrait %s'\''  msg='\''%s'\'' size=23 \n",strecke,satz)
                                                      printf("COMMENT=*\n")
                                                      printf("COMMENT=L~ange:~t %s\n",$3)
                                                      printf("COMMENT=Runden:~t %s\n",$4)
                                                      printf("COMMENT=Distanz:~t %s\n",$5)
                                                      printf("COMMENT=Startzeit:~t %s\n",$7)
                                                    }
                                                END {
                                                      print "ENDMENU"
                                                    }' >>$menustreckendetail
			else
			# Spezialfall Noida: es fehlen Infos z.B. die Distanz, deshalb hier eine Sonderbehandlung, um einem segfault vorzubeugen :(
                echo "$zzhtml" | awk  -v tuxwetter=$tuxwetter -v strecke="$strecke" -v picurl=$picurl -v libcurl="$libcurl" 'BEGIN
                                                    {
                                                     FS="@-@"
                                                    }
                                                    {
                                                      split($7,wort," ")
                                                      for(x in wort)
                                                        y=y+1

                                                      for(x=1;x<=y;x++)
                                                         {
                                                          satz=sprintf("%s %s",satz,wort[x])
                                                          if(x==10 || x==20 || x==30 || x==40 || x==50 || x==60 || x==70 || x==80 || x==90 )
                                                            satz=sprintf("%s~n",satz)
                                                         }
                                                      printf("ACTION=&Strecke anzeigen, %s ; %s '\''PICTURE=Strecke anzeigen,%s'\''\n",libcurl,tuxwetter,picurl)
                                                      printf("ACTION=&Portrait,msgbox title='\''Streckenportrait %s'\''  msg='\''%s'\'' size=23 \n",strecke,satz)
                                                      printf("COMMENT=*\n")
                                                      printf("COMMENT=L~ange:~t %s\n",$3)
                                                      printf("COMMENT=Runden:~t %s\n",$4)
                                                      #printf("COMMENT=Distanz:~t %s\n",$5)
                                                      printf("COMMENT=Startzeit:~t %s\n",$5)
                                                    }
                                                END {
                                                      print "ENDMENU"
                                                    }' >>$menustreckendetail
			fi



}

# ------------------- Fahrerwertung ausgeben -------------------

fahrerwertung () {

 url="$1"

 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Fahrerwertung und Infos" >$menufahrerwertung

 wget -O- $url | sed "# CRLF fix
                      s/$CRLF//g" |\

                 sed "/Fahrerwertung/,/Teamwertung/!d

                      /<\/td>/!d
                     # alle Leerzeichen am Anfang loeschen
                     s/^[ ]*//g

                     # Platzhalterzeilen fuer die naeschten Rennwertungen loeschen
                     /&nbsp;<\/td>/d
                     # URL zusammensetzen
                     s@^.*<a href=\"@MARKE $urlbase@
                     # Fahrername
                     s/html\" target=\"_blank\">/html MARKE/

                     s/^.*align=\"right\">/MARKE/" |\

                     # Nur Markierte Zeilen bearbeiten
                 sed "/MARKE/!d
                      s/<[^>]*>//g" |\

                     # nach jeder 3ten Zeile Leerzeile einfuegen
                  sed 'n;n;G;' |\

                     # Falls eine Zeile mit einem Gleichheitszeichen "MARKE" beginnt,
                     # fuege die vorhergehende hinzu
                 sed -e :a -e '$!N;s/\nMARKE/MARKE/;ta' -e 'P;D' |\

   # neu:  MARKE 1.MARKE http://formel1.motorsport-total.com/f1/saison/Fernando_Alonso.html MARKEF. Alonso  MARKE 134
   awk -v script=$0 -v shellexec=$shellexec -v menufahrerinfo=$menufahrerinfo '
                     BEGIN {
                             FS="MARKE"
                           }
                           {

                             printf("ACTION=&%s, ( %s fahrerinfo %s '\''%s'\'' ; %s %s )\n",$4,script,$3,$4,shellexec,menufahrerinfo)
                             printf("COMMENT=*Platz:%s Gesamtpunkte:%s \n",$2,$5)

                           }
                       END {
                             print "ENDMENU"
                           }' >>$menufahrerwertung

}


# ------------------- Fahrerinfo ausgeben -------------------

fahrerinfo () {

 url="$1"
 fahrer="$2"

 # Bilder URL ermitteln
 # SuchUrl Sortiert nach neuesten Bildern , Anzahl 40 pro Seite

 # neu: http://formel1.motorsport-total.com/f1/bilder/suche.php?bps=40&sort=1&s=p4 (p4 = Schumacher Michael)

 picurl=`wget -O- $url | sed -e '/\/f1\/bilder\/suche.php?s=/!d' -e "s#<a href=\"#$urlbase#" -e 's/".*$//'`

 # Tuxwetter Config zusammenbauen

 echo "SplashScreen=0
       SystemColors=1
       ShowIcons=1
       Metric=1
       MENU=Bilder von $fahrer" >$tuxwetconf

 wget -O- $picurl | sed "# CRLF fix
                        s/$CRLF//g" |\

                    sed "/<a href=\.\/sucheshow.php/!d

                        # alles bis zur Bildnummer loeschen und ersetzen durch PICTURE
                        s/^.*s=f//g
                        s/.*b=/PICTURE=/g

                        # alles bis zur BildUrl leoschen und durch Komma ersetzen
                        s/><img src=/\,/g

                        # url umbauen
                        s:/t2/:/:g
                        s/\_tn.jpg.*$/\.jpg/g" >>$tuxwetconf

 echo "ENDMENU" >>$tuxwetconf

 # Flexmenu Config zusammenbauen

 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Fahrerinfo: $fahrer" >$menufahrerinfo

       # Den oberen Begrenzer fuer Tuxwetter setzen
       echo "START" >$tempfile

 wget -O- $url | sed "# CRLF fix
                      s/$CRLF//g" |\

                 sed "/Aktuelles Team<\/td>/,/<\!-- \/PM -->/!d

                      # Alle Tags loeschen
                      s/<[^>]*>//g

                      # alle Leerzeichen am Anfang loeschen
                      s/^[ ]*//g

                      # Text ein bischen formatieren
                      s/Quote:/ Quote: /g

                      s/Weltmeister/\nWeltmeister/g

                      /Die letzten WMs/d

                      /WM-Titel:/d

                      /Linktipps/d

                      /Internetseite/d

                      /&nbsp;/d

                      /SaisonPunkteSiege/d" |\

                      sed '/^$/d;G' >>$tempfile

                      # Ende Begrenzer einfuegen
                      echo "ENDE" >>$tempfile

       echo "ACTION=&Fahrerportrait, $libcurl ; $tuxwetter 'TXTHTML=Fahrerportrait,$local_url$tempfile|START|ENDE'
       COMMENT=*
       ACTION=&Fahrerbilder, $libcurl ; $tuxwetter $tuxwetconf
       COMMENT=OK Taste Bild Auswahl
       COMMENT=w~ahrend der Bildanzeige mit der
       COMMENT=UP / Down-Taste Bild vor zur~uck bl~attern
       COMMENT=*
       ENDMENU" >>$menufahrerinfo

}

# ------------------- Teamwertung ausgeben -------------------

teamwertung () {

 url="$1"

 #   ACTION=&Teamkurzinfos, ( $0 teamkurzinfo $urlteam  ; if [ -f $menuteamkurz ] ; then  $shellexec $menuteamkurz  ; else $msgbox popup='Fehler bei der Ermittlung der Daten' timeout=5 ;fi )
 #      COMMENT=*

 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Teamwertung und Infos" >$menuteamwertung

 wget -O- $url | sed "# CRLF fix
                      s/$CRLF//g" |\

                 sed "/Teamwertung/,/Legende/!d

                      /<\/td>/!d
                     # alle Leerzeichen am Anfang loeschen
                     s/^[ ]*//g

                     # Platzhalterzeilen fuer die naeschten Rennwertungen loeschen
                     /&nbsp;<\/td>/d

                     # URL zusammensetzen
                     s@^.*<a href=\"@MARKE $urlbase@
                     # Fahrername
                     s/html\" target=\"_blank\">/html MARKE/

                     s/^.*align=\"right\">/MARKE/
                     s/^.* align=right><b>/MARKE/" |\

                     # Nur Markierte Zeilen bearbeiten
                 sed "/MARKE/!d
                      s/<[^>]*>//g" |\

                     # nach jeder 3ten Zeile Leerzeile einfuegen
                 sed 'n;n;G;' |\

                     # Falls eine Zeile mit einem Gleichheitszeichen "MARKE" beginnt,
                     # fuege die vorhergehende hinzu
                 sed -e :a -e '$!N;s/\nMARKE/MARKE/;ta' -e 'P;D' |\

                 sed '/^$/d' |\

   # MARKE1.MARKE http://formel1.motorsport-total.com/f1/saison/Ferrari.html MARKEFerrari MARKE63

                 awk -v script=$0 -v shellexec=$shellexec -v menuteaminfo=$menuteaminfo '
                     BEGIN {
                             FS="MARKE"
                           }
                           {

                             printf("ACTION=&%s, ( %s teaminfo %s '\''%s'\'' ; %s %s )\n",$4,script,$3,$4,shellexec,menuteaminfo)
                             printf("COMMENT=*Platz:%s Gesamtpunkte:%s \n",$2,$5)

                           }
                       END {
                             print "ENDMENU"
                           }' >>$menuteamwertung

}

# ------------------- Teaminfo ausgeben -------------------

teaminfo () {

 url="$1"
 team="$2"

 # Bilder URL ermitteln
 # SuchUrl Sortiert nach neuesten Bildern , Anzahl 40 pro Seite

 # neu:http://formel1.motorsport-total.com/f1/bilder/suche.php?bps=40&sort=1&s=t2

 picurl=`wget -O- $url | sed -e '/\/f1\/bilder\/suche.php?s=/!d' -e "s#<a href=\"#$urlbase#" -e 's/".*$//'`

 # Tuxwetter Config zusammenbauen

 echo "SplashScreen=0
       SystemColors=1
       ShowIcons=1
       Metric=1
       MENU=Team-Bilder $team" >$tuxwetconf

 wget -O- $picurl | sed "# CRLF fix
                        s/$CRLF//g" |\

                    sed "/<a href=\.\/sucheshow.php/!d

                        # alles bis zur Bildnummer loeschen und ersetzen durch PICTURE
                        s/^.*s=f//g
                        s/.*b=/PICTURE=/g

                        # alles bis zur BildUrl leoschen und durch Komma ersetzen
                        s/><img src=/\,/g

                        # url umbauen
                        s:/t2/:/:g
                        s/\_tn.jpg.*$/\.jpg/g" >>$tuxwetconf

 echo "ENDMENU" >>$tuxwetconf

 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Teaminfo: $team" >$menuteaminfo

       # Den oberen Begrenzer fuer Tuxwetter setzen
       echo "START" >$tempfile

 wget -O- $url | sed "# CRLF fix
                      s/$CRLF//g" |\

                 sed "/in der F1-Datenbank/,/<\!-- \/PM -->/!d

                      # Alle Tags loeschen
                      s/<[^>]*>//g

                      # alle Leerzeichen am Anfang loeschen
                      s/^[ ]*//g

                      # Text ein bischen formatieren
                      s/Quote:/ Quote: /g

                      s/(Anzeigen:.*$//g

                      s/Weltmeister/\nWeltmeister/g

                      /Die letzten WMs/d

                      /WM-Titel:/d

                      /Linktipps/d

                      /Internetseite/d

                      /&nbsp;/d

                      /SaisonPunkteSiege/d" |\

                  sed '/^$/d;G' >>$tempfile

                  # Ende Begrenzer einfuegen
                  echo "ENDE" >>$tempfile

  echo "ACTION=&Teamportrait, $libcurl ; $tuxwetter 'TXTHTML=Teamportrait,$local_url$tempfile|START|ENDE'
        COMMENT=*
        ACTION=&Teambilder, $libcurl ; $tuxwetter $tuxwetconf
        COMMENT=OK Taste Bild Auswahl
        COMMENT=w~ahrend der Bildanzeige mit der
        COMMENT=UP / Down-Taste Bild vor zur~uck bl~attern
        COMMENT=*
        ENDMENU" >>$menuteaminfo


}

# ------------------- Ergebnisse ausgeben -------------------

# Alle vorhandenen Strecken bearbeiten

ergmain () {

 url="$1"

 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Ergebnisse & Startaufstellung" >$menuergmain

 wget -O- $url | sed "# CRLF fix
                      s/$CRLF//g" |\

                 #sed "/Ergebnisse der Saison 2010/,/<\/table>/!d
		sed "/Ergebnisse der Saison 201./,/<\/table>/!d

                     # nur Strecke und URL auswerten
                     /\/f1\/ergeb\//!d

                     # URL markieren
                     s/<a href=\"/MARKE/g

                     # Alle Tags loeschen
                     s/<[^>]*>//g

                     # Umlaute
                     s/&uuml;/~u/g

                     # Marker zw. URL und Streckename
                     s/\">/MARKE/g

                     s/\" class=\"pfr//" >$tempfile

  # MARKE/ergeb/2006/01/MARKEBahrain / Manama

                 awk -v script=$0 -v shellexec=$shellexec -v urlbase=$urlbase -v menuergdetail=$menuergdetail '
                     BEGIN {
                             FS="MARKE" ; x=1
                           }
                           {

                             strecke[x]=sprintf("ACTION=&%s, ( %s ergdetail %s '\''%s'\'' ; %s %s )\n",$3,script,urlbase $2,$3,shellexec,menuergdetail)
                             x=x+1

                           }
                       END {
                             # Reihenfolge der Rennen umkehren
                             for ( y = x ; y>=1 ; y-- )
                               print strecke[y]

                             print "ENDMENU"

                           }' $tempfile >>$menuergmain
}

# ------------------- Ergebnisse im Detail ausgeben -------------------

# Alle vorhandenen Streckenergebnisse bearbeiten

ergdetail () {

 # wir machen uns das jetzt einfach und hoffen dass die URLs fuer alle Rennen gueltig sind :-)

 # neu: http://formel1.motorsport-total.com/f1/ergeb/2007/01/11.shtml

 # 1 freie Trainig   ...../11.shtml
 # 2 freie Training  ...../21.shtml
 # 3 freie Trainig   ...../31.shtml
 # Qualifying        ...../51.shtml
 # Rennen Startauf   ...../70.shtml
 # Rennen Erg        ...../71.shtml

 strecke="$2"

 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Ergebnisse $strecke" >$menuergdetail

 # Alle Seiten bearbeiten
 # ausfaelle = Seite 71.shtml auch fuer die Ausfaelle verwenden hier nur 8 Datensaetze pro Fahrer

 for i in 11.shtml 21.shtml 31.shtml 51.shtml 70.shtml 71.shtml ausfaelle
 do

  # startstring, endstring, leer = Leerzeichen nach x Zeilen einfuegen , ist je nach Seite unterschiedlich
  case $i in

      11.shtml) url="$1$i"
                startstring="Gefahrene Zeiten"
                endestring="<\!-- \/PM -->"
                # 8 Leerzeichen
                leer="n;n;n;n;n;n;n;G;"
                menutitel="1. freies Training"
                menudatei="/tmp/f1info_1frei.inc"
                ;;
      21.shtml) url="$1$i"
                startstring="Gefahrene Zeiten"
                endestring="<\!-- \/PM -->"
                leer="n;n;n;n;n;n;n;G;"
                menutitel="2. freies Training"
                menudatei="/tmp/f1info_2frei.inc"
                ;;
      31.shtml) url="$1$i"
                startstring="Gefahrene Zeiten"
                endestring="<\!-- \/PM -->"
                leer="n;n;n;n;n;n;n;G;"
                menutitel="3. freies Training"
                menudatei="/tmp/f1info_3frei.inc"
                ;;
      51.shtml) url="$1$i"
                startstring="Gesamtklassement"
                endestring="<a name=\"s3\">"
                leer="n;n;n;n;n;n;n;G;"
                menutitel="Qualifying"
                menudatei="/tmp/f1info_quali.inc"
                ;;
      70.shtml) url="$1$i"
                startstring="Startaufstellung"
                endestring="<\!-- \/PM -->"
                # 5 Leerzeichen
                leer="n;n;n;n;G;"
                menutitel="Startaufstellung"
                menudatei="/tmp/f1info_startauf.inc"
                ;;
      71.shtml) url="$1$i"
                startstring="Rennergebnis"
								endestring=">Ausf.lle<"
                leer="n;n;n;n;n;n;n;G;"
                menutitel="Rennergebnis"
                menudatei="/tmp/f1info_rennerg.inc"
                ;;
     ausfaelle) url="${1}71.shtml"
                startstring=">Ausf.lle<"
                endestring="<\!-- \/PM -->"
                leer="n;n;n;n;n;n;G;"
                menutitel="Rennergebnis Ausf~alle"
                menudatei="/tmp/f1info_rennergausfall.inc"
                ;;

  esac


  wget -O- $url | sed "# CRLF fix
                      s/$CRLF//g" |\

                  sed "/$startstring/,/$endestring/!d

                      # nur Zeilen mit <td am Anfang bearbeiten
                      /^<td /!d

                      # URL markieren
                      s/<a href=\"/@/g

                      # Alle Tags durch Marker ersetzen
                      s/<[^>]*>/@/g

                      # entstandene Doppelmarker entfernen
                      s/@@/@/g" |\

                      # Fuege jetzt alle x Zeilen eine Leerzeile ein.
                  sed "$leer" |\

                      # Falls eine Zeile mit einem "@" endet, fuege die naechste hinzu.
                  sed -e :a -e '/@$/N; s/@\n//; ta' |\

                  sed "s/\" target=\"_blank\">/@/g
                       s/&nbsp;/-/g" >$tempfile

		  #cp  $tempfile  /tmp/ttt_$i
                  # so sehen die Zeilen jetzt aus
                  # freies Training:
                  # @1@38@/rk.shtml@R. Kubica@ (T)@/bmw.shtml@BMW@M@1:32.170@-@-@20
                  # Qualifying:
                  # @1@5@/ms.shtml@M. Schumacher@/ferrari.shtml@Ferrari@B@1:31.431@-@-@12
                  # Startaufstellung:
                  # @1@5@/ms.shtml@M. Schumacher@/ferrari.shtml@Ferrari@B
                  # Rennergebnis:
                  # @1@1@/fa.shtml@F. Alonso@/renault.shtml@Renault@M@57@1:29:46.205@-@206,018
                  # Rennausfall:
                  # @-@23@/yi.shtml@Y. Ide@/saguri.shtml@Super Aguri@B@35@+22 Rnd.@126,439

 # neu: @1@6@../../../saison/Kimi_Raeikkoenen.html@K. Räikkonen@../../../saison/Ferrari.html@Ferrari@B

                  if [ `grep -c . $tempfile` -gt 0 ] ; then

                      # ACTION Zeile fuer das jeweilige Ergebnis ausgeben
                      echo "ACTION=&$menutitel,$shellexec $menudatei" >>$menuergdetail

                      # Menudatei zusammenbauen
                      awk -v fontsize=$FONTSIZE -v linespp=$LINESPP -v script=$0 -v urlbase=$urlbase -v menutitel="$menutitel" -v shellexec=$shellexec -v menufahrerinfo=$menufahrerinfo '
                             BEGIN {
                                      FS="@"
                                      print "FONT=/share/fonts/micron_bold.ttf"
                                      print "FONTSIZE=" fontsize
                                      print "LINESPP=" linespp
                                      print "MENU=" menutitel

                                   }
                                   {

                                      gsub("../../..","/f1",$4)
                                      gsub("../../..","/f1",$6)

                                      printf("ACTION=&%s, %s fahrerinfo %s '\''%s'\'' ; %s %s \n",$5,script,urlbase $4,$5,shellexec,menufahrerinfo)

#                                      # Teamname entweder in Spalte 7 oder 8
#                                      if(match($7,".shtml") >0)
#                                         { team=$8 ; reifen=$9 }
#                                      else
#                                         { team=$7 ; reifen=$8 }
#
#                                       if (reifen=="B")
#                                         reifen="Bridgestone"
#                                       if (reifen=="M")
#                                         reifen="Michelin"
#                                      printf("COMMENT=*Platz: %s    Team: %s  \n",$2,team)

                                      if(match(menutitel,"Startaufstellung") >0)
                                        { printf("COMMENT=*Platz: %s    Team: %s\n",$2,$7) }
                                      else
                                        { printf("COMMENT=*Platz: %s    Team: %s~tZeit: %s (%s)\n",$2,$7,$8,$9) }
                                   }
                               END {
                                     print "ENDMENU"
                                   }' $tempfile >$menudatei
                  fi


 done


  # Ergebnis Menu abschliessen
  echo "ENDMENU" >>$menuergdetail
}


# ------------------- Soundmenu ausgeben -------------------

# Alle vorhandenen Eintraege bearbeiten

sounds () {

 url="$1"

 leer="n;G;"

 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Sounds" >$menusoundmain

 wget -O- $url | sed "# CRLF fix
                      s/$CRLF//g" |\

                 sed "/<h1>Audio- und Sound-Files<\/h1>/,/<\!-- \/PM -->/!d

                     # Sound Ueberschrift markieren
                     s/<a href=\"audio.html/MARKE<a href=\"audio.html/g

                     # Sound Infos Markieren
                     s/<span style=/MARKE<span style=/g

                     # nur die markierten Zeilen weiterbearbeiten
                     /^MARKE/!d" >$tempfile

                     # Fuege jetzt alle 2 Zeilen eine Leerzeile ein
                 sed "$leer" $tempfile |\

                     # Falls eine Zeile mit einem "MARKE" beginnt,
                     # fuege die vorhergehende hinzu
                 sed -e :a -e '$!N;s/\nMARKE/MARKE/;ta' -e 'P;D' |\

                     # URL zusammenbauen
                 sed "s@<a href=\"@$urlbase/f1/audio/@g

                     # Marke zwischen URL und Ueberschrift
                     s/\"><b>/MARKE/g

                     # Alle Tags loeschen
                     s/<[^>]*>//g
                     #s:</b></a></td>::g

                     s:\">:MARKE:g

                     # Markierungen ersetzen durch @
                     s/MARKE/@/g

                     # Umlaute und Sonderzeichen ersetzen und Texte kuerzen
                     s/,//g
                     s/Minuten/Min\./g
                     s/Kilobyte/Kb/g
                     s/&auml;/~a/g
                     s/&ouml;&szlig;/~z/g
                     s/Dateigr~ze/Gr~o~ze/g
                     s/Exklusiv-Interview/Interview/g
                     s/\" class=\"pfr//g" |\

                     # Leere Zeilen loeschen
                 sed '/^$/d' >$tempfile

  # Zeile sieht jetzt so aus
  # @http://www.f1total.com/audio.html?i=36@Exklusiv-Interview mit Marc Surer@http://www.f1total.com/audio.html?i=36@F1Total.com-Experte@ 14.03.2006 L~ange: 9:47 Min Gr~ze: 2.294 Kb
  # @http://formel1.motorsport-total.com/f1/audio/audio.html?i=72@Interview mit Timo Glock (Toyota)@ 01.05.2008 L~ange: 2:47 Min. Gr~o~ze: 2.622 Kb

                awk -v script=$0 'BEGIN {
                                          FS="@"
                                        }
                                        {
                                           printf("ACTION=&%s , %s play '\''%s'\'' \n",$3,script,$2)
                                           printf("COMMENT=%s\n",$4)
                                           #printf("COMMENT=*%s\n",$6)
                                        }
                                    END {
                                           print "ENDMENU"
                                        }' $tempfile >>$menusoundmain

}

# ------------------- Soundmenu ausgeben -------------------

# Alle vorhandenen Eintraege bearbeiten

play () {

     # Alle Menues vor dem abspielen schliessen
     killall shellexec

     # Variable fuer Endlosschleife
     TRUE="true"

     # Url uebergeben
     url="$1"


     # MP3 Filename aus URL ermitteln
     podurl=`wget -O- $url | sed "# CRLF fix
                                 s/$CRLF//g" |\

                     # URL mit MP3 File
                     sed "/download.php/!d" |\

                     # URL zusammensetzen
                     sed "s@<a href=\"@$urlbase/f1/audio/@

                     # alles nach der URl loeschen
                     s/\.mp3\".*/\.mp3/g"`



     # MP3 Filename extrahieren
     mp3file="`echo $podurl | sed 's/.*\///
                                   s/%20/_/g
                                   s/download.php?file=//'`"


     # Info Message ausgeben
     msgstr="Download MP3-File:~n~s~n$mp3file~n~s~nDie Wiedergabe startet nach dem Download automatisch! "
     $msgbox popup="$msgstr" title="$menutitel" timeout=5

     # MP3 File downloaden und abspielen

     wget -q -O $mp3dir/$mp3file $podurl

     sleep 2

     if [ -f $mp3dir/$mp3file ]
     then

       # Aktuellen Channel sichern
       # (aus epgrefresh Skript uebernommen, Dank an Seddi und Ahjetztja123 )

       current="`wget -O- -q http://$auth@localhost/cgi-bin/streaminfo | grep '<!-- .*:-->' | sed 's/.*<!-- \(.*\)-->/\1/'`"

       # Lautstaerke fuer mp3 Wiedergabe etwas anheben, dazu aktuellen Wert ermitteln speichern und um x erhoehen
       # Wert fuer die Variable volumeoffset wird im Hauptteil gesetzt
       # laut Beschreibung Wert 0 - 10 = max Lautstaerke das funzt bei mir aber nicht, 10 ist zu leise ...

       laut="`wget -O- -q http://$auth@localhost/cgi-bin/audio | grep "volume:" | sed 's/.*volume\: \(.*\)<br.*/\1/'`"

       neulaut=`expr $laut - $volumeoffset`
       mp3laut=`expr 63 - $neulaut`

       # Zapto MP3 File und abspielen

       wget -q -O /dev/null "http://$auth@localhost/cgi-bin/zapTo?path=4096:0:0:0:0:0:0:0:0:0:$mp3dir/$mp3file"

       # Lautstaerke anheben
       wget -q -O /dev/null "http://$auth@localhost/setVolume?volume=$mp3laut"

       # dem MP3 File kurz zeitlassen anzuspielen
       sleep 5

       # Endlosschleife --> warten bis MP3 abgespielt ist

       while $TRUE
       do

          # Wenn die Variable active unser MP3 File beinhaltet, dann laeufts noch
          # wenn nicht dann zurueckschalten
          # wird waehrend der Wiedergabe mit der FB gezapt wird das Skript ebenfalls beendet

          active="`wget -O- -q http://$auth@localhost/cgi-bin/status | grep -c $mp3file`"

          if [ $active -gt 0 ]
          then

             # 3 sec warten bis zur naechsten Ueberpruefung
             sleep 3

          else

             # MP3 File zur Sicherheit nochmal stoppen falls direkt per Fernbedienung umgeschaltet wurde

             wget -q -O /dev/null "http://$auth@localhost/cgi-bin/stop"

             # Anderer Channel laeuft Schleife verlassen und zurueck zum gespeicherten Channel
             break

          fi

       done

       # Lautstaerke wieder setzen
       laut=`expr 63 - $laut`

       wget -q -O /dev/null "http://$auth@localhost/setVolume?volume=$laut"

       # Auf gespeicherten Channel zurueckschalten

       wget -q -O /dev/null "http://$auth@localhost/cgi-bin/zapTo?path=$current"

     else

       # Datei nicht gefunden , evt. Fehler beim Download
       $msgbox title="$menutitel" popup="Fehler beim Download von ~n $podurl !" timeout=5

     fi

     # MP3 File loeschen
     if [ -f $mp3dir/$mp3file ] ; then
       rm $mp3dir/$mp3file
     fi

}

# ----------------------- Diverses ausgeben ----------------------------
# Formel 1 Rekorde
# Tempfile wird im Menu Diverses an Tuxwetter uebergeben

rekorde () {

   url="$1"

   wget -O- $url | sed "# CRLF fix
                         s/$CRLF//g" |\

                   sed "# Leerzeichen am Anfang loeschen
                        s/^[ ]*//g

                        # Tags vor und nach Ueberschriften verdoppeln
                        # fuer Formatierung in Tuxwetter
                        s:</b><br>:</b><br>\n</b><br>:g
                        s:<p><b>:<p><b>\n------------------------------------------------------------------------------\n<p><b>:g" >$tempfile

 }

# ----------------------------------------------------------------------
# Formel 1 Reglement
# Tempfile wird im Menu Diverses an Tuxwetter uebergeben

regel () {

   url="$1"

   wget -O- $url | sed "# CRLF fix
                         s/$CRLF//g" |\

                   sed "/<\!-- PM -->/,/<\!-- \/PM -->/!d

                        # Leerzeichen am Anfang loeschen
                        s/^[ ]*//g

                        # nicht auswertbare Tags in Tuxwetter loeschen
                        s/\&ndash;//g

                        # Tags vor und nach Ueberschriften verdoppeln
                        # fuer Formatierung in Tuxwetter
                        s:</b><br>:</b><br>\n</b><br>:g
                        s:<p><b>:<p><b>\n------------------------------------------------------------------------------\n<p><b>:g" >$tempfile

}


# ----------------------------------------------------------------------
# Coole Sprueche

sprueche () {

   url="$1"

   echo "START" >$tempfile

   wget -O- $url | sed "# CRLF fix
                         s/$CRLF//g" |\

                   sed '/<h1>Coole Sprüche<\/h1>/,/<!-- \/PM -->/!d' |\

                   sed "# jeden Spruch in eine Zeile
                        s/<b>/\n<b>/g" |\

                   sed "# nur die Zeilen mit Spruechen ausgeben
                        /^<b>\"/!d

                        s/<\/b><br>/~n~s~n/g

                        s/<[^>]*>/ /g"  >$tempfile

    while read msg
    do

     # alle 8 Woerter einen Zeilenumbruch einfuegen , bei size=26
     msg="`echo $msg | awk '{
                                  if(NF>=10)
                                  {
                                    for(x=1;x<=NF;x++)
                                     {
                                      printf("%s ",$(x))
                                      if(x==8 || x==16 || x==24 || x==32 || x==40 || x==48 || x==56 || x==64 )
                                        printf("~n")
                                     }
                                  }
                                 else

                                   print $0

                             }'`"



      auswahl=`msgbox title"=Coole Spr~uche" msg="$msg" select="Abbruch,>>" default=2 echo=1 size=26`
      case $auswahl in

       "Abbruch")  exit ;;
               *) ;;

      esac


    done <$tempfile

}

# ----------------------------------------------------------------------
# Bilder vom aktuellen Rennwochenende

picactwe () {

 url="$1"

 # fuer die aktuelle Strecke die URL ermitteln
 wget -O- $url | sed "# CRLF fix
                         s/$CRLF//g" |\

                 sed "/<div class=\"headline\">Grands Prix<\/div>/,/<!-- \/PM -->/!d" |\

                      # nur die ersten 5 Zeilen bearbeiten
                  sed '5q
                       /href/!d' |\

                  sed "s@<a href=@$urlbase/f1/bilder/@
                        s/<[^>]*>//g
                        s/>/@/
                        /^$/d" >$tempfile

 # http://www.f1total.com/bilder/cat.php?c=0602mal@Großer Preis von Malaysia
 # URL grosses Bild: http://www.f1total.com//bilder/2006/gp/0602mal/fr/z136.jpg

 # aktuelle URL
 read url <$tempfile

 # Titel entfernen und alle Bilder (999) nach neuesten Bildern sortiert ausgeben (sort=1)
 url="`echo $url | sed 's/@.*$//'`&bps=999&sort=1"

 # Streckenname ermitteln
 read strecke <$tempfile

 strecke="`echo $strecke | sed 's/.*@//'`"

  # Tuxwetter Config zusammenbauen

 echo "SplashScreen=0
       SystemColors=1
       ShowIcons=1
       Metric=1
       MENU=Bilder $strecke" >$tuxwetconf

 # fuer die aktuelle Strecke die Bilder URL ermitteln
 wget -O- $url | sed "# CRLF fix
                       s/$CRLF//g" >$tempfile

                     # nur die Zeilen mit Bildern bearbeiten
                 sed "/tn.jpg border/!d

                     # alles bis zur URL leoschen
                     # und PICTURE Anweisung zusammensetzen
                     s/.*<a href=.*\&b=/PICTURE=/
                     s/\&d=.><img src=/,/

                     s/_tn\.jpg.*/\.jpg/g

                     # /t/ aus URL loeschen fuer URL grosses Bild
                     s@/t/@/z@g" $tempfile >>$tuxwetconf

 echo "ENDMENU" >>$tuxwetconf

}

# ----------------------------------------------------------------------
# Formel 1 TV Programm

tv () {

 url="$1"

 # wenn Menu schon vorhanden nicht nochmal anlegen, wegen Performance
 if [ ! -f $menutv ]; then

       #--------------------------------------------------------
       # TV Menu zusammenbauen
       #--------------------------------------------------------
       echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
       MENU=Formel 1 TV Termine" >$menutv


      # fuer die aktuelle Strecke die URL ermitteln
      wget -O- $url | sed "# CRLF fix
                              s/$CRLF//g" |\

                      sed "/<item>/,/<\/channel>/!d

                          # nur description und subject zeilen bearbeiten dazu markieren
                          s/<description><\!\[CDATA\[/@/g
                          s/<dc:subject>/@SENDER /g" |\

                      sed "# nur die markierten Zeilen bearbeiten
                          /^@/!d

                          s/<[Bb][Rr]>/ /g

                          # Alle Tags durch Marker ersetzen
                          s/<[^>]*>/@ /g
                          s/@*/@/g

                          s/\]\]>/ /g

                          s/Uhr/Uhr@/g

                          # ueberfluessigen Text loeschen wegen Laenge
                          s/Formel 1[:-]*//g" |\

                          # Falls Zeile mit "@SENDER" beginnt,
                          # fuege die vorhergehende hinzu und ersetzte "@SENDER"
                     sed -e :a -e '$!N;s/\n@SENDER//;ta' -e 'P;D' |\

                     sed "# Kein Premiere, da hab ich keinen Plan wegen den Unterkanaelen Sport x
                          /Premiere/d

                          s/@ @/@ Kein Titel gefunden @/g" |\

     # @02.04 05:50 Uhr@ - @  GP Australien@  Ende 07:50 Uhr@ Rennen aus Melbourne/AUS Kommentar: Michael Stäuble  @  SF2@

     # zapping: http://root:dreambox@localhost/cgi-bin/switchService?6d6e:00c00000:0437:0001:1:9484
     #  record: http://root:dreambox@localhost/addTimerEvent?ref=1:0:1:6d6e:437:1:c00000:0:0:0:&start=1142456100&duration=6300&channel=%20ZDFdoku%20&descr=Klassenfahrt&action=dvr
     # rec-zap: http://root:dreambox@localhost/addTimerEvent?ref=1:0:1:6d67:437:1:c00000:0:0:0:&start=1142374200&duration=6600&channel=%203SAT%20&descr=Ein%20kriminelles%20Paar&action=zap

     # gibt die Zeile oberhalb des Suchbegriffes aus (hier RTL): sed -n '/^RTL$/{g;1!p;};h' /var/tuxbox/config/enigma/services | grep 00c00000
     # sid ermitteln aus services , Problem nur an Hand des Namens keine genaue Auswahl moeglich
     # z.B. werden fuer RTL die ASTRA und Hotbird Eintraege gefunden
     # nur fuer ASTRA waere kein Problem (Namespace=00c00000) aber SF2 -> Hotbird
     # N-TV steht klein in der Services! n-tv

     # wir machen es uns deshalb wieder einfach und hinterlegen die sids der betroffenen Sender
     # hier fest. Formel1 2007 gibts bei uns nur auf RTL N-TV ORF1 SF2 und Premiere


           awk -v auth=$auth -v tempfile=$tempfile '
                              BEGIN {
                                     FS="@"

                                     idrtl="2ee3:00c00000:0441:0001:1:9359"
                                     idorf1="32c9:00c00000:045d:0001:1:9390"
                                     idntv="2f3a:00c00000:0441:0001:1:9364"
                                     idsf2="038b:00820000:2134:013e:1:7045"
                                     iddsf="0384:00c00000:0021:0085:1:6710"

                                    }
                                    {
                                     channel=$(NF-1)

                                     gsub(/^[ \-]*/,"",$4)
                                     gsub(" Ende","-",$5)
                                     gsub(/^[ ]*/," ",channel)
                                     gsub(" Uhr","",$2)

                                     # Start und Ende in sec. von 01.01.1970 ermitteln
                                     # daraus die Dauer der Aufnahme errechnen
                                     # Feld2 = 02.04 05:50
                                     # daraus machen wir:
                                     # date -d 2007.04.02-05:50 +%s

                                     split($2,startz," ")
                                     split(startz[1],datum,".")
                                     kommando="date -d 2012." datum[2] "." datum[1] "-" startz[2] " +%s >" tempfile
                                     system(kommando)
                                     getline startzeit <tempfile
                                     close(tempfile)

                                     split($5,endz," ")
                                     kommando="date -d 2012." datum[2] "." datum[1] "-" endz[2] " +%s >" tempfile
                                     system(kommando)
                                     getline endezeit <tempfile
                                     close(tempfile)

                                     # Aufnahmedauer
                                     dauer=endezeit-startzeit

                                     # Trenner zwischen Datum und Uhrzeit fuer lesbarere Ausgabe
                                     gsub(" "," / ",$2)

                                     # aktuelle sids ermitteln
                                     if( match(channel,"RTL") > 0 )
                                        aktid=idrtl
                                     if( match(channel,"ORF1") > 0 )
                                        aktid=idorf1
                                     if( match(channel,"N-TV") > 0 )
                                        aktid=idntv
                                     if( match(channel,"SF2") > 0 )
                                        aktid=idsf2
                                     if( match(channel,"DSF") > 0 )
                                        aktid=iddsf

                                     # jetzt den ref= String zusammenbauen
                                     # ref=1:0:1:0382:021:1:c00000:0:0:0:
                                     # dazu zerlegen wir die id 0382:00c00000:0021:0085:1:7036

                                     split(aktid,ids,":")

                                     # fuehrende nullen des Namespace entfernen
                                     sub("00","",ids[2])
                                     # fuehrende nullen der tsid entfernen
                                     sub("0","",ids[3])

                                     recid="1:0:1:" ids[1] ":" ids[3] ":1:" ids[2] ":0:0:0:"


                                     # ACTION Eintrag msgbox
                                     printf("ACTION=&%s,msgbox size=26 title='\''TV Timer'\'' msg='\''%s~n%s~n~s~n~Y%s~S~n~s~n%s%s'\'' select='\''Schlie~zen,ZAP-To,REC-Timer,ZAP-Timer'\'' order=4 default=1 ; ret=$? ; ",$4,$4,$6,channel,$2,$5)

                                     # ZAP Eintrag
                                     printf("if [ $ret -eq 2 ]; then wget -Y off -O - http://%s@localhost/cgi-bin/switchService?%s ; fi ; ",auth,aktid)

                                     # fuer die description alle Leerzeichen durch %20 ( UTF8 Format ) ersetzen
                                     gsub(" ","%20",$4)

                                     # fuer den channel Eintrag alle Leerzeichen entfernen
                                     gsub(" ","",channel)

                                     # Record-Timer Eintrag
                                     printf("if [ $ret -eq 3 ]; then wget -Y off -O - '\''http://%s@localhost/addTimerEvent?ref=%s&start=%s&duration=%s&channel=%s&descr=%s&action=dvr'\'' >%s ; msgbox msg=%s timeout=5; fi ; ",auth,recid,startzeit,dauer,channel,$4,tempfile,tempfile)

                                     # ZAP-Timer Eintrag
                                     printf("if [ $ret -eq 4 ]; then wget -Y off -O - '\''http://%s@localhost/addTimerEvent?ref=%s&start=%s&duration=%s&channel=%s&descr=%s&action=zap'\'' >%s ; msgbox msg=%s timeout=5; fi \n",auth,recid,startzeit,dauer,channel,$4,tempfile,tempfile)

                                     printf("COMMENT=*%s%s /%s\n",$2,$5,channel)


                                   }' >>$menutv

      echo "ENDMENU" >>$menutv

 fi

}

# ----------------------------------------------------------------------
# Statistiken Mainmenu

statmain () {

 url="$1"
 stattyp="$2"

 case $stattyp in
    "Fahrerstatistiken") staturl="http://formel1.motorsport-total.com/f1/db/drivers/stats/" ;;
      "Teamstatistiken") staturl="http://formel1.motorsport-total.com/f1/db/teams/stats/" ;;
     "Motorstatistiken") staturl="http://formel1.motorsport-total.com/f1/db/engines/stats/" ;;
 esac

 #--------------------------------------------------------
 # Menu zusammenbauen
 #--------------------------------------------------------
 echo "FONT=/share/fonts/micron_bold.ttf
       FONTSIZE=$FONTSIZE
       LINESPP=$LINESPP
     MENU=$stattyp" >$menustatmain

     # fuer die aktuelle Strecke die URL ermitteln
     wget -O- $url | sed "# CRLF fix
                            s/$CRLF//g" |\

                     sed '/php" class="pfr"/!d' |\

                     sed "# URL einfuegen
                          s#<a href=\"#$staturl#g

                          # Alle Tags durch Marker ersetzen
                          s/<[^>]*>/@/g

                          # mehrere Leerzeichen loeschen
                          s/^[ ]*//g

                         # Sonderzeichen entfernen wegen ACTION Eintrag
                         s/[=(),]//g
                         s/&nbsp;//g

                         # Mehrfachmarker entfernen
                         s/@@*/@/g

                         s/\">//g

                         s/\" class\"pfr/@/" >$tempfile


    # http://www.f1total.com/db/drivers/stats/wins.php@Siege@
    # http://www.f1total.com/db/drivers/stats/poles.php@Pole-Positionen@
    # http://www.f1total.com/db/drivers/stats/frl.php@Schnellste Rennrunden@

    awk -v script=$0 -v shellexec=$shellexec -v menustatdetail=$menustatdetail -v stattyp=$stattyp '
                           BEGIN {
                                  FS="@"
                                  }
                                  {
                                    printf("ACTION=&%s, ( %s statdetail '\''%s'\'' %s %s ; if [ -f %s ] ; then  %s %s  ; else msgbox popup='\''Fehler bei der Ermittlung der Daten'\'' timeout=5 ;fi ) \n",$2,script,$2,$1,stattyp,menustatdetail,shellexec,menustatdetail)
                                  }
                              END {
                                   print "ENDMENU"
                                  }' $tempfile >>$menustatmain
}

# ----------------------------------------------------------------------
# Statistiken Details

statdetail () {

 stattitel="$1"
 url="$2"
 stattyp="$3"

 # http://formel1.motorsport-total.com/f1/db/drivers/details.php?d=618

 case $stattyp in
    "Fahrerstatistiken") staturl="http://formel1.motorsport-total.com/f1/db/drivers/details" ;;
      "Teamstatistiken") staturl="http://formel1.motorsport-total.com/f1/db/teams/details" ;;
     "Motorstatistiken") staturl="http://formel1.motorsport-total.com/f1/db/engines/details" ;;
 esac

     #--------------------------------------------------------
     # Menu zusammenbauen
     #--------------------------------------------------------
     echo "FONT=/share/fonts/micron_bold.ttf
     FONTSIZE=$FONTSIZE
     LINESPP=$LINESPP
     MENU=$stattitel" >$menustatdetail


     # fuer die aktuelle Strecke die URL ermitteln
     wget -O- $url | sed "# CRLF fix
                            s/$CRLF//g" |\

                     # nur die Zeile mit den Fahrerdaten
                     sed "/href=\"\.\.\/details\.php/!d" |\

                     # Jeden Fahrer in eine Zeile schreiben
                     sed 's/"><td align="right" >/\n"><td align="right" >/g' |\


                     sed "# URL einfuegen
                         s#<a href=\"../details#$staturl#g

                         # Alle Tags durch Marker ersetzen
                         s/<[^>]*>/@/g

                         # Alle Leerzeichen loeschen
                         s/[ ]//g

                         s/\">/@/g

                         # die dadurch entstandenen Mehrfachmarker entfernen
                         s/@@*/@/g

                         # Komma zw. Name und Vorname entfernen
                         s/@,/@/g

                         # restliche Kommas durch Punkt ersetzen
                         s/,/\./g

                         s/<trclass.*$//g

                         1d" >$tempfile

      # http://formel1.motorsport-total.com/f1/db/drivers/details.php?d=618@Schumacher@Michael@7@2@
      # @1@http://www.f1total.com/db/drivers/details.php?d=618@Schumacher@Michael@85@
      # @2@http://www.f1total.com/db/drivers/details.php?d=551@Prost@Alain@51@

      # @1@http://formel1.motorsport-total.com/f1/db/teams/details.php?d=159@Ferrari@205@

      awk -v script=$0  -v tuxwetter="$tuxwetter" -v libcurl="$libcurl" '
                           BEGIN {
                                  FS="@"
                                 }
              $0 ~/[a-z]/  {
                              fahrername=$5" "$4
                              #TXTHTML=Details,http://www.f1total.com/db/drivers/details.php?d=551|<table class=t1>|Grafische Statistik-Auswertungen

                              printf("ACTION=*&%s %s,%s ; %s '\''TXTHTML=Details %s,%s|<th colspan=\"2\">Stati|<!-- /PM -->'\''\n",fahrername,$6,libcurl,tuxwetter,fahrername,$3)
                              #printf("COMMENT=*%s %s\n",$6,typ)
                           }
                      END {
                            print "ENDMENU"
                          }' $tempfile >>$menustatdetail



}

#---------------------------------- Main ------------------------------

case "$1" in

            teaminfo) teaminfo $2 "$3" ;;
        makemainmenu) makemainmenu ;;
        teamkurzinfo) teamkurzinfo $2 ;;
        streckeninfo) streckeninfo $2 ;;
      streckendetail) streckendetail $2 "$3" ;;
       fahrerwertung) fahrerwertung $2 ;;
          fahrerinfo) fahrerinfo $2 "$3" ;;
         teamwertung) teamwertung $2 ;;
             ergmain) ergmain $2 ;;
           ergdetail) ergdetail $2 "$3" ;;
              sounds) sounds $2 ;;
                play) play $2 ;;
             rekorde) rekorde $2 ;;
            sprueche) sprueche $2 ;;
            picactwe) picactwe $2 ;;
               regel) regel $2 ;;
                  tv) tv $2 ;;
            statmain) statmain "$2" "$3" ;;
          statdetail) statdetail "$2" "$3" "$4" ;;


esac
