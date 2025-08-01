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

(defn ask [session query]
  (def resp ((session :client)
             :ask query
             :history (session :history)
             :files (session :files)))
  (write-history (session :path) (resp :history))
  (resp :response))
