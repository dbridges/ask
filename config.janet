(import spork/path)
(use ./util)

(def default-config
  {:ollama
    {:url    "http://localhost:11434"
     :system "You are an expert assistant. Answer the following questions with brevity. If asked about code, answer with only the code."
     :model  "qwen2.5-coder:7b"}})


(def dir (path/join (os/getenv "HOME") ".ask"))
(def session-dir (path/join dir "sessions"))
(def file (path/join dir "config.janet"))

(os/mkdir dir)
(os/mkdir session-dir)

(defn make [&keys {:model model}]
  (def user-config
    (if (os/stat file)
          (eval-string (slurp file))
          @{}))

  (def args-config @{:ollama @{}})

  (if model
    (put (args-config :ollama) :model model))

  (deep-merge default-config user-config args-config))
