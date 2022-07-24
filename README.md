# Video Maker

Creating a video using images, music and a fade in effect using ffmpeg.

## How does it work?

- The script will read the ```input.cfg``` file.
- The ```input.cfg``` file must contain all the slides and how many seconds that slide must be displayed. For example:

```
slide001.png, 5
slide002.png, 3
slide003.png, 8.5
slide004.png, 4
slide005.png, 6.2
slide006.png, 2
```

- The music is optional, if the music file ```music.mp3``` doesn't exists, the video will be created anyway.

## How to use it?

- Install ```ffmpeg``` on your system.
- Open the terminal.
- Go to the folder where you have your slides, music (optional) and ```input.cfg``` file.
- Paste the ```make.sh``` file into that folder.
- Make the script executable by running ```chmod +x make.sh```.
- Run ```./make.sh```.

## Things to know:

- Every slide must have the exact same width and height.
- At least 3 slides are required to create a video.
- If you want to have a fade in from a black screen when the video starts, you have to create a ```slide001.png``` file that must contain a black image and then the first two lines in the ```input.cfg``` should be:
```
slide001.png, 0
slide002.png, 0
```
