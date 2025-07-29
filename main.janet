(import spork/argparse)
(import spork/sh)

(import ./config :as config)
(import ./session :as session)
(import ./ollama :as ollama)

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
      "model"    {:kind     :option
                  :short    "m"
                  :help     "Model to use."
                  :default  nil
                  :required false}
      :default {:kind :accumulate
                :required true}))
  (if (or (nil? args) (empty? (args :default))) (os/exit))

  (def history-path
    (or (args "history")
        (if (args "continue")
          (session/most-recent-session))))

  (def config (config/make :model (args "model")))

  (pp config)

  (def session
    (session/new :history-path history-path :config config))

  (session/ask session (string/join (args :default) " ")))
