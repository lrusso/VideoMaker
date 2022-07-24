# Video Maker

Creating a video using images, music and a fade in effect using ffmpeg.

## How does it work?

- The script will read the ```input_video.cfg``` file.
- The script will read the ```input_audio.cfg``` file (optional file).
- The ```input_video.cfg``` file must contain all the slides and how many seconds that slide must be displayed. For example:

```
slide001.png, 5
slide002.png, 3
slide003.png, 8.5
slide004.png, 4
slide005.png, 6.2
slide006.png, 2
```

- The ```input_audio.cfg``` file must contain all the audio files and how many millseconds of delay there will be for each audio file. For example:

```
music.mp3,0
voice001.wav, 1000
voice002.wav, 3000
voice003.wav, 5000
voice004.wav, 7000
```

## How to use it?

- Install ```ffmpeg``` on your system.
- Open the terminal.
- Go to the folder where you have your slides, audios (optionals) and configuration files (```input_video.cfg``` and ```input_audio.cfg```) are located.
- Paste the ```make.sh``` file into that folder.
- Make the script executable by running ```chmod +x make.sh```.
- Run ```./make.sh```.

## Things to know:

- Every slide must have the exact same width and height.
- At least 3 slides are required to create a video.
- To have a fade in from a black screen when the video starts, you have to create a ```slide001.png``` file that must contain a black image and then the first two lines in the ```input.cfg``` should be:
```
slide001.png, 0
slide002.png, 1
```
- For increasing the volume of an audio file, you should do:
```
ffmpeg -i voice.wav -filter:a "volume=1.5" voice_edited.wav
```
- For decreasing the volume of an audio file, you should do:
```
ffmpeg -i voice.wav -filter:a "volume=0.5" voice_edited.wav
```
