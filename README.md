# Video Maker

Creating a video using static images, GIFs, music and a fade in effect using ffmpeg.

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
gif001.gif, 0, 200, 200, 100, 100, 3, 5
gif002.gif, 0, 200, 200, 300, 300, 6, 8
gif003.gif, 0, 200, 200, 500, 500, 9, 10
```

The required data for each row is: ```filename``` (string), ```ignore_loop``` (0 or 1), ```width``` (integer), ```height``` (integer), ```x``` (integer), ```y``` (integer), ```fade_in_after``` (seconds) and ```fade_out_after``` (seconds).

## How to use it?

- Install ```ffmpeg``` on your system.
- Open the terminal.
- Go to the folder where you have your slides, audios (optional), GIFs (optional) and configuration files (```input_video.cfg``` and the optional ```input_audio.cfg``` and ```input_gifs.cfg```) are located.
- Paste the ```make.sh``` file into that folder.
- Make the script executable by running ```chmod +x make.sh```
- Run ```./make.sh```.
- The  ```output.mp4``` file will be created.

## Things to know:

- Every slide (image file) must have the exact same width and height.
- At least 3 slides are required to create a video.
- The created video will have the same resolution of the slides.
- To have a fade in from a black screen when the video starts, you have to create a ```slide001.png``` file that must contain a black image and then the first two lines in the ```input_video.cfg``` should be:
```
slide001.png, 0
slide002.png, 1
```
- For increasing the volume of an audio file, you can do:
```
ffmpeg -i voice.wav -filter:a "volume=1.5" voice_edited.wav
```
- For decreasing the volume of an audio file, you can do:
```
ffmpeg -i voice.wav -filter:a "volume=0.5" voice_edited.wav
```
- For changing the kbps of an audio file:
```
ffmpeg -i voice.wav -b:a 128k voice_edited.wav
```
- For converting an audio file from stereo to mono:
```
ffmpeg -i voice.wav -ac 1 voice_edited.wav
```
- For changing the sample rate of an audio file:
```
ffmpeg -i voice.wav -ar 22050 voice_edited.wav
```
- For cutting the first 20 seconds of an audio file:
```
ffmpeg -i voice.wav -ss 20 voice_edited.wav
```
- For cutting the first 20 seconds and getting only the next 5 seconds of an audio file:
```
ffmpeg -i voice.wav -ss 20 -t 5 voice_edited.wav
```
