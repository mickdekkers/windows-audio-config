# Contribution Guide

## Generating the audio config graph image

You'll need to have [Graphviz](https://www.graphviz.org/)'s `dot` installed.

```sh
dot -Tpng -o audio-config.png audio-config.dot
```

Use e.g. [ffmpeg](https://www.ffmpeg.org/) to downscale the image by 4x:

```sh
ffmpeg -y -i audio-config.png -vf scale="iw/4:-1" audio-config-downscaled.png
```

To automatically generate the images when the `.dot` file is saved or the `img` folder is updated you can use [`watchexec`](https://github.com/watchexec/watchexec).

```sh
watchexec -d 200 -w audio-config.dot -w img 'dot -Tpng -o audio-config.png audio-config.dot && ffmpeg -y -i audio-config.png -vf scale="iw/4:-1" audio-config-downscaled.png'
```
