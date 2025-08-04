(declare-project
  :name "ask"
  :description "Ask an LLM a question"
  :url "https://github.com/dbridges/ask"
  :author "Dan Bridges"
  :dependencies ["spork" "sh" "https://github.com/dbridges/jty"])

(declare-executable
  :name "ask"
  :entry "main.janet"
  :install true)
