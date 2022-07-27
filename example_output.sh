ffmpeg \
-loop 1 -t 0 -i slide00.png \
-loop 1 -t 1 -i slide01.png \
-loop 1 -t 2.5 -i slide02.png \
-loop 1 -t 3.7 -i slide03.png \
-loop 1 -t 5.4 -i slide04.png \
-loop 1 -t 7.4 -i slide05.png \
-loop 1 -t 8.4 -i slide06.png \
-loop 1 -t 9.9 -i slide07.png \
-loop 1 -t 11.1 -i slide08.png \
-loop 1 -t 12.8 -i slide09.png \
-loop 1 -t 14.8 -i slide10.png \
-loop 1 -t 19.8 -i slide11.png \
-i output_audio.mp3 \
-filter_complex " \
 [1]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+0/TB[f0]; \
 [2]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+1/TB[f1]; \
 [3]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+2.5/TB[f2]; \
 [4]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+3.7/TB[f3]; \
 [5]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+5.4/TB[f4]; \
 [6]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+7.4/TB[f5]; \
 [7]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+8.4/TB[f6]; \
 [8]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+9.9/TB[f7]; \
 [9]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+11.1/TB[f8]; \
 [10]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+12.8/TB[f9]; \
 [11]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+14.8/TB[f10]; \
 [0][f0]overlay[bg1]; \
 [bg1][f1]overlay[bg2]; \
 [bg2][f2]overlay[bg3]; \
 [bg3][f3]overlay[bg4]; \
 [bg4][f4]overlay[bg5]; \
 [bg5][f5]overlay[bg6]; \
 [bg6][f6]overlay[bg7]; \
 [bg7][f7]overlay[bg8]; \
 [bg8][f8]overlay[bg9]; \
 [bg9][f9]overlay[bg10]; \
 [bg10][f10]overlay,format=yuv420p[v]" \
-map "[v]" \
-map 12:a \
-t 19.8 \
-loglevel error \
output-part1.mp4

ffmpeg \
-i output-part1.mp4 \
-ignore_loop 0 -i demo.gif \
-filter_complex " \
 [1]scale=312:625,fade=in:st=0:d=1:alpha=1,fade=out:st=7:d=1:alpha=1[f0]; \
 [0][f0]overlay=1285:300,format=yuv420p" \
-t 19.8 \
-loglevel error \
output.mp4
