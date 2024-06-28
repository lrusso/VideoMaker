const fs = require("fs")
const { execSync } = require("child_process")

function deleteFileIfExists(filePath) {
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath)
  }
}

// -------------------------------------------------------------------------------------------------------------------
// DELETING ANY PREVIOUS OUTPUT
// -------------------------------------------------------------------------------------------------------------------

deleteFileIfExists("output_audio.mp3")
deleteFileIfExists("output_part1.mp4")
deleteFileIfExists("output.mp4")

// -------------------------------------------------------------------------------------------------------------------
// CREATING THE AUDIO FILE
// -------------------------------------------------------------------------------------------------------------------

let audioCounter1 = -1
let audioDelayInMS = -1

if (fs.existsSync("input_audio.cfg")) {
  let outputAudioSh = "ffmpeg \\\n"

  const audioConfig = fs.readFileSync("input_audio.cfg", "utf8").trim().split("\n")

  audioConfig.forEach((line) => {
    const [field1, field2] = line.split(",").map((field) => field.trim())
    outputAudioSh += `-i ${field1} \\\n`
  })

  outputAudioSh += '-filter_complex "\\\n'

  audioConfig.forEach((line) => {
    const [field1, field2] = line.split(",").map((field) => field.trim())
    audioDelayInMS = field2 * 1000
    audioCounter1++
    outputAudioSh += `[${audioCounter1}]adelay=${audioDelayInMS}|${audioDelayInMS}[a${audioCounter1}]; \\\n`
  })

  audioCounter1 = -1

  audioConfig.forEach((line) => {
    audioCounter1++
    outputAudioSh += `[a${audioCounter1}]\\\n`
  })

  audioCounter1++

  outputAudioSh += `amix=inputs=${audioCounter1} \\\n`
  outputAudioSh += ':duration=first:dropout_transition=99999999,volume=2.1" \\\n'
  outputAudioSh += "-loglevel error \\\n"
  outputAudioSh += "output_audio.mp3"

  execSync(outputAudioSh)
}

// -------------------------------------------------------------------------------------------------------------------
// CREATING THE VIDEO FILE
// -------------------------------------------------------------------------------------------------------------------

let videoCounter1 = 0
let videoCounter2 = 0
let videoCounter3 = 0
let videoSlideDuration = 0
let videoDuration = 0
let videoAudioEnabled = 0
let videoTimeValue = 0

let outputSh = "ffmpeg \\\n"
const videoConfig = fs.readFileSync("input_video.cfg", "utf8").trim().split("\n")

videoConfig.forEach((line) => {
  const [field1, field2] = line.split(",").map((field) => field.trim())
  videoTimeValue = videoDuration + parseInt(field2, 10)
  videoDuration = videoTimeValue
  videoCounter1++
  outputSh += `-loop 1 -t ${videoTimeValue} -i ${field1} \\\n`
})

if (fs.existsSync("output_audio.mp3")) {
  videoAudioEnabled++
  outputSh += "-i output_audio.mp3 \\\n"
}

videoConfig.forEach((line) => {
  const [field1, field2] = line.split(",").map((field) => field.trim())

  if (videoCounter2 === 1) {
    outputSh += '-filter_complex " \\\n'
  }

  if (videoCounter2 > 0) {
    outputSh += ` [${videoCounter2}]format=yuv420p,fade=d=1:t=in:alpha=1,setpts=PTS-STARTPTS+${videoSlideDuration}/TB[f${videoCounter2 - 1}]; \\\n`
  }

  videoSlideDuration += parseInt(field2, 10)
  videoCounter2++
})

videoConfig.forEach((line) => {
  if (videoCounter3 < videoCounter1 - 1) {
    if (videoCounter3 === 0 && videoCounter1 === 2) {
      outputSh += ' [0][f0]overlay,format=yuv420p[v]" \\\n'
    } else if (videoCounter3 === 0) {
      outputSh += " [0][f0]overlay[bg1]; \\\n"
    } else if (videoCounter3 === videoCounter1 - 2) {
      outputSh += ` [bg${videoCounter3}][f${videoCounter3}]overlay,format=yuv420p[v]" \\\n`
    } else {
      outputSh += ` [bg${videoCounter3}][f${videoCounter3}]overlay[bg${videoCounter3 + 1}]; \\\n`
    }
  }
  videoCounter3++
})

if (videoCounter2 > 1) {
  outputSh += '-map "[v]" \\\n'
  if (videoAudioEnabled > 0) {
    outputSh += `-map ${videoCounter1}:a \\\n`
  }
}

outputSh += `-t ${videoDuration} \\\n`
outputSh += "-loglevel error \\\n"
outputSh += "output_part1.mp4"

// -------------------------------------------------------------------------------------------------------------------
// ADDING GIF TO THE VIDEO FILE
// -------------------------------------------------------------------------------------------------------------------

if (fs.existsSync("input_gifs.cfg")) {
  let gifCounter1 = 1
  let gifCounter2 = 0
  const gifConfig = fs.readFileSync("input_gifs.cfg", "utf8").trim().split("\n")

  outputSh += "\nffmpeg \\\n"
  outputSh += "-i output_part1.mp4 \\\n"

  gifConfig.forEach((line) => {
    const fields = line.split(",").map((field) => field.trim())
    outputSh += `-ignore_loop ${fields[1]} -i ${fields[0]} \\\n`
  })

  outputSh += '-filter_complex " \\\n'

  gifConfig.forEach((line) => {
    const fields = line.split(",").map((field) => field.trim())
    outputSh += ` [${gifCounter1}]setpts=PTS-STARTPTS+${fields[6]}/TB,scale=${fields[4]}:${fields[5]},fade=in:st=${fields[6]}:d=1:alpha=1,fade=out:st=${fields[7]}:d=1:alpha=1[f${gifCounter1 - 1}]; \\\n`
    gifCounter1++
  })

  gifConfig.forEach((line) => {
    const fields = line.split(",").map((field) => field.trim())

    if (gifCounter2 === 0 && gifCounter1 === 2) {
      outputSh += ` [0][f0]overlay=${fields[2]}:${fields[3]},format=yuv420p" \\\n`
    } else if (gifCounter2 === 0) {
      outputSh += ` [0][f0]overlay=${fields[2]}:${fields[3]}[bg1]; \\\n`
    } else if (gifCounter2 === gifCounter1 - 2) {
      outputSh += ` [bg${gifCounter2}][f${gifCounter2}]overlay=${fields[2]}:${fields[3]},format=yuv420p" \\\n`
    } else {
      outputSh += ` [bg${gifCounter2}][f${gifCounter2}]overlay=${fields[2]}:${fields[3]}[bg${gifCounter2 + 1}]; \\\n`
    }
    gifCounter2++
  })

  outputSh += `-t ${videoDuration} \\\n`
  outputSh += "-loglevel error \\\n"
  outputSh += "output.mp4"
}

execSync(outputSh)

if (!fs.existsSync("input_gifs.cfg")) {
  fs.renameSync("output_part1.mp4", "output.mp4")
}

deleteFileIfExists("output_audio.mp3")
deleteFileIfExists("output_part1.mp4")
