## --- Elapsed Time in Prompt ---

# 1. Define variables to store the start time and elapsed time
# SECONDS is a built-in bash variable that counts seconds since the shell started.
export LAST_CMD_DURATION=0
export TIMER_START=0

# 2. Function to start the timer (called before every simple command)
# The DEBUG trap is triggered before every command execution.
function set_cmd_start() {
    # Set TIMER_START to the current SECONDS value
    TIMER_START=$SECONDS
}
trap 'set_cmd_start' DEBUG

# 3. Function to stop the timer and format the duration (called before every prompt)
# PROMPT_COMMAND is run just before displaying the prompt (PS1).
function calculate_duration() {
    # Calculate the difference and save it to LAST_CMD_DURATION
    LAST_CMD_DURATION=$((SECONDS - TIMER_START))
    
    # Format the time for display (e.g., 65 seconds to 1m05s)
    local D=$LAST_CMD_DURATION
    if (( D >= 60 )); then
        local M=$((D / 60))
        local S=$((D % 60))
        # Use printf to ensure seconds always has two digits
        LAST_CMD_DURATION_FMT="${M}m$(printf '%02d' $S)s"
    else
        LAST_CMD_DURATION_FMT="${D}s"
    fi
}

# 4. Add the calculation function to PROMPT_COMMAND
# The PROMPT_COMMAND is a string of commands to execute before the prompt is displayed.
# We ensure existing commands are preserved (if PROMPT_COMMAND is not empty).
##PROMPT_COMMAND="calculate_duration${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# 5. Integrate the duration into your PS1
# We use an example PS1. You can modify your existing PS1.
# The `\${LAST_CMD_DURATION_FMT}` part adds the formatted time.
# The conditional `\$((LAST_CMD_DURATION > 1 && ...))` only displays the time if it's > 1 second.
##export PS1='\[\e[32m\]\u@\h\[\e[m\]:\w $(if [[ $LAST_CMD_DURATION -gt 1 ]]; then echo "(\[\e[31m\]${LAST_CMD_DURATION_FMT}\[\e[m\])"; fi)\n\$ '

## --- END Elapsed Time in Prompt ---