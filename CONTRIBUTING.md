# Contribution Guide

## Generating the audio config graph image

You'll need to have [Graphviz](https://www.graphviz.org/)'s `dot` installed.

```sh
dot -Tpng -o audio-config.png audio-config.dot
```

To automatically generate the image when the `.dot` file is saved you can use [`watchexec`](https://github.com/watchexec/watchexec).

```sh
watchexec -d 200 -w audio-config.dot -w img -- dot -Tpng -o audio-config.png audio-config.dot
```
