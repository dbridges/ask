# Ask

Ask an LLM a question using Janet and a compatible OpenAI API endpoint (Ollama, etc).

## Installation

Ensure you have Janet installed. Then, clone this repository and build the executable:

```sh
jpm install
```

## Usage

Run the `ask` executable with your question or use the `-c` flag to continue a previous session.

```sh
ask "What is the capital of Peru?"
```

Or:

```sh
ask -c "Can you explain your previous response more?"
```

## Options

- `-h, --help`: Show help information.
- `-c, --continue`: Continue the previous session.
- `-H, --history <file>`: Use a specific history file.
- `-p, --persona <name>`: Use a specific persona from the config file.
- `-m, --model <name>`: Use a specific model.

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
