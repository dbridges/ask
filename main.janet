(import spork/argparse)
(import spork/sh)
(import spork/path)
(use sh)

(import ./config :as config)
(import ./session :as session)
(import ./api :as api)
(use ./util)

(defn clean []
  (map os/rm (sh/list-all-files config/session-dir))
  (os/exit))

(defn models []
  (def client (api/new ((config/make) :api)))
  (loop [{:id name} :in (client :models)]
    (print name))
  (os/exit))

(defn print-markdown [md]
  (if ($? command -v glow > [stdout :null])
    ($ echo ,md | glow)
    (print md)))

(defn config []
  ($ ,(os/getenv "EDITOR") ,config/file)
  (os/exit))

(defn main [&]
  (def args
    (or 
      (argparse/argparse
        "Ask AI a question"
        "clean"       {:kind          :flag
                       :help          "Clean sessions."
                       :default       false
                       :required      false
                       :short-circuit true
                       :action        clean}
        "config"      {:kind          :flag
                       :help          "Open the config file for editing."
                       :default       false
                       :required      false
                       :short-circuit true
                       :action        config}
        "models"      {:kind          :flag
                       :help          "List available models."
                       :default       false
                       :required      false
                       :short-circuit true
                       :action        models}
        "ascii"       {:kind     :flag
                       :help     "Output without pretty markdown formatting."
                       :default  false
                       :required false}
        "continue"    {:kind     :flag
                       :short    "c"
                       :help     "Continue the previous session."
                       :default  false
                       :required false}
        "history"     {:kind     :option
                       :short    "H"
                       :help     "History file to use."
                       :default  nil
                       :required false}
        "persona"     {:kind     :option
                       :short    "p"
                       :help     "Persona to use from config file."
                       :default  :default
                       :required false}
        "model"       {:kind     :option
                       :short    "m"
                       :help     "Model to use."
                       :default  nil
                       :required false}
        "system"      {:kind     :option
                       :help     "System message to use."
                       :default  nil
                       :required false}
        "temperature" {:kind     :option
                       :short    "t"
                       :help     "Temperature of the model."
                       :default  nil
                       :required false}
        "include"     {:kind     :accumulate
                       :short    "i"
                       :help     "Add a file or glob of files to be included in the chat. (Only image and text based files supported)"
                       :default  nil
                       :required false}
        :default {:kind :accumulate})
      {}))

  (if (or (has-value? (dyn :args) "-h") (has-value? (dyn :args) "--help"))
    (os/exit))

  # Handle subcommands for convenience
  (when (= (length (args :default)) 1)
    (case (first (args :default))
      "clean"  (clean)
      "config" (config)
      "models" (models)))

  (def prompt 
    (if (nil? (args :default))
      (file/read stdin :all)
      (string/join (args :default) " ")))

  (def history-path
    (or (args "history")
        (if (args "continue")
          (session/most-recent-session))))

  (def config (config/make
                :model (args "model")
                :persona (args "persona")
                :system (args "system")
                :temperature (args "temperature")))

  (def files
    (flatten
      (map |(glob (expand-user $))
           (get args "include" []))))

  (loop [f :in files]
    (when (not (sh/exists? f))
      (exit-error (string f " does not exist."))))

  (def session
    (session/new
      :history-path history-path
      :config config
      :files files))

  (def response (session/ask session prompt))

  (if (args "ascii")
    (print response)
    (print-markdown response)))
