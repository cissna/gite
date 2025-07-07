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

function answer_question(conversation)

function deal_with_potential_limitations(conversation, LLM_response_proposing_commands)

function identify_potential_limitations_with_proposed_commands(conversation, LLM_response_proposing_commands)

function format_git_commands(unformatted_git_commands_string)

function get_valid_user_choice(nonexit_choices, prompt_text)

function propose_git_commands_to_user(conversation, formatted_git_commands_string, explanation_text)

function propose_and_run_commands_until_success(conversation, initial_commands, explanation_text)

function handle_conversation_until_no_question(conversation)

function run_commands_in_users_terminal_and_collect_logs(list_of_commands)

function are_logs_bad(logs, commands)

function singular_to_plural(singular_text, commands)

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

    conversation = add {assistant: send_to_LLM(conversation, model=quick).strip()} to the end of conversation 
    conversation = handle_conversation_until_no_question(conversation)

    # update the conversation inside the function:
    conversation = deal_with_potential_limitations(conversation)
    # this is first-order processing only. we assume that after deal_with_potential_limitations, there are no limitations left, so we don't bother to check after this, beyond letting the LLM ask questions.

    LLM_output_string = pop last entry of conversation (remove it and return value)
    initial_commands = format_git_commands(LLM_output_string)
    assert len(initial_commands) > 0

    # This function will loop until the commands are successfully executed.
    # It handles proposing, explaining, editing, and running the commands.
    conversation, _, _ = propose_and_run_commands_until_success(conversation, initial_commands, explanation_text="Suggested command:")



function definitions:
send_to_LLM will depend on model, but for now just assume my specific set up

function singular_to_plural(singular_text, commands)
    assert len(commands) > 0
    if len(commands) == 1:
        return singular_text
    else:
        return singular_text.replace('command', 'commands').replace('this', 'these').replace('it', 'them').replace('that', 'those')

function answer_question(conversation)
    let question be the last item in conversation
    assert question ends in a question mark

    git_commands = format_git_commands(send_to_LLM({
        system: "You are an assistant who detects automatable tasks. I will attach a conversation between an LLM and person, and your job is to look at the final message (given the context of the above messages), which will be a question to the user. You don't want the user to have to spend time answering questions are easily answerable without, so you will detect whether a question can be answerable by terminal commands. If it is answerable by terminal commands, provide those terminal commands.
        If you determine it is *not* answerable with terminal commands (because it needs the insight of a human to clarify their intentions or have a more comprehensive understanding of the relevant information), reply that this text needs to be answered by a human. If you are unsure of what terminal commands are necessary, feel free to choose this response—at the end of the day, it's better if the human correctly answers it than the terminal incorrectly answering.",
        user: 
    }, model=quick))

    if len(git_commands) == 0:
        Ask the question to the user, return their response. Loop until they actually respond (no accidentally hitting enter)
    
    # at this point, we assume git_commands are the terminal commands to be executed:

    # we sort of doubt the user will edit these commands, but give them the option
    # so if they do, the prompt will be kind of janky and we definitely DO NOT want that updating the conversation, hence the `_`.
    # This function will loop until the commands are successfully executed.
    # It handles proposing, explaining, editing, and running the commands.
    # We pass `update_conversation_on_edit=False` because we don't want to pollute the main conversation
    # with edits made to these temporary, information-gathering commands.
    _, logs, commands_that_were_run = propose_and_run_commands_until_success(
        conversation,
        initial_commands=git_commands,
        explanation_text=explanation_text
    )

    return singular_to_plural('To answer your question, I ran this command:\n```\n', commands_that_were_run) +
           (commands_that_were_run, separated line by line) + '```\nAnd I got this response:\n```\n' +
           logs + '```\n\nDoes that answer your question? If not, ask me further questions. If it does, continue with assisting me."
    

function deal_with_potential_limitations(conversation):
    # scenario might not be the most apt name, consider changing once formatting better understood. same comment as formatting comment below, basically.
    limitation_scenario = identify_potential_limitations_with_proposed_commands(conversation)

    # then make a new prompt where the system prompt suggests the LLM should be harsh and consider whether the scenario is actually likely in the real world at all, or if it is just obscure or hypothetical.
    # user prompt is basically the whole above prompting back-and-forth.
    # send that to the quick LLM and look for a response of "real limitation" or "nothing to worry about"
    # if nothing to worry about, return conversation (unchanged)

    # if something to worry about, send a prompt to quicker LLM to create a clarifying question to see if the limitations apply.
    # use answer_question on it

    # we forge an LLM message in the `conversation` (this involves popping git_commands off of the conversation and adding it back)
    # where it says something like "I was considering using these commands [git_commands]\nBut I am worried about a potential limitation: [limitation output of identify_potential_limitations_with_proposed_commands]. [question associated with limitation]?"
    # consider the formatting of [limitation output of identify_potential_limitations_with_proposed_commands], may need to adjust some things to make it make sense

    # and then also add the response from the user (or maybe not the user, depending on what happens in answer_question) to the conversation
    # then send back to the LLM to evaluate whether (and how) it needs to edit the suggested commands

    # then return the conversastion where the last value is the output is the LLMs response to the response to the question about limitations
    return conversation

function identify_potential_limitations_with_proposed_commands(conversation):
    # create a new system prompt that tells the LLM to read the conversation and especially the commands, and think about whether these commands are faulty, especally with regard to potential limitations that would only occur in certain scenarios.
    # prompt specificity: "don't response with anything but a sentence explaining the potential limitations, please don't start the sentence with \"the potential limitations are...\", as it is redundant."

    # then create a user prompt which actually includes the entire JSON of `conversation` and some user text at the bottom saying something like 'are there scenarios where this will fail?'
    # send that off to the quick LLM and get back some potential limitations
    return potential_limitations_LLM_response_text

function format_git_commands(unformatted_git_commands_string):
    # The LLM output may include extra explanation, markdown formatting, or other noise.
    # This function sends that output to the quickest model, instructing:
    #   - Only extract actual git commands.
    #   - Return only the commands, each on its own line.
    #   - Do not output any explanations, markdown, or formatting.

    formatted_string = send_to_LLM({
        system: "You are a parser. The user will provide text that contains one or more terminal commands, possibly surrounded by explanatory text or markdown formatting.
        Extract only the git commands.
        Return ONLY the commands, each on a new line.
        Do not include any other text, explanation, or markdown formatting like ```.
        If there are no commands, reply with the EXACT TEXT (NOTHING ELSE), \"No commands in this text.\"",
        user: unformatted_git_commands_string
    }, model=quickest)

    if formatted_string == 'No commands in this text.':  # maybe make this more lenient in case the 'quickest' models doesn't perfectly match this text. Candidates for leniency: stripped, lowercase, punctuation doesn't matter, missing any (or all) of the last 3 words.
        return []

    # Split into lines, removing blank lines and stripping any whitespace.
    return [line.strip() for line in formatted_string.split('\n') if line.strip()]  # this line is python not pseudocode

# Helper to validate user input and handle cancellation/reprompt
function get_valid_user_choice(nonexit_choices, prompt_text):
    while True:
        print (in normal text) prompt_text
        char = read 1 character (don't wait for enter)
        if char in nonexit_choices:
            return char
        if char == 'n':
            exit program and print "Cancelled."
        # one more try then cancel
        print (in normal text) prompt_text
        char = read 1 character (don't wait for enter)
        if char in nonexit_choices:
            return char
        exit program and print "Cancelled."


# proposes git commands to user, supports explain/edit/execute without code duplication
# This is the core loop for proposing, editing, and running commands until they succeed.
function propose_and_run_commands_until_success(conversation, initial_commands, explanation_text):
    explanation_text_formatted = singular_to_plural(explanation_text, initial_commands)

    # Always work on a copy of the conversation to avoid side effects.
    # The caller can decide whether to use the returned, updated conversation.
    temp_conversation = conversation.copy()  # this may be unnecessary depending on the specific implementation
    current_commands = initial_commands
    failed = True

    while failed:
        # Propose the commands to the user and get their agreement to run them.
        # This function returns the potentially updated conversation and the commands to run.
        temp_conversation, commands_to_run = propose_git_commands_to_user(
            temp_conversation,
            current_commands,
            explanation_text_formatted
        )

        logs = run_commands_in_users_terminal_and_collect_logs(commands_to_run)
        failed = are_logs_bad(logs, commands_to_run)

        if failed:
            # If the commands fail, update the conversation to send to the LLM for a fix.
            temp_conversation = add {assistant: commands_to_run} to the end of temp_conversation
            temp_conversation = add {
                user: "I tried running these commands but I got this response:\n\n[logs]\n\nIf the solution to this is obvious, propose new git commands. If it is not, ask me questions that will help you better understand the problem."
            } to the end of temp_conversation
            
            LLM_output_string = send_to_LLM(temp_conversation, model=quick).strip()
            
            # The LLM might ask a question back. Handle that conversation loop.
            temp_conversation = add {assistant: LLM_output_string} to the end of temp_conversation
            temp_conversation, LLM_output_string = handle_conversation_until_no_question(temp_conversation)

            # The new commands to try in the next iteration of the loop
            current_commands = format_git_commands(LLM_output_string)
        else:
            # Success! Print a confirmation message and return the final state.
            print singular_to_plural("Command executed successfully.", current_commands)
            return temp_conversation, logs, commands_to_run  # at this point it's more like commands_that_were_run

# This function now only handles the user interaction part (propose/explain/edit)
function propose_git_commands_to_user(conversation, formatted_git_commands, explanation_text):
    # This function can modify the conversation if the user edits the commands.
    # It returns the (potentially modified) conversation and the final commands.
    temp_conversation = conversation.copy()

    while True:
        print (in blue, bold text) explanation_text
        print each command in bold, default-color text line by line
        print (in yellow, not bold text) "Warning: Always review AI-generated commands."

        choice = get_valid_user_choice(['y', 'e'], "Execute? [y]es / [e]xplain / [n]o:")
        if choice == 'y':
            return temp_conversation, formatted_git_commands
        if choice == 'e':
            LLM_response = send_to_LLM(conversation={
                system: "You are a terminal-embedded LLM assisting a beginner terminal-user. They will provide some commands they are confused about, and you will explain granularly but concisely what the command does. Don't repeat yourself or add any fluff, and don't put any markdown formatting as it will not render.",
                user: singular_to_plural("Please explain what this does before I execute it", formatted_git_commands) + "```\n{commands, line by line}\n```"
            }, model=quicker)
            print LLM_response
            
            choice2 = get_valid_user_choice(['y', 'e'], "Execute? [y]es / [e]dit / [n]o:")
            if choice2 == 'y':
                return temp_conversation, formatted_git_commands
            if choice2 == 'e':
                user_clarification = read from user until they hit enter
                
                add to end of temp_conversation {
                    assistant: formatted_git_commands,
                    user: singular_to_plural("can you explain that command?", formatted_git_commands),
                    assistant: LLM_response + '?',
                    user: "Please make the following changes to the commands:\n" + user_clarification
                }

                LLM_output_string = send_to_LLM(temp_conversation, model=quick)
                
                # Update the commands for the next loop iteration to re-propose them.
                formatted_git_commands = format_git_commands(LLM_output_string)
                # continue the while loop



# handle the conversational exchange loop with the LLM, returning when the LLM no longer asks questions
# this function assumes conversations ends with a message send by the LLM
function handle_conversation_until_no_question(conversation):
    assert key of last entry in conversation is 'assistant'
    LLM_output_string = value of last entry in conversation
    while LLM_output_string ends in "?":
        # user_response may come from user or automated execution
        user_response = answer_question(conversation)
        conversation = add {user: user_response} to the end of conversation
        LLM_output_string = send_to_LLM(conversation, model=quick).strip()
        conversation = add {assistant: LLM_output_string} to the end of conversation
    return conversation, LLM_output_string

function run_commands_in_users_terminal_and_collect_logs(list_of_commands):
    pass  # I don't know how to implement this, should return string of logs
    # i think we may use the `script` terminal command to collect logs for more complicated, interactive commands, like `git add -p` or `git commit`

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

## Long-term future considerations
Right now, the tool only works with my specific Azure GPT-4.1 API key, which is less than ideal. I'll make setup more user friendly once I'm happy with the project.
