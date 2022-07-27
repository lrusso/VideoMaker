ffmpeg \
-i music.mp3 \
-i voice001.wav \
-i voice002.wav \
-i voice003.wav \
-i voice004.wav \
-i voice005.wav \
-filter_complex "\
[0]adelay=0|0[a0]; \
[1]adelay=9000|9000[a1]; \
[2]adelay=10000|10000[a2]; \
[3]adelay=11300|11300[a3]; \
[4]adelay=12500|12500[a4]; \
[5]adelay=14800|14800[a5]; \
[a0]\
[a1]\
[a2]\
[a3]\
[a4]\
[a5]\
amix=inputs=6 \
:duration=first:dropout_transition=99999999,volume=2.1" \
-loglevel error \
output_audio.mp3
