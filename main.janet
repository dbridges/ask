(import spork/argparse)
(import spork/sh)

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
        "models"      {:kind          :flag
                       :help          "List available models."
                       :default       false
                       :required      false
                       :short-circuit true
                       :action        models}
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
        :default {:kind :accumulate})
      {}))

  (if (or (has-value? (dyn :args) "-h") (has-value? (dyn :args) "--help"))
    (os/exit))

  (def prompt 
    (if (nil? (args :default))
      (file/read stdin :all)
      (string/join (args :default) " ")))


  (def history-path
    (or (args "history")
        (if (args "continue")
          (session/most-recent-session))))

  (when (and (args "system") (args "persona"))
    (exit-error "Cannot provide both 'system' and 'persona' arguments"))

  (def config (config/make
                :model (args "model")
                :persona (args "persona")
                :system (args "system")
                :temperature (args "temperature")))

  (def session
    (session/new :history-path history-path :config config))

  (session/ask session prompt))
