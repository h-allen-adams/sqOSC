#  CQ

* [Q_MIDI_Protocol_V1_2_0_iss4](https://www.allen-heath.com/content/uploads/2024/10/CQ_MIDI_Protocol_V1_2_0_iss4.pdf)

## Mixer OSC Address Space

### Scene Change

| Target                   | Notes                                             |
| ------------------------ | ------------------------------------------------- |
| /scene/{1...100}/recall  |                                                   |

**Example Messages**

* /scene/5/recall

### Soft Keys

Soft Key addresses trigger soft keys actions. Soft Keys must be configured on
the mixer before they can be targeted. The general form of these addresses is
"/softKey/{keyNum}" where "keyNum" is the soft key number.

| Target                                    | Args            | Notes          |
| ----------------------------------------- | --------------- | ---------------|
| /softKey/{1...3}/trigger                  | {PRESS,RELEASE} |                |

**Example Messages**

* /softKey/1/trigger PRESS
* /softKey/10/trigger RELEASE

### Mutes

Mutes apply to input channels, output channels, DCAs and Mute Groups:

| Target                                        | Args        | Notes          |
| --------------------------------------------- | ----------- | -------------- |
| /input/{1...16}/mute                          | {ON,OFF}    |                |
| /input/st{1...2}/mute                         | {ON,OFF}    |                |
| /input/usb/mute                               | {ON,OFF}    |                |
| /input/bt/mute                                | {ON,OFF}    |                |
| /main/mute                                    | {ON,OFF}    |                |
| /aux/{1...6}/mute                             | {ON,OFF}    |                |
| /fxSend/{1...4}/mute                          | {ON,OFF}    |                |
| /fxReturn/{1...4}/mute                        | {ON,OFF}    |                |
| /dca/{1...4}/mute                             | {ON,OFF}    |                |
| /muteGroup/{1...4}/mute                       | {ON,OFF}    |                |

### Levels

Audio level messages apply both to single channel levels and to
channel-to-channel send levels.

> [!Important]
> Currenty only the Linear Taper fader law is 

| Channel Level Target                          | Args        | Notes          |
| --------------------------------------------- | ----------- | -------------- |
| /main/level                                   | {-100...10} |                |
| /aux/{1...6}/level                            | {-100...10} |                |
| /fxSend/{1...4}/level                         | {-100...10} |                |
| /dca/{1...4}/level                            | {-100...10} |                |

| Channel-to-Channel Send Level                 | Args        | Notes          |
| --------------------------------------------- | ----------- | -------------- |
| /input/{1...16}/to/main/sendLevel             | {-100...10} |                |
| /input/{1...16}/to/aux/{1...6}/sendLevel      | {-100...10} |                |
| /input/{1...16}/to/fxSend/{1...4}/sendLevel   | {-100...10} |                |
| /input/st{1...2}/to/main/sendLevel            | {-100...10} |                |
| /input/st{1...2}/to/aux/{1...6}/sendLevel     | {-100...10} |                |
| /input/st{1...2}/to/fxSend/{1...4}/sendLevel  | {-100...10} |                |
| /input/usb/to/main/sendLevel                  | {-100...10} |                |
| /input/usb/to/aux/{1...6}/sendLevel           | {-100...10} |                |
| /input/usb/to/fxSend/{1...4}/sendLevel        | {-100...10} |                |
| /input/bt/to/main/sendLevel                   | {-100...10} |                |
| /input/bt/to/aux/{1...6}/sendLevel            | {-100...10} |                |
| /input/bt/to/fxSend/{1...4}/sendLevel         | {-100...10} |                |
| /fxReturn/{1...4}/to/main/sendLevel           | {-100...10} |                |
| /fxReturn/{1...4}/to/aux/{1...6}/sendLevel    | {-100...10} |                |
| /fxReturn/{1...4}/to/fxSend/{1...4}/sendLevel | {-100...10} |                |

### Panning / Balance

| Channel-to-Channel Send Pan/Balance          | Args         | Notes          |
| -------------------------------------------- | ------------ | -------------- |
| /input/{1...16}/to/main/pan                  | {-100...100} |                |
| /input/{1...16}/to/aux/{1...6}/pan           | {-100...100} |                |
| /input/st{1...2}/to/main/pan                 | {-100...100} |                |
| /input/st{1...2}/to/aux/{1...6}/pan          | {-100...100} |                |
| /input/usb/to/main/pan                       | {-100...100} |                |
| /input/usb/to/aux/{1...6}/pan                | {-100...100} |                |
| /input/bt/to/main/pan                        | {-100...100} |                |
| /input/bt/to/aux/{1...6}/pan                 | {-100...100} |                |
| /fxReturn/{1...4}/to/main/pan                | {-100...100} |                |
| /fxReturn/{1...4}/to/aux/{1...6}/pan         | {-100...100} |                |

