# gite
I never bothered to get good at Git commands because
the space of commands is vast but the mental model for Git is fairly small.
Therefore, I can always describe what I want to use Git to do in English, and since
Git really isn't that complicated, an LLM can always give me the appropriate Git command.
However, it is quite cumbersome to always be switching tabs and copying git commands.
If only it could be easier...

### GitEnglish -> GitE -> gite
The solution, of course, was to embed English in the command line.
I made some alpha versions with Gemini (see `alpha/`)
and it worked really well.
But then I realized I wanted it to be more robust of a tool than vague prompting would make,
so I created this repo and outlines the tool I wanted to make in pseudocode. See below:

## Pseudocode
```pseudocode

```

# Future considerations
Right now, the tool only works with my specific Azure GPT-4.1 API key, which is less than ideal. I'll make setup more user friendly once I'm happy with the project.
