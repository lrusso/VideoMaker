#!/bin/bash

let counter1=0
let counter2=0
let slideduration=0
let videoduration=0
let musicEnabled=0
let timeValue=0

echo "ffmpeg \\" >output.sh


while IFS=, read -r field1 field2
  do
    timeValue=`echo $videoduration+$field2 | awk '{print $1 + $2}'`
    videoduration=$timeValue
    counter1=$((counter1+1))
    echo "-loop 1 -t "$timeValue" -i "$field1" \\" >>output.sh
done < input.cfg



if test -f "music.mp3";
  then
    musicEnabled=$((musicEnabled+1))
    echo "-i music.mp3 \\" >>output.sh
fi


echo "-filter_complex \" \\" >>output.sh


while IFS=, read -r field1 field2
  do
    if ((counter2>0))
      then
        echo " ["$counter2"]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+"$slideduration"/TB[f"$((counter2-1))"]; \\" >>output.sh
    fi
    timeValue=`echo $slideduration+$field2 | awk '{print $1 + $2}'`
    slideduration=$timeValue
    counter2=$((counter2+1))
done < input.cfg


for (( i=0; i<=$counter1-2; i++ ))
  do
    if (($i==0));
      then
        echo " [0][f0]overlay[bg1]; \\" >>output.sh
      else
        if (($i==$counter1-2))
          then
            echo " [bg"$i"][f"$i"]overlay,format=yuv420p[v]\" \\" >>output.sh
          else
            echo " [bg"$i"][f"$i"]overlay[bg"$((i+1))"]; \\" >>output.sh
         fi
      fi
done


echo "-map \"[v]\" \\" >>output.sh


if ((musicEnabled>0))
  then
   echo "-map "$((counter1))":a \\" >>output.sh
fi


echo "-t "$videoduration" \\" >>output.sh
echo "output.mp4" >>output.sh


if test -f "output.mp4";
  then
    rm output.mp4
fi


chmod +x output.sh
./output.sh