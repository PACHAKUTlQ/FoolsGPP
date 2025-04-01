package main

import (
	"bytes"
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

func findRealGPP() (string, error) {
	// First try same directory as our executable
	exePath, err := os.Executable()
	if err != nil {
		return "", err
	}
	exeDir := filepath.Dir(exePath)
	sameDirPath := filepath.Join(exeDir, "g++real.exe")
	if _, err := os.Stat(sameDirPath); err == nil {
		return sameDirPath, nil
	}

	// Then try PATH
	path, err := exec.LookPath("g++real.exe")
	if err == nil {
		return path, nil
	}

	return "", fmt.Errorf("could not find g++real.exe in executable directory or PATH")
}

const (
	targetErrorToken = ": error: "
	chance           = 2 // 1 in 2 chance of replacing an error
)

var aprilFoolsMessages = []string{
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
}

func main() {
	rand.Seed(time.Now().UnixNano())

	realGPP, err := findRealGPP()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		fmt.Fprintf(os.Stderr, "Please rename your original g++.exe to g++real.exe\n")
		os.Exit(1)
	}

	cmd := exec.Command(realGPP, os.Args[1:]...)

	var stdoutBuf, stderrBuf bytes.Buffer
	cmd.Stdout = &stdoutBuf
	cmd.Stderr = &stderrBuf

	err = cmd.Run()
	exitCode := cmd.ProcessState.ExitCode()

	if exitCode != 0 {
		modifiedStderr := ""
		for _, line := range strings.Split(stderrBuf.String(), "\n") {
			if strings.Contains(line, targetErrorToken) && rand.Intn(chance) == 0 {
				parts := strings.SplitN(line, targetErrorToken, 2)
				modifiedStderr += parts[0] + targetErrorToken
				modifiedStderr += aprilFoolsMessages[rand.Intn(len(aprilFoolsMessages))] + "\n"
			} else {
				modifiedStderr += line + "\n"
			}
		}
		fmt.Fprint(os.Stderr, modifiedStderr)
	} else {
		fmt.Fprint(os.Stderr, stderrBuf.String())
	}

	fmt.Print(stdoutBuf.String())
	os.Exit(exitCode)
}
