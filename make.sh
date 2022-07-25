#!/bin/bash

# -------------------------------------------------------------------------------------------------------------------
# DELETING ANY PREVIOUS OUTPUT
# -------------------------------------------------------------------------------------------------------------------

# CHECKING IF THERE IS ANY PREVIOUS AUDIO OUTPUT AND DELETING THE FILE
if test -f "output_audio.mp3";
  then
    rm output_audio.mp3
fi

# CHECKING IF THERE IS ANY PREVIOUS VIDEO OUTPUT AND DELETING THE FILE
if test -f "output.mp4";
  then
    rm output.mp4
fi

# -------------------------------------------------------------------------------------------------------------------
# CREATING THE AUDIO FILE
# -------------------------------------------------------------------------------------------------------------------

let audioCounter1=-1
let audioDelayInMS=-1

# CHECKING IF THERE IS AN AUDIO CONFIGURATION
if test -f "input_audio.cfg";
  then

    # WRITING THE FILE THAT WILL BE CALLING THE FFMPEG COMMAND FOR CREATING THE AUDIO FILE
    echo "ffmpeg \\" >output_audio.sh

    # PASSING ALL THE AUDIO FILES AS INPUT PARAMETERS
    while IFS=, read -r field1 field2
      do
        echo "-i "$field1" \\" >>output_audio.sh
    done < input_audio.cfg

    # WRITING THE AUDIO FILTER PARAMETER
    echo "-filter_complex \"\\" >>output_audio.sh

    # PASSING EVERY DELAY OF EVERY AUDIO
    while IFS=, read -r field1 field2
      do
        audioDelayInMS=`echo $field2 1000 | awk '{print $1 * $2}'`
        audioCounter1=$((audioCounter1+1))
        echo "["$audioCounter1"]adelay="$audioDelayInMS"|"$audioDelayInMS"[a"$audioCounter1"]; \\" >>output_audio.sh
    done < input_audio.cfg

    # RESETTING THE AUDIO COUNTER
    audioCounter1=-1

    # DECLARING ALL THE AUDIOS
    while IFS=, read -r field1 field2
      do
        audioCounter1=$((audioCounter1+1))
        echo "[a"$audioCounter1"]\\" >>output_audio.sh
    done < input_audio.cfg

    # UPDATING THE AUDIO CONTAINER
    audioCounter1=$((audioCounter1+1))

    # SETTING ALL THE AUDIOS THAT WILL BE USED
    echo "amix=inputs=$audioCounter1 \\" >>output_audio.sh

    # WORKAROUND FOR THE AMIX FILTERS WHEN TRIES TO IMPLEMENT A FADE IN EFFECT IN THE NEW AUDIO
    # AND WHEN MODIFIED THE VOLUME OF THE NEW AUDIO.
    echo ":duration=first:dropout_transition=99999999,volume=2.1\" \\" >>output_audio.sh

    # SETTING THE OUTPUT AUDIO FILENAME
    echo "output_audio.mp3" >>output_audio.sh

    # MAKING THE OUTPUT AUDIO SCRIPT EXECUTABLE
    chmod +x output_audio.sh

    # RUNNING THE OUTPUT AUDIO SCRIPT
    ./output_audio.sh

fi

# -------------------------------------------------------------------------------------------------------------------
# CREATING THE VIDEO FILE
# -------------------------------------------------------------------------------------------------------------------

let videoCounter1=0
let videoCounter2=0
let videoSlideDuration=0
let videoDuration=0
let videoAudioEnabled=0
let videoTimeValue=0

# WRITING THE FILE THAT WILL BE CALLING THE FFMPEG COMMAND FOR CREATING THE VIDEO FILE
echo "ffmpeg \\" >output.sh

# PASSING ALL THE IMAGE FILES
while IFS=, read -r field1 field2
  do
    videoTimeValue=`echo $videoDuration+$field2 | awk '{print $1 + $2}'`
    videoDuration=$videoTimeValue
    videoCounter1=$((videoCounter1+1))
    echo "-loop 1 -t "$videoTimeValue" -i "$field1" \\" >>output.sh
done < input_video.cfg

# CHECKING IF THERE IS AN AUDIO OUTPUT CREATED AND USING IT
if test -f "output_audio.mp3";
  then
    videoAudioEnabled=$((videoAudioEnabled+1))
    echo "-i output_audio.mp3 \\" >>output.sh
fi

# ADDING THE VIDEO FILTER PARAMETER
echo "-filter_complex \" \\" >>output.sh

# PASSING ALL THE FADE IN EFFECT FOR EVERY SLIDE
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

# DECLARING ALL THE SLIDES
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

# ENABLING THE VIDEO MAP
echo "-map \"[v]\" \\" >>output.sh

# CHECKING IF THERE IS AUDIO AND ENABLING THE AUDIO MAP
if ((videoAudioEnabled>0))
  then
   echo "-map "$((videoCounter1))":a \\" >>output.sh
fi

# SETTING THE VIDEO DURATION
echo "-t "$videoDuration" \\" >>output.sh

# SETTING THE OUTPUT VIDEO FILENAME
echo "output.mp4" >>output.sh

# MAKING THE OUTPUT VIDEO SCRIPT EXECUTABLE
chmod +x output.sh
./output.sh

# DELETING THE AUDIO OUTPUT SCRIPT
if test -f "output_audio.sh";
  then
    rm output_audio.sh
fi

# DELETING THE AUDIO OUTPUT FILE
if test -f "output_audio.mp3";
  then
    rm output_audio.mp3
fi

# DELETING THE VIDEO OUTPUT SCRIPT
if test -f "output.sh";
  then
    rm output.sh
fi
