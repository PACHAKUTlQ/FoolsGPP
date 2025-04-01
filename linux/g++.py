#!/usr/bin/env python3

import subprocess
import sys
import random

REAL_GPP = "g++"
TARGET_ERROR_PATTERN = r": error: "
APRIL_FOOLS_MESSAGES = [
    "April Fools! Maybe you're debugging in the Twilight Zone?",
    "Your code has been abducted by aliens. Try again after they return it.",
    "Compilation failed because the compiler found your logic too complex for mere mortals.",
    "Segmentation fault in the compiler's sense of humor. Please try again.",
    "The compiler is on strike. It demands better jokes in comments.",
    "Your code is too perfect. The compiler suspects AI-generated content.",
    "It compiles on *my* machine...",
    "Maybe your code is haunted?",
    "KFC Crazy Thursday V me 50",
    "You forgot to pray before compiling. Be sincere.",
    "Oops! I don't like your code style. Try again.",
]
CHANCE = 2  # 1 in 2 chance


def main():
    # Execute the real g++ and capture its output (both stdout and stderr)
    try:
        result = subprocess.run(
            [REAL_GPP] + sys.argv[1:], capture_output=True, text=True, check=False
        )
        stdout = result.stdout
        stderr = result.stderr
        exit_code = result.returncode

    except FileNotFoundError:
        print(
            f"Error: Real g++ not found at {REAL_GPP}.  Adjust REAL_GPP in the script.",
            file=sys.stderr,
        )
        sys.exit(1)

    if exit_code != 0:
        # Process the stderr
        modified_stderr = ""
        for line in stderr.splitlines():
            if TARGET_ERROR_PATTERN in line:
                if random.randint(0, CHANCE - 1) == 0:
                    # Split the line at the error message
                    parts = line.split(TARGET_ERROR_PATTERN, 1)
                    # Keep the original colorful prefix but change the message
                    modified_stderr += parts[0] + TARGET_ERROR_PATTERN
                    modified_stderr += random.choice(APRIL_FOOLS_MESSAGES) + "\n"
                else:
                    modified_stderr += line + "\n"
            else:
                modified_stderr += line + "\n"

        # Print to stderr with original color codes preserved
        print(modified_stderr, file=sys.stderr, end="")
    else:
        # Print original stderr (usually empty)
        print(stderr, file=sys.stderr, end="")

    # Print original stdout (with colors preserved)
    print(stdout, end="")

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
