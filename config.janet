(import spork/path)
(use ./util)

(def default-config
  {:model       "qwen2.5-coder:7b"
   :temperature 0.8
   :url         "http://localhost:11434/v1"
   :auth-key    nil
   :system      "You are an expert assistant being accessed from the command line. Answer the following request with brevity. If asked for CLI commands, return the commands in fenced code blocks."})

(def dir (path/join (os/getenv "HOME") ".ask"))
(def session-dir (path/join dir "sessions"))
(def file (path/join dir "config.janet"))

(os/mkdir dir)
(os/mkdir session-dir)

(defn make [&keys args]
  (def user-config
    (if (os/stat file)
          (eval-string (slurp file))
          @{}))

  (reduce
    (fn [acc el] (merge acc (get user-config el {})))
    (merge default-config args)
    [:default ;(get args :personas [])]))
