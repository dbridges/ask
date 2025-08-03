(import spork/path)
(use sh)
(import ./http :as http)
(use ./util)

(defn mimetype [fname]
  ($<_ file --mime-type -b ,fname))

(defn content-type [fname]
  (let [ext (string/ascii-lower (path/posix/ext fname))]
    (cond
      (image-url? fname) "image_url"
      (url? fname)       "url"
      (image? fname)     "image"
      "text")))

(defn base64-data [fname]
  ($<_ base64 -i ,fname))

(defn text-data [fname]
  (string "File Name: " fname "\nFile Content:\n\n" (slurp fname)))

(defn web-data [url]
  (var content ($<_ curl -s ,url))

  (when (cmd-exists? "pandoc")
    (set content ($<_ pandoc -f html -t markdown <,content)))

  (string "URL: " url "\nPage Content:\n\n" content))

(defn base64-image-data [fname]
  (def data (base64-data fname))
  (string "data:" (mimetype fname) ";base64," data))

(defn file-message [fname]
  (def t (content-type fname))
  (case t
    "image_url" {:type "image_url" :image_url {:url fname}}
    "image"     {:type "image_url" :image_url {:url (base64-image-data fname)}}
    "url"       {:type "text" :text (web-data fname)}
    "text"      {:type "text" :text (text-data fname)}))

(defn message-content [prompt files]
  (if (empty? files)
    prompt
    [{:type "text" :text prompt} ;(map file-message files)]))

(defn ask [client prompt &keys {:history history :files files}]
  (def messages [{:role "system" :content (client :system)}
                 ;(or history [])
                 {:role "user" :content (message-content prompt files)}])

  (def resp 
    (http/post
      (string (client :url) "/chat/completions")
      {:model       (client :model)
       :messages    messages
       :stream      false
       :temperature (client :temperature)}
      (client :auth-key)))

  (def resp-message (get-in resp [:choices 0 :message :content]))

  (when (nil? resp-message)
    (exit-error (pp resp)))

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
