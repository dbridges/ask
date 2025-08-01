(import spork/json)
(use sh)

(defn parse-body [body]
  (json/decode body true true))

(defn get [url &opt auth-key]
  (def header-args @[])
  (when auth-key
      (array/push header-args "-H")
      (array/push header-args (string "Authorization: Bearer " auth-key)))
  (parse-body ($< curl -s ;header-args ,url)))

(defn post [url rawbody &opt auth-key]
  (def body (string (json/encode rawbody)))
  (def header-args @["-H" "Content-Type: application/json"])
  (when auth-key
      (array/push header-args "-H")
      (array/push header-args (string "Authorization: Bearer " auth-key)))
  (->>
    ($< curl -s ;header-args -d ,body ,url)
    (parse-body)))

