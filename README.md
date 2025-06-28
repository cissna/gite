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
so I created this repo and outlined the tool I wanted to make in pseudocode. See below:

## Pseudocode
```pseudocode
function declarations:

function send_to_LLM(chat_obj, model)
# where chat_obj has a system prompt, then messages back and forth between 'user' and 'assistant', ending with a message from the user. I'll later call it `conversation` instead of `chat_obj`
# assume that some sort of config defines quick, quicker, quickest models, so model can just be quick, quicker, or quickest and that can be decided by the user
# for now, i am using GPT-4.1, mini, and nano for these 3

function deal_with_potential_limitations(conversation, LLM_response_proposing_commands)

function identify_potential_limitations_with_proposed_commands(conversation, LLM_response_proposing_commands)

function format_git_commands(unformatted_git_commands_string)

function get_valid_user_choice(valid_choices, prompt_text)

function propose_git_commands_to_user(conversation, formatted_git_commands_string)

function handle_conversation_until_no_question(conversation)

function run_commands_in_users_terminal_and_collect_logs(list_of_commands)

function are_logs_bad(logs)

system_prompt = """You are an Expert Git assistant helping a beginner use Git. They want to do something with Git which they can describe, but need you to help them translate that into a viable command.
To be viable, the command must be non-interactive, i.e., executable without ANY alterations—no fill in the blanks or ...s.
They will provide you a description of what they want, and you will return a non-interactive command or a list of non-interactive commands that accomplishes their goal.
They might not have provide all of the necessary information to make the perfect non-interactive command, in which case you MUST follow up with a clarifying question.
NEVER return with git commands if you are unsure if they will meet the user's needs—accuracy is paramount.
If you ask a question, ensure your message ends with a `?`
If you provide git commands, ensure your message does not end in a `?`, which exclusively indicates a question."""

main logic:
    user_str = user passes in a string describing what they want with a command like `gite "merge dev into this branch"`

    conversation = {
        system: system_prompt,
        user: user_str
    }

    conversation, LLM_output_string = handle_conversation_until_no_question(conversation)

    # update the conversation inside the function:
    conversation = deal_with_potential_limitations(conversation, LLM_output_string)
    # this is first-order processing only. we assume that after deal_with_potential_limitations, there are no limitations left, so we don't bother to check after this, beyond letting the LLM ask questions.

    failed = True  # not actually true at first, but we need to get into while loop
    while failed:
        conversation, LLM_output_string = handle_conversation_until_no_question(conversation)
        conversation = add {assistant: LLM_output_string} to the end of conversation

        git_commands = format_git_commands(LLM_output_string)

        # user can exit the program from this function,
        # so we proceed from here we assume they agreed to these commands
        conversation, git_commands_to_run = propose_git_commands_to_user(conversation, git_commands)

        logs = run_commands_in_users_terminal_and_collect_logs(git_commands_to_run)

        failed = are_logs_bad(logs, git_commands_to_run)
        if failed:
            conversation = add {
                user: "I tried running these commands but I got this response:\n\n[logs]\n\nIf the solution to this is obvious, propose new git commands. If it is not, ask me questions that will help you better understand the problem."
            } to conversation
        else:
            # if logs are not bad, we assume success and exit the loop
            print "Commands executed successfully."



function definitions:
send_to_LLM will depend on model, but for now just assume my specific set up

# this is the one that, if there are limitations found, we forge an LLM message in the conversation
# where it says something like "I was considering using these commands [git_commands]\nBut I am worried about a potential limitation: [limitation output of identify_potential_limitations_with_proposed_commands]. [question associated with limitation]?"
function deal_with_potential_limitations(conversation, LLM_response_proposing_commands):
    pass

function identify_potential_limitations_with_proposed_commands(conversation, LLM_response_proposing_commands):
    pass

function format_git_commands(unformatted_git_commands_string):
    pass the unformatted_git_commands_string to the quickest model and ask it to parse
    out only the actual git commands from the text. Make sure they are returned with no additional text, no formatting, and with each command (if multiple) on separate lines.
    
    Then do the equivalent of python's output.split('\n') to make it a list, and return that list

# Helper to validate user input and handle cancellation/reprompt
function get_valid_user_choice(valid_choices, prompt_text):
    while True:
        print (in normal text) prompt_text
        char = read 1 character (don't wait for enter)
        if char in valid_choices:
            return char
        if char == 'n':
            exit program and print "Cancelled."
        # one more try then cancel
        print (in normal text) prompt_text
        char = read 1 character (don't wait for enter)
        if char in valid_choices:
            return char
        exit program and print "Cancelled."


# proposes git commands to user, supports explain/edit/execute without code duplication
function propose_git_commands_to_user(conversation, formatted_git_commands_string):
    while True:
        print (in blue, bold text) f"Suggested command{'s' if multiple commands else ''}:\n"
        print each command in bold, default-color text line by line
        print (in yellow, not bold text) "Warning: Always review AI-generated commands."
        choice = get_valid_user_choice(['y', 'e'], "Execute? [y]es / [e]xplain / [n]o:")
        if choice == 'y':
            return conversation, formatted_git_commands_string
        if choice == 'e':
            # Explain path
            LLM_response = send_to_LLM(conversation={
                system: "You are a terminal-embedded LLM assisting a beginner terminal-user. They will provide some commands they are confused about, and you will explain granularly but concisely what the command does. Don't repeat yourself or add any fluff, and don't put any markdown formatting as it will not render.",
                user: ("Please explain what this does before I execute it" if (only one command) else "Please explain what these do before I execute them") + f"```\n{commands, line by line}\n```"
            }, model=quicker)
            print LLM_response
            # Now prompt for execute/edit/no
            choice2 = get_valid_user_choice(['y', 'e'], "Execute? [y]es / [e]dit / [n]o:")
            if choice2 == 'y':
                return conversation, formatted_git_commands_string
            if choice2 == 'e':
                user_clarification = read from user until they hit enter
                
                # Update conversation with clarification and previous explanation
                add to end of conversation {
                    assistant: formatted_git_commands_string,
                    user: f"can you explain {"that command" if only one command else  "those commands"}?",

                    # the '?' is because without it, it could influence LLM to send
                    # non-git-command messages that don't end in a '?', which should never happen.
                    assistant: LLM_response + '?',
                    user: "Please make the following changes to the commands:\n" + user_clarification
                }

                LLM_output_string = send_to_LLM(conversation, model=quick)
                git_commands = format_git_commands(LLM_output_string)
                formatted_git_commands_string = git_commands

                # continue loop with updated git commands and conversation
                # until the user agrees or exits



# handle the conversational exchange loop with the LLM, returning when the LLM no longer asks questions
function handle_conversation_until_no_question(conversation):
    LLM_output_string = send_to_LLM(conversation, model).strip()
    while LLM_output_string ends in "?":
        conversation = add {assistant: LLM_output_string} to the end of conversation
        # user_response may come from user or automated execution
        user_response = answer_question(conversation)
        conversation = add {user: user_response} to the end of conversation
        LLM_output_string = send_to_LLM(conversation, model=quick).strip()
    return conversation, LLM_output_string

function run_commands_in_users_terminal_and_collect_logs(list_of_commands):
    pass  # I don't know how to implement this, should return string of logs
function are_logs_bad(logs, commands):
    if logs are empty: return False

    # ask the quickest model to analyze the logs and commands
    # the model should be instructed to respond with one of three things:
    # 1. 'no' if the commands succeeded
    # 2. 'yes' if the commands failed for a generic reason
    # 3. 'conflict: [explanation]' if the commands resulted in a merge conflict. The explanation should be a short, user-friendly guide on how to resolve it.

    model_response = send_to_LLM_with_special_instructions({
        system: "You are a failure detector, designed to determine whether terminal commands resulted in failure or not based on their logs. You also have a carve-out for git commands that result in merge conflicts.
        You will STRICTLY output 'failure', 'success' or 'conflict: .+'.
        Unless there is a merge conflict, you will only output the SINGLE WORD that describes the situation.
        DO NOT provide any additional explanation text, markdown formatting or anything else.
        If there is a conflict, you should output 'conflict: [explanation of how to resolve the conflict]'
        so you can assist the user in manually solving the conflict.",
        user: "I ran these commands:\n```\n{commands, line by line}\n```\nAnd this was the output:\n```\n{logs}\n```\nDid it fail, succeed, or was there a merge conflict (and if so, how do I fix the conflict)?"
    }, model=quickest)

    if model_response is 'success':
        return False # logs are not bad
    if model_response is 'failure':
        return True # logs are bad
    if model_response starts with 'conflict:':
        # print the explanation and treat as "not bad" to exit the main loop
        conflict_explanation = the rest of the model_response string
        print (in red, bold text) "Merge conflict detected."
        print (in normal text) conflict_explanation
        return False # logs are not "bad" in a way that requires a retry

    # if the model returns something unexpected, assume it's a failure
    return True

```

# Future considerations
## Short-term future considerations
- Config stuff:
    - --verbose: prints all API calls
    - --quiet: print bare minimum
    - --auto-accept: self-explanatory, maybe allow for different levels so user input can/cannot be an option at times.

- should edit include necesarily previous explanation of the commands? probably...
## Long-term future considerations
Right now, the tool only works with my specific Azure GPT-4.1 API key, which is less than ideal. I'll make setup more user friendly once I'm happy with the project.
