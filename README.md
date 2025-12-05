# sqOSC

Open Sound Control (OSC) Server providing automation cues for the Allen &
Heath SQ series mixers, as well as other A&H mixers. Upon receipt of any OSC
Message described below, the server constructs the corresponding MIDI message
and forwards it to the mixer.

This application can be configured to target multiple A&H mixer series, but only
one mixer can be targeted at one time.

## Disclaimers

> [!Important]
> This project is not affiliated with or supported by Allen & Heath in any way.

> [!Warning]
> No warranty is expressed or implied.
                                            
## Background

I initially developed this application to automate show cues at my church, where
we have an SQ-6 mixer in the Sanctuary. While the SQ-6 provides MIDI support
to control a lot of mixer parameters, I found it difficult to use those MIDI
messages in QLab and other automation tools.
                                            
Most mixer control messages take the form of MIDI Non-Registered Parameter
Number (NRPN) messages, which consist of a Parameter Number which identifies the
value to be changed and a Parameter Value which encodes the new value. Both the
Parameter Number and Parameter Value are split into a high and low byte in order
to fit in the NPRN message format.

Automation tools like QLab can send MIDI messages, but NPRN messages are not
really human-readable. Writing and editing NPRM show cues on the fly (for
instance, during a tech rehearsal) is difficult. In contrast, OSC messages
are human-readable and can easily be edited on the fly.

## Supported Mixer Series

* [SQ](dictionary-sq.md)
* [Qu 5/6/7](dictionary-qu.md)
* [CQ](dictionary-cq.md)

## Mixer OSC Address Space

> [!Information]
> Not all supported mixer series support all of the operations and addresses
> described in this guide. Use the OSC Builder and Dictionary tabs of the 
> application to view the OSC methods supported for a specific mixer series.

An OSC Server’s OSC Methods are arranged in a tree strcuture called an OSC
Address Space. The leaves of this tree are the OSC Methods and the branch nodes
are called OSC Containers. OSC Methods are defined for each supported mixer
operation:

| Method    | OSC Container Type  | Description                                  |
| --------- | ------------------- | -------------------------------------------- |
| mute      | Channel, DCA, MG    | Mute or Unmute the specified target          |
| sendLevel | Channel-to-Channel  | Set the level of a channel to a mix or group |
| sendPan   | Channel-to-Channel  | Set the pan of a channel to a mix or group   |
| assign    | Channel-to-Channel  | Assign a channel to a mix or group           |
| level     | Output Channel, DCA | Set the output channel's level               |
| balance   | Output Channel      | Set the output channel's stereo balance      |
| trigger   | Soft Key            | PRESS or RELEASE the specified Soft Key      |
| recall    | Scene               | Recall the Specified Scene                   |

### Channel Targets

Channel addresses define a single audio channel, such as an input or output. The
general form of these addresses is "/{chType}/{chNum}" where:

* chType - Channel Type (see tables below)
* chNum - Channel number. For channel types with only one channel (such as main),
  the channel number is omitted.

| Input Channel     | Description                                  |
| ----------------- | -------------------------------------------- |
| /input/{chNum}    | Mono or assignable mono/stereo input channel |
| /input/st{chNum}  | Fixed stereo input channel                   |
| /input/usb        | Fixed stereo USB input                       |
| /input/bt         | Fixed stereo Bluetooth input                 |

| Output Channel    | Description                                  |
| ----------------- | -------------------------------------------- |
| /main             | Main LR Output                               |
| /aux/{chNum}      | Aux Output                                   |
| /matrix/{chNum}   | Matrix Output                                |

| Internal Channel  | Description                                  |
| ----------------- | -------------------------------------------- |
| /group/{chNum}    | Audio Group                                  |
| /fxSend/{cNum}    | FX Send channel                              |
| /fxReturn/{chNum} | FX Return channel                            |

### DCA and Mute Group Targets

| Target             | Description                                  |
| ------------------ | -------------------------------------------- |
| /dca/{chNum}       | DCAs                                         |
| /muteGroup/{chNum} | Mute Group Control                           |

### Channel-to-Channel Targets

Channel-to-Channel addresses target audio moving from one channel to another,
such as an input channel to an output, or an output to a group. The general form
of these addresses is "/{sourceType}/{sourceNum}/to/{destType}/{destNum}" where

* sourceType, destType - Channel Type (see tables above)
* sourceNum, destNum - Channel number. For channel types with only one channel
  (such as main), the channel number is omitted.

### Soft Key Targets

Soft Key addresses trigger soft keys actions. Soft Keys must be configured on
the mixer before they can be targeted. The general form of these addresses is
"/softKey/{keyNum}" where "keyNum" is the soft key number.

### Scene Change

```
/scene/{sceneNum}/recall 
```

## Acknowledgements

* [OSCKit](https://github.com/orchetect/OSCKit)
* [MIDIKit](https://github.com/orchetect/MIDIKit)
* Application Icon has been designed using resources from [Flaticon.com](https://www.flaticon.com/free-icon/mixer_1741701?related_id=1741701)
