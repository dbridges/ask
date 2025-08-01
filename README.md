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
ask -c "Can you explain your previous response more?"
```

Full usage:

```
usage: ask [option] ...

Ask AI a question

 Optional:
     --clean                                 Clean sessions.
 -c, --continue                              Continue the previous session.
 -h, --help                                  Show this help message.
 -H, --history VALUE                         History file to use.
 -m, --model VALUE                           Model to use.
     --models                                List available models.
 -p, --persona VALUE=default                 Persona to use from config file.
     --system VALUE                          System message to use.
 -t, --temperature VALUE                     Temperature of the model.
```

## Glow Support

If [Glow](https://github.com/charmbracelet/glow) is installed results will be passed through it for presentation.

## Configuration

The program uses a `~/.ask/config.janet` file. Here is an example configuration for Ollama:

```janet
{:api
  {:url    "http://localhost:11434/v1"
   :model  "qwen2.5-coder:7b"
   :temperature 0.8}
 :personas {
    :default "You are an expert assistant. Answer the following questions with brevity. If asked about code, answer with only the code."
  }}
```

## Directory Structure

- `~/.ask/config.janet`: Configuration file for the program.
- `~/.ask/sessions/`: Directory for storing session files.
