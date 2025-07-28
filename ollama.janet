(import ./http :as http)

(def default-config
  {:url   "http://localhost:11434"
   :system "You are an expert assistant. Answer the following questions with brevity. If asked about code, answer with only the code."
   :model "qwen2.5-coder:7b"})

(defn ask [client prompt &opt history]
  (def messages (if (nil? history)
                  [{:role "system" :content (client :system)}
                   {:role "user" :content prompt}]
                  [{:role "system" :content (client :system)}
                   ;history
                   {:role "user" :content prompt}]))

  (def resp 
    (http/post
      (string (client :url) "/api/chat")
      {:model    (client :model)
       :messages messages
       :stream   false
       :system   (client :system)}))

  {:response ((resp :message) :content)
   :history [;(drop 1 messages) (resp :message)]})

(defn new [&opt cfg]
  (def client
    (merge default-config (or cfg {})))
  (fn [command & args]
    (case command
      :ask (ask client ;args)
      (error (string "Unknown command '" command "' for client")))))
