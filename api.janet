(import ./http :as http)
(use ./util)

(defn ask [client prompt &opt history]
  (def messages [{:role "system" :content (client :system)}
                 ;(or history [])
                 {:role "user" :content prompt}])

  (def resp 
    (http/post
      (string (client :url) "/chat/completions")
      {:model       (client :model)
       :messages    messages
       :stream      false
       :temperature (client :temperature)}
      (client :auth-key)))

  (def resp-message
    (try
      (((first (resp :choices)) :message) :content)
      ([err]
       (exit-error (pp resp)))))

  {:response resp-message
   :history [;(drop 1 messages) {:content resp-message :role "assistant"}]})

(defn models [client]
  ((http/get
    (string (client :url) "/models") (client :auth-key)) :data))

(defn new [&opt client]
  (fn [command & args]
    (case command
      :ask    (ask client ;args)
      :models (models client)
      (error (string "Unknown command '" command "' for client")))))
