#!/bin/bash

# -------------------------------------------------------------------------------------------------------------------
# DELETING ANY PREVIOUS OUTPUT
# -------------------------------------------------------------------------------------------------------------------

# CHECKING IF THERE IS ANY PREVIOUS AUDIO OUTPUT AND DELETING THE FILE
if test -f "output_audio.mp3";
  then
    rm output_audio.mp3
fi

# CHECKING IF THERE IS ANY PREVIOUS VIDEO OUTPUT PART 1 AND DELETING THE FILE
if test -f "output-part1.mp4";
  then
    rm output-part1.mp4
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
        field1=`echo $field1 | sed 's/ *$//g'`
        field2=`echo $field2 | sed 's/ *$//g'`

        echo "-i "$field1" \\" >>output_audio.sh
    done < <(grep "" input_audio.cfg)

    # WRITING THE AUDIO FILTER PARAMETER
    echo "-filter_complex \"\\" >>output_audio.sh

    # PASSING EVERY DELAY OF EVERY AUDIO
    while IFS=, read -r field1 field2
      do
        field1=`echo $field1 | sed 's/ *$//g'`
        field2=`echo $field2 | sed 's/ *$//g'`

        audioDelayInMS=`echo $field2 1000 | awk '{print $1 * $2}'`
        audioCounter1=$((audioCounter1+1))
        echo "["$audioCounter1"]adelay="$audioDelayInMS"|"$audioDelayInMS"[a"$audioCounter1"]; \\" >>output_audio.sh
    done < <(grep "" input_audio.cfg)

    # RESETTING THE AUDIO COUNTER
    audioCounter1=-1

    # DECLARING ALL THE AUDIOS
    while IFS=, read -r field1 field2
      do
        field1=`echo $field1 | sed 's/ *$//g'`
        field2=`echo $field2 | sed 's/ *$//g'`

        audioCounter1=$((audioCounter1+1))
        echo "[a"$audioCounter1"]\\" >>output_audio.sh
    done < <(grep "" input_audio.cfg)

    # UPDATING THE AUDIO CONTAINER
    audioCounter1=$((audioCounter1+1))

    # SETTING ALL THE AUDIOS THAT WILL BE USED
    echo "amix=inputs=$audioCounter1 \\" >>output_audio.sh

    # WORKAROUND FOR THE AMIX FILTERS WHEN TRIES TO IMPLEMENT A FADE IN EFFECT IN THE NEW AUDIO
    # AND WHEN MODIFIED THE VOLUME OF THE NEW AUDIO.
    echo ":duration=first:dropout_transition=99999999,volume=2.1\" \\" >>output_audio.sh

    # SHOWING ONLY ERRORS (IF ANY) DURING THE SCRIPT EXECUTION
    echo "-loglevel error \\" >>output_audio.sh

    # SETTING THE OUTPUT AUDIO FILENAME
    echo "output_audio.mp3" >>output_audio.sh

    # MAKING THE OUTPUT AUDIO SCRIPT EXECUTABLE
    chmod +x output_audio.sh

    # RUNNING THE OUTPUT AUDIO SCRIPT
    ./output_audio.sh

fi

# -------------------------------------------------------------------------------------------------------------------
# CREATING THE SCRIPT FOR MAKING THE VIDEO FILE WITH IMAGES AND SOUNDS
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
    field1=`echo $field1 | sed 's/ *$//g'`
    field2=`echo $field2 | sed 's/ *$//g'`

    videoTimeValue=`echo $videoDuration $field2 | awk '{print $1 + $2}'`
    videoDuration=$videoTimeValue
    videoCounter1=$((videoCounter1+1))
    echo "-loop 1 -t "$videoTimeValue" -i "$field1" \\" >>output.sh
done < <(grep "" input_video.cfg)

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
    field1=`echo $field1 | sed 's/ *$//g'`
    field2=`echo $field2 | sed 's/ *$//g'`

    if ((videoCounter2>0))
      then
        echo " ["$videoCounter2"]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+"$videoSlideDuration"/TB[f"$((videoCounter2-1))"]; \\" >>output.sh
    fi
    videoTimeValue=`echo $videoSlideDuration $field2 | awk '{print $1 + $2}'`
    videoSlideDuration=$videoTimeValue
    videoCounter2=$((videoCounter2+1))
done < <(grep "" input_video.cfg)

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

# SHOWING ONLY ERRORS (IF ANY) DURING THE SCRIPT EXECUTION
echo "-loglevel error \\" >>output.sh

# SETTING THE OUTPUT VIDEO FILENAME
echo "output-part1.mp4" >>output.sh

# -------------------------------------------------------------------------------------------------------------------
# CREATING THE SCRIPT FOR ADDING THE GIF FILES TO THE VIDEO FILE
# -------------------------------------------------------------------------------------------------------------------

let gifCounter1=1
let gifCounter2=0

# CHECKING IF GIFS ARE GOING TO BE ADDED TO THE VIDEO
if test -f "input_gifs.cfg";
  then

    # ADDING A BREAKLINE TO THE SCRIPT
    echo "" >>output.sh

    # ADDING A SECOND CALL TO THE FFMPEG THAT WILL ADD THE GIFS TO THE VIDEO FILE
    echo "ffmpeg \\" >>output.sh

    # SETTING THE INPUT FILE
    echo "-i output-part1.mp4 \\" >>output.sh

    # PASSING ALL THE GIF FILES
    while IFS=, read -r field1 field2 field3 field4 field5 field6 field7 field8
      do
        field1=`echo $field1 | sed 's/ *$//g'`
        field2=`echo $field2 | sed 's/ *$//g'`
        field3=`echo $field3 | sed 's/ *$//g'`
        field4=`echo $field4 | sed 's/ *$//g'`
        field5=`echo $field5 | sed 's/ *$//g'`
        field6=`echo $field6 | sed 's/ *$//g'`
        field7=`echo $field7 | sed 's/ *$//g'`
        field8=`echo $field8 | sed 's/ *$//g'`

        echo "-ignore_loop "$field2" -i "$field1" \\" >>output.sh
    done < <(grep "" input_gifs.cfg)

    # WRITING THE GIF FILTER PARAMETER
    echo "-filter_complex \" \\" >>output.sh

    # SETTING ALL THE FADES IN AND OUT FOR EACH GIF FILE
    while IFS=, read -r field1 field2 field3 field4 field5 field6 field7 field8
      do
        field1=`echo $field1 | sed 's/ *$//g'`
        field2=`echo $field2 | sed 's/ *$//g'`
        field3=`echo $field3 | sed 's/ *$//g'`
        field4=`echo $field4 | sed 's/ *$//g'`
        field5=`echo $field5 | sed 's/ *$//g'`
        field6=`echo $field6 | sed 's/ *$//g'`
        field7=`echo $field7 | sed 's/ *$//g'`
        field8=`echo $field8 | sed 's/ *$//g'`

        echo " ["$gifCounter1"]scale="$field3":"$field4",fade=in:st="$field7":d=1:alpha=1,fade=out:st="$field8":d=1:alpha=1[f"$((gifCounter1-1))"]; \\" >>output.sh
        gifCounter1=$((gifCounter1+1))
    done < <(grep "" input_gifs.cfg)

    # SETTING ALL THE ELEMENTS THAT WILL BE ADDED DURING THE FFMPEG EXECUTION
    while IFS=, read -r field1 field2 field3 field4 field5 field6 field7 field8
      do
        field1=`echo $field1 | sed 's/ *$//g'`
        field2=`echo $field2 | sed 's/ *$//g'`
        field3=`echo $field3 | sed 's/ *$//g'`
        field4=`echo $field4 | sed 's/ *$//g'`
        field5=`echo $field5 | sed 's/ *$//g'`
        field6=`echo $field6 | sed 's/ *$//g'`
        field7=`echo $field7 | sed 's/ *$//g'`
        field8=`echo $field8 | sed 's/ *$//g'`

        if (($gifCounter2==0 && $gifCounter1==2));
          then
            echo " [0][f0]overlay="$field5":"$field6",format=yuv420p\" \\" >>output.sh
          else
            if (($gifCounter2==0));
              then
                echo " [0][f0]overlay="$field5":"$field6"[bg1]; \\" >>output.sh
              else
                if (($gifCounter2==$gifCounter1-2))
                  then
                    echo " [bg"$gifCounter2"][f"$gifCounter2"]overlay="$field5":"$field6",format=yuv420p\" \\" >>output.sh
                  else
                    echo " [bg"$gifCounter2"][f"$gifCounter2"]overlay="$field5":"$field6"[bg"$((gifCounter2+1))"]; \\" >>output.sh
                fi
            fi
          fi
        gifCounter2=$((gifCounter2+1))
    done < <(grep "" input_gifs.cfg)

    # SETTING THE VIDEO DURATION
    echo "-t "$videoDuration" \\" >>output.sh

    # SHOWING ONLY ERRORS (IF ANY) DURING THE SCRIPT EXECUTION
    echo "-loglevel error \\" >>output.sh

    # SETTING THE OUTPUT VIDEO FILENAME
    echo "output.mp4" >>output.sh
fi

# -------------------------------------------------------------------------------------------------------------------
# ADDING THE GIF FILES TO THE VIDEO FILE
# -------------------------------------------------------------------------------------------------------------------

# MAKING THE OUTPUT VIDEO SCRIPT EXECUTABLE
chmod +x output.sh

# RUNNING THE VIDEO MAKER SCRIPT
./output.sh

# CHECKING IF GIF FILES WERE NOT ADDED TO THE VIDEO AND RENAMING OUTPUT VIDEO FILE
if ! test -f "input_gifs.cfg";
  then
    mv output-part1.mp4 output.mp4
fi

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

# DELETING THE VIDEO OUTPUT PART 1 FILE
if test -f "output-part1.mp4";
  then
    rm output-part1.mp4
fi

# DELETING THE VIDEO OUTPUT SCRIPT
if test -f "output.sh";
  then
    rm output.sh
fi
