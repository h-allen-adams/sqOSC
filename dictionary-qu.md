#  Qu 5/6/7

[Qu567_MIDI_Protocol_Iss2](https://www.allen-heath.com/content/uploads/2025/06/Qu567_MIDI_Protocol_Iss2.pdf)

## Mixer OSC Address Space

### Scene Change

| Target                   | Notes                                             |
| ------------------------ | ------------------------------------------------- |
| /scene/{1...300}/recall  |                                                   |

**Example Messages**

* /scene/5/recall

### Soft Keys

Soft Key addresses trigger soft keys actions. Soft Keys must be configured on
the mixer before they can be targeted. The general form of these addresses is
"/softKey/{keyNum}" where "keyNum" is the soft key number.

| Target                                    | Args            | Notes          |
| ----------------------------------------- | --------------- | ---------------|
| /softKey/{1...8}/trigger                  | {PRESS,RELEASE} |                |

**Example Messages**

* /softKey/1/trigger PRESS
* /softKey/10/trigger RELEASE

### Mutes

Mutes apply to input channels, output channels, DCAs and Mute Groups:

| Target                                        | Args        | Notes          |
| --------------------------------------------- | ----------- | -------------- |
| /input/{1...32}/mute                          | {ON,OFF}    |                |
| /input/st{1...2}/mute                         | {ON,OFF}    |                |
| /input/usb/mute                               | {ON,OFF}    |                |
| /main/mute                                    | {ON,OFF}    |                |
| /aux/{1...12}/mute                            | {ON,OFF}    | NOTE 1         |
| /group/{1...12}/mute                          | {ON,OFF}    | NOTE 1         |
| /fxSend/{1...4}/mute                          | {ON,OFF}    |                |
| /fxReturn/{1...6}/mute                        | {ON,OFF}    |                |
| /matrix/{1...3}/mute                          | {ON,OFF}    | NOTE 2         |
| /dca/{1...8}/mute                             | {ON,OFF}    |                |
| /muteGroup/{1...8}/mute                       | {ON,OFF}    |                |

**Notes**

1. /aux and /group mutes use the same MIDI parameter numbers
2. Only matrix 1-3 are MIDI contollable

### Levels

Audio level messages apply both to single channel levels and to
channel-to-channel send levels.

| Channel Level Target                          | Args        | Notes          |
| --------------------------------------------- | ----------- | -------------- |
| /main/level                                   | {-100...10} |                |
| /aux/{1...12}/level                           | {-100...10} | NOTE 1         |
| /group/{1...12}/level                         | {-100...10} | NOTE 1         |
| /fxSend/{1...4}/level                         | {-100...10} |                |
| /matrix/{1...3}/level                         | {-100...10} | NOTE 2         |
| /dca/{1...8}/level                            | {-100...10} |                |

**Notes**

1. /aux and /group mutes use the same MIDI parameter numbers
2. Only matrix 1-3 are MIDI contollable

| Channel-to-Channel Send Level                 | Args        | Notes          |
| --------------------------------------------- | ----------- | -------------- |
| /input/{1...32}/to/main/sendLevel             | {-100...10} | NOTE 1         |
| /input/{1...32}/to/aux/{1...12}/sendLevel     | {-100...10} |                |
| /input/{1...32}/to/fxSend/{1...4}/sendLevel   | {-100...10} |                |
| /input/st{1...2}/to/main/sendLevel            | {-100...10} | NOTE 1         |
| /input/st{1...2}/to/aux/{1...12}/sendLevel    | {-100...10} |                |
| /input/st{1...2}/to/fxSend/{1...4}/sendLevel  | {-100...10} |                |
| /input/usb/to/main/sendLevel                  | {-100...10} | NOTE 1         |
| /input/usb/to/aux/{1...12}/sendLevel          | {-100...10} |                |
| /input/usb/to/fxSend/{1...4}/sendLevel        | {-100...10} |                |
| /main/to/matrix/{1...3}/sendLevel             | {-100...10} | NOTE 2         |
| /aux/{1...12}/to/matrix/{1...3}/sendLevel     | {-100...10} | NOTE 2         |
| /group/{1...12}/to/main/sendLevel             | {-100...10} |                |
| /group/{1...12}/to/aux/{1...12}/sendLevel     | {-100...10} |                |
| /group/{1...12}/to/fxSend/{1...4}/sendLevel   | {-100...10} |                |
| /group/{1...12}/to/matrix/{1...3}/sendLevel   | {-100...10} | NOTE 2         |
| /fxReturn/{1...6}/to/main/sendLevel           | {-100...10} | NOTE 1         |
| /fxReturn/{1...6}/to/aux/{1...12}/sendLevel   | {-100...10} |                |
| /fxReturn/{1...6}/to/fxSend/{1...4}/sendLevel | {-100...10} |                |

**Notes**

1. /to/main/sendLevel also sets the sendLevel to all groups
2. Only matrix 1-3 are MIDI contollable

### Panning / Balance

| Channel-to-Channel Send Pan/Balance          | Args         | Notes          |
| -------------------------------------------- | ------------ | -------------- |
| /input/{1...32}/to/main/pan                  | {-100...100} | NOTE 1         |
| /input/{1...32}/to/aux/{1...12}/pan          | {-100...100} |                |
| /input/st{1...2}/to/main/pan                 | {-100...100} | NOTE 1         |
| /input/st{1...2}/to/aux/{1...12}/pan         | {-100...100} |                |
| /input/usb/to/main/pan                       | {-100...100} | NOTE 1         |
| /input/usb/to/aux/{1...12}/pan               | {-100...100} |                |
| /main/to/matrix/{1...3}/pan                  | {-100...100} | NOTE 2         |
| /aux/{1...12}/to/matrix/{1...3}/pan          | {-100...100} | NOTE 2         |
| /group/{1...12}/to/main/pan                  | {-100...100} |                |
| /group/{1...12}/to/aux/{1...12}/pan          | {-100...100} |                |
| /group/{1...12}/to/matrix/{1...3}/pan        | {-100...100} | NOTE 2         |
| /fxReturn/{1...6}/to/main/pan                | {-100...100} | NOTE 1         |
| /fxReturn/{1...6}/to/aux/{1...12}/pan        | {-100...100} |                |

**Notes**

1. /to/main/pan also sets the pan to all groups
2. Only matrix 1-3 are MIDI contollable

### Mix Assignments

| Channel-to-Channel Mix Assignments           | Args         | Notes          |
| -------------------------------------------- | ------------ | -------------- |
| /input/{1...32}/to/main/assign               | {ON,OFF}     |                |
| /input/{1...32}/to/aux/{1...12}/assign       | {ON,OFF}     | NOTE 1         |
| /input/{1...32}/to/group/{1...12}/assign     | {ON,OFF}     | NOTE 1         |
| /input/{1...32}/to/fxSend/{1...4}/assign     | {ON,OFF}     |                |
| /input/st{1...2}/to/main/assign              | {ON,OFF}     |                |
| /input/st{1...2}/to/aux/{1...12}/assign      | {ON,OFF}     | NOTE 1         |
| /input/st{1...2}/to/group/{1...12}/assign    | {ON,OFF}     | NOTE 1         |
| /input/st{1...2}/to/fxSend/{1...4}/assign    | {ON,OFF}     |                |
| /input/usb/to/main/assign                    | {ON,OFF}     |                |
| /input/usb/to/aux/{1...12}/assign            | {ON,OFF}     | NOTE 1         |
| /input/usb/to/group/{1...12}/assign          | {ON,OFF}     | NOTE 1         |
| /input/usb/to/fxSend/{1...4}/assign          | {ON,OFF}     |                |
| /main/to/matrix/assign                       | {ON,OFF}     | NOTE 2         |
| /aux/{1...12}/to/matrix/assign               | {ON,OFF}     | NOTE 2         |
| /group/{1...12}/to/main/assign               | {ON,OFF}     |                |
| /group/{1...12}/to/aux/{1...12}/assign       | {ON,OFF}     |                |
| /group/{1...12}/to/fxSend/{1...4}/assign     | {ON,OFF}     |                |
| /group/{1...12}/to/matrix/{1...3}/assign     | {ON,OFF}     | NOTE 2         |
| /fxReturn/{1...6}/to/main/assign             | {ON,OFF}     |                |
| /fxReturn/{1...6}/to/aux/{1...12}/assign     | {ON,OFF}     | NOTE 1         |
| /fxReturn/{1...6}/to/group/{1...12}/assign   | {ON,OFF}     | NOTE 1         |
| /fxReturn/{1...6}/to/fxSend/{1...4}/assign   | {ON,OFF}     |                |

**Notes**

1. to/aux and to/group assigns use the same MIDI parameter numbers
2. Only matrix 1-3 are MIDI contollable

