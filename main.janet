(import spork/argparse)
(import spork/sh)

(import ./config :as config)
(import ./session :as session)

(defn clean []
  (map os/rm (sh/list-all-files config/session-dir))
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
      :default {:kind :accumulate
                :required true}))
  (if (or (nil? args) (empty? (args :default))) (os/exit))
  (def history-path
    (or (args "history")
        (if (args "continue")
          (session/most-recent-session))))
  (def session
    (session/new history-path))
  (session/ask session (string/join (args :default) " ")))
