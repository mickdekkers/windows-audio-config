## Audio Graph

![a visual graph of the audio configuration](audio-config.png)

## Setup

- Ensure any audio device that will be connected to the virtual audio cables is configured to use a sample rate of 48000 Hz.
- Set up 6 Virtual Audio Cables in the VAC Control Panel (the default settings are fine).
- Go to the Windows audio properties panel and rename both the `Playback` and `Recording` components of the `Line x` audio devices as follows (best done device by device):

| Cable number | Old name | New name         |
| ------------ | -------- | ---------------- |
| 1            | Line 1   | Virtual Chat In  |
| 2            | Line 2   | Virtual Default  |
| 3            | Line 3   | Virtual Mixer    |
| 4            | Line 4   | Virtual Media    |
| 5            | Line 5   | Virtual Guitar   |
| 6            | Line 6   | Virtual Chat Out |

- Install Nvidia RTX Voice and configure it to use your physical microphone as its input device (to denoise your mic) and `Virtual Chat In` as its output device (to denoise incoming chat audio).
- Set `Virtual Default` to be your default device and default communication device under `Playback`
- Set `Virtual Chat Out` to be your default device and default communication device under `Recording`
- Go to `App volume and device preferences` under `Advanced sound options` in the Windows 10 settings app and configure any media player apps (e.g. Spotify) to output to `Virtual Media`
- Configure any voice chat apps to output incoming chat audio to `Speakers (NVIDIA RTX Voice)`
- Disable audio ducking in Windows

### Configure run on startup

- Create a shortcut named `Start Audio Repeaters` with the following settings in its Shortcut tab:

| Field    | Value                                                                                                                              |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Target   | `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "<path-to-the-directory-that-contains-this-readme>\start.ps1"` |
| Start in | `<path-to-the-directory-that-contains-this-readme>`                                                                                |
| Run      | Minimized                                                                                                                          |

- Copy/move the shortcut to `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp`

## Caveats

The Windows volume controls will not work for audio that is forwarded with the KS repeaters. My headset has a built-in volume knob that is processed in its firmware outside of Windows, so this is not an issue for me in this specific case. I can use a KS repeater to forward audio from the Virtual Mixer to my headset. If you need volume control, replace that KS repeater with an MME repeater. In my case an MME repeater is needed for my monitor speakers, for example.

## TODO

- Configure Shadowplay for instant replay recording and document configuration
- Configure OBS and document configuration
- Configure Discord and document configuration
- Configure Google Meet and document configuration
- Document Tracktion Waveform configuration for guitar effects

## Attribution

Images
```
electric guitar by Juan Pablo Bravo from the Noun Project
```
