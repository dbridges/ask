(import ./http :as http)
(use ./util)

(defn ask [client prompt &opt history]
  (def messages (if (nil? history)
                  [{:role "system" :content (client :system)}
                   {:role "user" :content prompt}]
                  [{:role "system" :content (client :system)}
                   ;history
                   {:role "user" :content prompt}]))

  (def resp 
    (http/post
      (string (client :url) "/chat")
      {:model    (client :model)
       :messages messages
       :stream   false
       :think    (client :think)
       :system   (client :system)
       :options  (client :options)}
      (client :auth-key)))

  (if (resp :error)
    (exit-error (resp :error)))

  {:response ((resp :message) :content)
   :history [;(drop 1 messages) (resp :message)]})

(defn models [client]
  ((http/get
    (string (client :url) "/tags" (client :auth-key))) :models))

(defn new [&opt client]
  (fn [command & args]
    (case command
      :ask    (ask client ;args)
      :models (models client)
      (error (string "Unknown command '" command "' for client")))))
