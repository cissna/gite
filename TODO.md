# TODO
- figure out what to do instead of assertions
- ponder on git commands running on their own vs by the user / how this happens
    - other uses of pbcopy for ease
    - Make it so when the git commands execute, it reprints them at the end and gives a y/n to copy or not (config to remove option)
        - If some commands fail and then they run more, we should probably print the failed commands in red and then also print the successful commands in green. In case the first ones also matter for the second ones
    - But that's only one of the cases, when it's determined that the command running is not interactive. If the command is interactive, it should forgo log collecting and just let it run
        - In this case, it *can't* print at the end (I think, need to verify this fact), so we should ask to copy before it runs.
- buncha stuff is fucked up
    - git_commands is sometimes a list, sometimes a string
        - Figure out how to properly deal with len == 0 (maybe fine as is with assert)
    - need to make sure to use singular->plural all places it’s applicable
    - go thru prompts and make them actually do what I want + add some prompt engineering flare
    - note that auxiliary commands, if edited, will be kind of a suboptimal prompt.
        - Not worth fixing though because it will likely work well enough and rarely happen anyway.
    - Add to the prompt about error handling to undo what commands were done if necessasry.
- make a note about separating the auto-execute flag for auxiliary commands and git commands (maybe not at all for git commands)
- "gemini refactored everything so that I could reuse the command suggestion loop." -m "Not sure if I like it, need to read through more carefully"

