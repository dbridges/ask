(declare-project
  :name "ask"
  :description "Ask an LLM a question"
  :dependencies ["spork"])

(declare-executable
  :name "ask"
  :entry "main.janet"
  :install true)
