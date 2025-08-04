(import spork/json)
(import spork/path)
(import ./api :as api)
(import ./config :as config)

(defn make-session-path []
  (path/join config/session-dir
             (string (os/strftime "%Y-%m-%d %H.%M.%S" nil true) ".json")))

(defn most-recent-session []
  (def f (last (sort (os/dir config/session-dir))))
  (if f
    (path/join config/session-dir f)
    nil))

(defn read-history [p]
  (if (os/stat p)
    (json/decode (slurp p))))

(defn write-history [p history]
  (spit p (json/encode history)))

(defn new [&keys {:history-path history-path :config config :files files}]
  (def p (or history-path (make-session-path)))
  {:path    p
   :client  (api/new (config :api))
   :history (read-history p)
   :files   files})

(def tool-call-peg
  ~{:block-start   (* "```" (+ "sh\n" "bash\n"))
    :block-end     (* "```")
    :not-block-end (if-not :block-end 1)
    :code-block    (* :block-start (/ (<- (some :not-block-end)) ,string/trim) :block-end)
    :main          (some (+ :code-block 1))})

(defn response-tool-calls [content]
  (peg/match tool-call-peg content))

(defn ask [session query]
  (def resp ((session :client)
             :ask     query
             :history (session :history)
             :files   (session :files)))
  (write-history (session :path) (resp :history))
  {:content    (resp :response)
   :tool-calls (response-tool-calls (resp :response))})
