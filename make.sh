#!/bin/bash

# creating the audio file

let audioCounter1=-1
let audioDelayInMS=-1

if test -f "output.mp3";
  then
    rm output.mp3
fi

if test -f "input_audio.cfg";
  then
    echo "ffmpeg \\" >output_audio.sh

    while IFS=, read -r field1 field2
      do
        echo "-i "$field1" \\" >>output_audio.sh
    done < input_audio.cfg

    echo "-filter_complex \"\\" >>output_audio.sh

    while IFS=, read -r field1 field2
      do
        audioDelayInMS=`echo $field2 1000 | awk '{print $1 * $2}'`
        audioCounter1=$((audioCounter1+1))
        echo "["$audioCounter1"]adelay="$audioDelayInMS"|"$audioDelayInMS"[a"$audioCounter1"]; \\" >>output_audio.sh
    done < input_audio.cfg

    audioCounter1=-1

    while IFS=, read -r field1 field2
      do
        audioCounter1=$((audioCounter1+1))
        echo "[a"$audioCounter1"]\\" >>output_audio.sh
    done < input_audio.cfg

    audioCounter1=$((audioCounter1+1))

    echo "amix=inputs=$audioCounter1 \\" >>output_audio.sh


    echo ":duration=first:dropout_transition=99999999,volume=2.1\" \\" >>output_audio.sh


    echo "output_audio.mp3" >>output_audio.sh


    chmod +x output_audio.sh
    ./output_audio.sh

fi

# creating the video file with the audio file (if exists)

let videoCounter1=0
let videoCounter2=0
let videoSlideDuration=0
let videoDuration=0
let videoMusicEnabled=0
let videoTimeValue=0



echo "ffmpeg \\" >output.sh


while IFS=, read -r field1 field2
  do
    videoTimeValue=`echo $videoDuration+$field2 | awk '{print $1 + $2}'`
    videoDuration=$videoTimeValue
    videoCounter1=$((videoCounter1+1))
    echo "-loop 1 -t "$videoTimeValue" -i "$field1" \\" >>output.sh
done < input_video.cfg


if test -f "output_audio.mp3";
  then
    videoMusicEnabled=$((videoMusicEnabled+1))
    echo "-i output_audio.mp3 \\" >>output.sh
fi


echo "-filter_complex \" \\" >>output.sh


while IFS=, read -r field1 field2
  do
    if ((videoCounter2>0))
      then
        echo " ["$videoCounter2"]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+"$videoSlideDuration"/TB[f"$((videoCounter2-1))"]; \\" >>output.sh
    fi
    videoTimeValue=`echo $videoSlideDuration+$field2 | awk '{print $1 + $2}'`
    videoSlideDuration=$videoTimeValue
    videoCounter2=$((videoCounter2+1))
done < input_video.cfg


for (( i=0; i<=$videoCounter1-2; i++ ))
  do
    if (($i==0));
      then
        echo " [0][f0]overlay[bg1]; \\" >>output.sh
      else
        if (($i==$videoCounter1-2))
          then
            echo " [bg"$i"][f"$i"]overlay,format=yuv420p[v]\" \\" >>output.sh
          else
            echo " [bg"$i"][f"$i"]overlay[bg"$((i+1))"]; \\" >>output.sh
         fi
      fi
done


echo "-map \"[v]\" \\" >>output.sh


if ((videoMusicEnabled>0))
  then
   echo "-map "$((videoCounter1))":a \\" >>output.sh
fi


echo "-t "$videoDuration" \\" >>output.sh
echo "output.mp4" >>output.sh


if test -f "output.mp4";
  then
    rm output.mp4
fi


chmod +x output.sh
./output.sh


if test -f "output_audio.sh";
  then
    rm output_audio.sh
fi

if test -f "output_audio.mp3";
  then
    rm output_audio.mp3
fi

if test -f "output.sh";
  then
    rm output.sh
fi
