(import spork/path)
(use ./util)

(def default-config
  {:ollama
    {:url    "http://localhost:11434"
     :system "You are an expert assistant. Answer the following questions with brevity. If asked about code, answer with only the code."
     :model  "qwen2.5-coder:7b"
     :think  false}
    :personas {}})


(def dir (path/join (os/getenv "HOME") ".ask"))
(def session-dir (path/join dir "sessions"))
(def file (path/join dir "config.janet"))

(os/mkdir dir)
(os/mkdir session-dir)

(defn make [&keys {:model   model
                   :persona persona
                   :think   think
                   :system  system}]
  (def user-config
    (if (os/stat file)
          (eval-string (slurp file))
          @{}))

  (def args-config @{:ollama @{}})

  (if model
    (put (args-config :ollama) :model model))

  (if system
    (put (args-config :ollama) :system system))

  (if (not (nil? think))
    (put (args-config :ollama) :think think))

  (if persona
    (if-let [system-prompt ((user-config :personas) (keyword persona))]
      (put (args-config :ollama) :system system-prompt)
      (exit-error (string persona " persona not found"))))

  (deep-merge default-config user-config args-config))
