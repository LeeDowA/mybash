# ==========================================================
# 🥇 FINAL FIX: Conditional Timer Start
# ==========================================================

# 1. New Timer Start Trap (REPLACE THE OLD timer_start FUNCTION)
function conditional_timer_start() {
    # Reset formatting
    echo -ne "${none}" 
    
    # Check if the command is *NOT* part of the prompt management system.
    # We must explicitly exclude the PROMPT_COMMAND function (render_prompt)
    # and the history commands that often trigger traps.
    local CMD="$BASH_COMMAND"

    if [[ -n "$CMD" && "$CMD" != "render_prompt" && "$CMD" != "history -a" && "$CMD" != "history -n" ]]; then
        __CMD_START=$SECONDS
    fi
}
trap 'conditional_timer_start' DEBUG


# 2. Calculation and Rendering Function (NO CHANGE NEEDED HERE)
# The logic inside render_prompt remains the same as the last successful version.
# It handles calculation, formatting, and dynamic PS1 assignment.
function render_prompt() {
    local END_TIME=$SECONDS
    local D=0
    
    # --- A. Calculate Duration ---
    if (( __CMD_START > 0 )); then
        D=$((END_TIME - __CMD_START))
    fi
    
    # --- B. Reset State ---
    __CMD_START=0

    # --- C. Format Duration ---
    # We keep the D > 1 check to prevent clutter, but you can remove it for debugging.
    if (( D > 1 )); then
        # Formatting logic (M:SS)
        # ... (Your existing formatting logic) ...
        if (( D >= 60 )); then
            local M=$((D / 60))
            local S=$((D % 60))
            LAST_CMD_DURATION_FMT="(\[\e[31m\]${M}m$(printf '%02d' $S)s\[\e[m\])"
        else
            LAST_CMD_DURATION_FMT="(\[\e[31m\]${D}s\[\e[m\])"
        fi
    else
        LAST_CMD_DURATION_FMT="" 
    fi

    # --- D. Dynamic PS1 Rendering ---
    local FINAL_PS1="$TITLEBAR\n${PROMT_USER}${SEPARATOR_1}${PROMT_HOST}${SEPARATOR_2}$(date +%H:%M)${SEPARATOR_3}\
\n took (\[\e[35m\]${LAST_CMD_DURATION_FMT}\[\e[m\])\$ "
    
    PS1="$FINAL_PS1"

    # --- E. History Sync ---
    history -a
    history -n
}

# 3. PROMPT_COMMAND Setup (NO CHANGE NEEDED HERE)
export PROMPT_COMMAND="render_prompt"