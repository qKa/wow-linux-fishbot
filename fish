#!/bin/bash
##by eek, schnellschuss unter gpl v3
## run sndtest = ./sndpeek --nodisplay --print and beginn fishing to see the soundnumbers
##configure in fishconfig

. ./fish.config

## start
function coordinaten ()
{
	echo "[ $now ] take screenshot"
	nice -n 19 scrot /tmp/fish.png
	## Test, funktionierte aber bescheiden
	#if   [ -n "$var" ]
	#then
	#let f=$x+15
	#let g=$y+15
	#convert -draw "fill white circle $x,$y $f,$g" -geometry 1280x800 /tmp/temp.png /tmp/fish.png 2>&1
	#echo "[ $now ] convert Image"
	#else
	#echo "[ $now ] cant convert string"
	#fi
	x=$(visgrep -t $tolleranz /tmp/fish.png $pat | sed 's/,/\t/' | awk '{print $1}'| tail -n1)
	y=$(visgrep -t $tolleranz /tmp/fish.png $pat | sed 's/,/\t/' | awk '{print $2}'| tail -n1)
	xte "mousemove $x $y" ; echo "[ $now ] move mouse to $x $y"
	count=0
}

function auswerfen ()
{
	killall sndpeek 2>&1; rm $peeklog 2>&1; echo "[ $now ] files removed"
	sleep 1s
	xte 'keydown m' ; sleep 0.2 ; xte 'keyup m'
	($snd --nodisplay --print > $peeklog &)
	xte 'mousemove 20 120'
	sleep 1s
}

function signal()
{
	killall sndpeek 2>&1; rm $peeklog 2>&1; echo "[ $now ] files removed"
	echo "[ $now ] kill fishbot ~ $fishcount fishes looted" ; break ##ob das echo so kerrekt is xD
}

trap signal SIGINT

## Start

	sleep 3s 
	xte 'keydown m' ; xte 'keyup m'
	xte 'mousemove 20 120'
	sleep 2s
	count=0
	fishcount=0
	coordinaten
	($snd --nodisplay --print > $peeklog &)

## Los gehts

while true;
	do
	#Lauschen
	now=$(date +"%H-%M-%S")
	var=$(cat $peeklog | awk '{print $1}' | tail -n1 | cut -c 1-3 | sed -e 's/[.]//g')

## Keine Coordinaten

if [ "$x" = "" ]
	then
	echo "[ $now ] invalid coordinates"
	auswerfen
	sleep 2s
	coordinaten
fi

## Grundschleife

if   [ -z "$var" ] || [ $var -lt $soundmin ]
	then
	echo "[ $now ] string error, calculating new var"
	var=$(( $sound-3 ))
fi

if  [ $sound -lt $var ]
	then
	echo "[ $now ] $count - sound: $var"

## Nix angebissen

if [ "$count" = "$counter" ]
     then
	echo "[ $now ] no fish found"
	xte 'mouseclick 3'
	sleep 1.5s
	auswerfen
	coordinaten
fi
(( count += 1 ))
sleep 1s

else
	xte 'mouseclick 3'
	echo -e "[ $now ] \033[1;31mFish number ~ $fishcount found\033[0m"
	echo "[ $now ] sound: $var - limit was $sound"
	(( fishcount += 1 ))
	timer=$(date +"%H-%M")
	if [ "$timer" = "$breaktime" ]
	then
	echo "[ $now ] killing Bot ~ $fishcount fishes looted"
	xte 'keydown m' ; xte 'keyup m'
	sleep 1m
	killall Wow.exe
	sudo halt
	break
	fi
	auswerfen
	sleep $wait
	coordinaten
fi
done
