# Human vs AI Example

This repo contains (hopefully) representative examples of entirely human created code/documentation vs LLM generated versions of the same. The aim is to help identify AI slop.

# BLUF

The human produced script contains no glaring errors or issues and runs cleanly. The code is concise and commented sparsely. The documentation is equally concise and contains a relevant screenshot. The PR text is simple and to the point with a proper title.

The AI generated script runs despite a few issues that would still likely pass CI (described below), though human review would catch some strange logic choices. It contains copious comments, all formatted as generally complete sentences, even where the code speaks relatively well for itself without comment. The documentation is overly thorough, often stating the obvious and slightly repetitive, even moreso in the more detailed variant. The more verbose file also contains emojis in the headers along with some special characters that aren't easily typed in a simple text editor (an arrow character and several emdash characters) - all fairly glaring AI indicators. The PR description follows the same overly verbose pattern with prominent formatting that is a bit uncharacteristic of purely human produced content.

### Human Produced Files:

- [human (folder)](human)
    - [human.lua](human/human.lua)
    - [README.md (human)](human/README.md)
    - [pull_request.md (human)](human/pull_request.md)

### AI (GPT5) Generated Files:

- [gpt5 (folder)](gpt5)
    - [gpt5.lua](gpt5/gpt5.lua)
    - [README.md (AI)](gpt5/README.md)
    - [README2.md (AI)](gpt5/README2.md)
    - [pull_request.md (AI)](gpt5/pull_request.md)

### AI Generated Script Issues

- There are ways to produce the intended behavior without scripting, a fact I wondered if the AI agent would deduce. It did not.
- Inappropriately uses `nav_scripting_enable()` as if it controls state (it does not)
- Mistakenly tries to capture SCRIPT_TIME timeout as an argument and then attempts to elegantly determine whether to use the timeout feature or Arg1. Timeout is unavailable in the binding, so the entire logic tree surrounding it simply results in the need to set Arg1 to the timeout value. Also results in misleading names for arg1, arg2, etc.
- Implements a state machine that is wholly unnecessary for the simple task
    - Likely because the ArduPilot example repo uses this technique
- Unnecessarily wraps bearing around 360 degrees
    - Again, likely because there are `wrap360()` examples, but the binding used here would never return a value greater than 2*pi.
- Does not use a command ID, so any `SCRIPT_TIME` command results in this script triggering. As a result, this script could conflict with others using `SCRIPT_TIME`.
    - And once again, a bit of logic lifted from the example repo
- Uses `set_target_posvelaccel_NED()` where `set_target_pos_NED()` would be adequate and also mislabels the arguments in the comments.

# Method

### Human Produced Code + Documentation

I first created a simple ArduPilot Lua script to face a Copter toward home for a user-defined duration. I used only ArduPilot documentation and examples with no AI agent generation or hints for the initial script and associated documentation. The script was tested via SITL and works as intended.

The scripted behavior is complex enough to require a human user to have a fairly thorough working knowledge of ArduPilot and its scripting interface and also rather simple to implement, given that knowledge.

### AI Generated Code + Documentation

I prompted the AI agent with the following:

> Create an ardupilot lua script that uses a SCRIPT_TIME command to pause the mission for a user-determined time (in seconds). While paused, the Copter should yaw toward the home waypoint, and then continue the mission.

It generated a script that actually ran briefly until it encountered a type error, which was fixed after the following prompt:

> I get this error:
```
28-Nov-25 09:58:47 : av_scripting_enable' (number expected, got boolean
28-Nov-25 09:58:47 : Lua: ./scripts/gpt5.lua:120: bad argument #1 to 'n
```

I then asked it to generate a README file. I also asked for a second README with additional detail and formatting.

Lastly, I prompted for a pull request title and description.
