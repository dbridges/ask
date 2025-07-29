(import spork/argparse)
(import spork/sh)

(import ./config :as config)
(import ./session :as session)
(import ./ollama :as ollama)
(use ./util)

(defn clean []
  (map os/rm (sh/list-all-files config/session-dir))
  (os/exit))

(defn models []
  (def client (ollama/new ((config/make) :ollama)))
  (loop [{:name name} :in (client :models)]
    (print name))
  (os/exit))

(defn main [&]
  (def args
    (or 
      (argparse/argparse
        "Ask AI a question"
        "clean"    {:kind          :flag
                    :help          "Clean sessions."
                    :default       false
                    :required      false
                    :short-circuit true
                    :action        clean}
        "models"   {:kind          :flag
                    :help          "List available models."
                    :default       false
                    :required      false
                    :short-circuit true
                    :action        models}
        "continue" {:kind     :flag
                    :short    "c"
                    :help     "Continue the previous session."
                    :default  false
                    :required false}
        "history"  {:kind     :option
                    :short    "H"
                    :help     "History file to use."
                    :default  nil
                    :required false}
        "persona"  {:kind     :option
                    :short    "p"
                    :help     "Persona to use from config file."
                    :default  nil
                    :required false}
        "model"    {:kind     :option
                    :short    "m"
                    :help     "Model to use."
                    :default  nil
                    :required false}
        "system"   {:kind     :option
                    :help     "System message to use."
                    :default  nil
                    :required false}
        "think"    {:kind     :flag
                    :help     "Enable thinking."
                    :default  nil
                    :required false}
        "no-think" {:kind     :flag
                    :help     "Disable thinking."
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
                :think (or (args "think")
                           (if (nil? (args "no-think")) nil (not (args "no-think"))))))

  (def session
    (session/new :history-path history-path :config config))

  (session/ask session prompt))
