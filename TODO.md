# TODO
- figure out what to do instead of assertions
- ponder on git commands running on their own vs by the user / how this happens
    - other uses of pbcopy for ease
- buncha stuff is fucked up
    - git_commands is sometimes a list, sometimes a string
        - Figure out how to properly deal with len == 0 (maybe fine as is with assert)
    - need to make sure to use singular->plural all places it’s applicable
    - go thru prompts and make them actually do what I want + add some prompt engineering flare
    - note that auxiliary commands, if edited, will be kind of a suboptimal prompt.
        - Not worth fixing though because it will likely work well enough and rarely happen anyway.
- make a note about separating the auto-execute flag for auxiliary commands and git commands (maybe not at all for git commands)
- "gemini refactored everything so that I could reuse the command suggestion loop." -m "Not sure if I like it, need to read through more carefully"

