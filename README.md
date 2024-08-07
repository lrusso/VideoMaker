# VideoMaker

Creating a video using static images, GIFs, music and a fade in effect using ffmpeg.

## How to use the Bash version?

- Install ```ffmpeg``` on your system.
- Open the terminal.
- Unzip the sample ```video.zip``` file.
- Paste the ```make.sh``` file into that folder.
- Make the script executable by running ```chmod +x make.sh```
- Run ```./make.sh```.
- The  ```output.mp4``` file will be created.

## How to use the JavaScript version?

- Install ```ffmpeg``` on your system.
- Open the terminal.
- Unzip the sample ```video.zip``` file.
- Paste the ```make.js``` file into that folder.
- Run ```node make```.
- The  ```output.mp4``` file will be created.

## How does it work?

- The script will read the ```input_video.cfg``` file.
- The script will read the ```input_audio.cfg``` file (optional file).
- The script will read the ```input_gifs.cfg``` file (optional file).
- The ```input_video.cfg``` file must contain all the slides and how many seconds that slide must be displayed. For example:

```
slide001.png, 5
slide002.png, 3
slide003.png, 8.5
slide004.png, 4
slide005.png, 6.2
slide006.png, 2
```

- The ```input_audio.cfg``` file must contain all the audio files and how many seconds of delay there will be for each audio file. For example:

```
music.mp3,0
voice001.wav, 1.5
voice002.wav, 3
voice003.wav, 5
voice004.wav, 7.8
```

- The ```input_gifs.cfg``` file must contain all the gif files that are going to be displayed during the video. For example:

```
gif001.gif, 0, 150, 150, 256, 256, 3, 5
gif002.gif, 0, 300, 300, 256, 256, 6, 8
gif003.gif, 0, 450, 450, 256, 256, 9, 10
```

The required values for each row are:

* ```filename``` (string)
* ```ignore_loop``` (0 or 1)
* ```x``` (integer)
* ```y``` (integer)
* ```width``` (integer)
* ```height``` (integer)
* ```fade_in_after``` (seconds)
* ```fade_out_after``` (seconds)

## Things to know:

- Every slide (image file) must have the exact same width and height.
- The created video will have the same resolution of the slides.
- To have a fade in from a black screen when the video starts, you have to create a ```slide001.png``` file that must contain a black image and then the first two lines in the ```input_video.cfg``` should be:
```
slide001.png, 0
slide002.png, 1
```
- A workflow for GitHub Actions was created in this repository that shows how to create a video and attach it to the job as an artifact.

## Useful ffmpeg commands

```
# Increasing the volume of an audio file:
ffmpeg -i voice.wav -filter:a "volume=1.5" voice_edited.wav

# Decreasing the volume of an audio file:
ffmpeg -i voice.wav -filter:a "volume=0.5" voice_edited.wav

# Changing the kbps of an audio file:
ffmpeg -i voice.wav -b:a 128k voice_edited.wav

# Converting an audio file from stereo to mono:
ffmpeg -i voice.wav -ac 1 voice_edited.wav

# Changing the sample rate of an audio file:
ffmpeg -i voice.wav -ar 22050 voice_edited.wav

# Cutting the first 20 seconds of an audio/video file:
ffmpeg -i voice.wav -ss 20 voice_edited.wav

# Cutting the first 20 seconds and getting only the next 5 seconds of an audio/video file:
ffmpeg -i voice.wav -ss 20 -t 5 voice_edited.wav

# Getting the first 5 seconds of an audio/video file:
ffmpeg -i voice.wav -t 5 voice_edited.wav

# Adding a 5 seconds fade in to an audio file:
ffmpeg -i music.mp3 -af "afade=t=in:st=0:d=5" music_edited.mp3

# Adding a 5 seconds fade out after 30 seconds to an audio file:
ffmpeg -i music.mp3 -af "afade=t=out:st=30:d=5" music_edited.mp3

# Converting a MP4 file to a GIF file without scaling:
ffmpeg -i video.mp4 -filter_complex 'fps=24,scale=-1:-1:flags=lanczos,split [o1] [o2];[o1] palettegen [p]; [o2] fifo [o3];[o3] [p] paletteuse' video.gif

# Converting a MP4 file to a scaled GIF file (320px width):
ffmpeg -i video.mp4 -filter_complex 'fps=24,scale=320:-1:flags=lanczos,split [o1] [o2];[o1] palettegen [p]; [o2] fifo [o3];[o3] [p] paletteuse' video.gif

# Cropping a MP4 file that has a 1080x2316 resolution to a 1080x2030 video file using a Y offset of 110 pixels:
ffmpeg -i video.mp4 -filter:v "crop=1080:2030:0:110" -c:a copy video_edited.mp4
```
