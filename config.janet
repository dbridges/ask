(import spork/path)
(use ./util)

(def default-config
  {:api {
     :url    "http://localhost:11434/v1"
     :model  "qwen2.5-coder:7b"
   }
   :personas {
      :default "You are an expert assistant. Answer the following request with brevity."
   }})

(def dir (path/join (os/getenv "HOME") ".ask"))
(def session-dir (path/join dir "sessions"))
(def file (path/join dir "config.janet"))

(os/mkdir dir)
(os/mkdir session-dir)

(defn make [&keys {:model       model
                   :persona     persona
                   :system      system
                   :temperature temperature}]
  (def user-config
    (if (os/stat file)
          (eval-string (slurp file))
          @{}))

  (def args-config @{:api @{}})

  (if model
    (put (args-config :api) :model model))

  (if temperature
    (put (args-config :api) :temperature (scan-number temperature)))

  (if persona
    (if-let [personas (deep-merge (default-config :personas) (user-config :personas))
             system-prompt (personas (keyword persona))]
      (put (args-config :api) :system system-prompt)
      (exit-error (string persona " persona not found"))))

  (if system
    (put (args-config :api) :system system))

  (deep-merge default-config user-config args-config))
