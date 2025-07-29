(import ./ollama :as ollama)
(import ./config :as config)

(import spork/path)

(def sep "\n\n---\n\n")

(defn make-session-path []
  (path/join config/session-dir
             (string (os/strftime "%Y-%m-%d %H.%M.%S" nil true) ".md")))

(defn most-recent-session []
  (def f (last (sort (os/dir config/session-dir))))
  (if f
    (path/join config/session-dir f)
    nil))

(defn read-history [p]
  (if (os/stat p)
    (as->
      (slurp p) $
      (string/split sep $)
      (seq [[i m] :pairs $]
        {:role    (if (zero? (mod i 2)) "user" "assistant")
         :content (string/trim m)}))))

(defn write-history [p history]
  (as->
    (seq [{:content content} :in history] content) $
    (string/join $ sep)
    (spit p (string $ "\n"))))

(defn new [&keys {:history-file-path history-file-path :config config}]
  (def p (or history-file-path (make-session-path)))
  {:path    p
   :client  (ollama/new (config :ollama))
   :history (read-history p)})

(defn ask [session query]
  (def resp ((session :client) :ask query (session :history)))
  (print (resp :response))
  (write-history (session :path) (resp :history)))
