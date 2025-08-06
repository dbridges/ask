# Ask

Ask an LLM a question using Janet and a compatible OpenAI API endpoint (Ollama, etc).

## Installation

Ensure you have Janet installed. Then, clone this repository and build the executable:

```sh
jpm install
```

## Usage

Run the `ask` executable with your question and use the `-c` flag to continue a previous session.

```sh
ask "What is the capital of Peru?"
```

To ask a follow up question use `-c`:

```sh
ask -c "Can you explain your previous response?"
```

Add a picture to your message:

```sh
ask -i path/to/image.png "Describe this image"
```

Add a set of text files to your message:

```sh
ask -i path/to/source/*.janet "Which file contains the api code?"
```

Ask about a webpage:

```sh
ask -i https://janet-lang.org/index.html "What is this webpage about?"
```

Have an LLM review your code changes:

```sh
git diff | ask --system "review the following git diff"
```

Generate a commit message:

```sh
git diff | ask --system "Provide only a short commit message summarizing the changes in this git diff"
```

Full usage:

```
usage: main.janet [option] ...

Ask AI a question

 Optional:
     --ascii                                 Output without pretty markdown formatting.
     --clean                                 Clean sessions.
 -c, --continue                              Continue the previous session.
 -h, --help                                  Show this help message.
 -H, --history VALUE                         History file to use.
 -i, --include VALUE                         Add a file, glob of files or url to be included in the chat.
                                             (Only image and text based files supported)
 -m, --model VALUE                           Model to use.
     --models                                List available models.
 -p, --persona VALUE=default                 Persona to use from config file.
     --system VALUE                          System message to use.
 -t, --temperature VALUE                     Temperature of the model.
```

`clean`, `models`, `config` can also be run as sub-commands, e.g. `ask clean`

## Glow Support

If [Glow](https://github.com/charmbracelet/glow) is installed results will be passed through it for presentation.

## Pandoc Support

If you include a webpage url using `ask -i https://github.com/dbridges/ask "What does this tool do"?` and [pandoc](https://pandoc.org/MANUAL.html) is installed, the page will be converted to markdown before being sent to the LLM.

## Configuration

The program config is stored in `~/.ask/config.janet`. Configurations are stored as personas. Multiple personas can be referenced as command line arguments, their attributes will be merged in the order specified. Here is an example config:

```janet
{
  :default {
    :url "http://localhost:11434/v1"
    :model "qwen2.5-coder:7b"
    :temperature 0.8
    :system "You are an expert assistant being accessed from the command line. Answer the following request:"
  }
  :gemini {
    :url "https://generativelanguage.googleapis.com/v1beta/openai"
    :model "gemini-2.5-flash"
    :auth-key "YOUR_AUTH_KEY"
  }
  :claude {
    :url "https://api.anthropic.com/v1"
    :model "claude-sonnet-4-20250514"
    :auth-key "YOUR_AUTH_KEY"
  }
  :review {
    :system "You are an expert programmer. Review the supplied git diff. Provide succinct feedback addressing complexity, security, and accuracy of the code changes."
    :temperature 0.4
  }
}
```

With this config, you can run Claude as a reviewer using:

```
git diff | ask -p claude -p review
```

If no configs are specified on the command line `ask` will use the `:default` config.

## Directory Structure

- `~/.ask/config.janet`: Configuration file for the program.
- `~/.ask/sessions/`: Directory for storing session files.
