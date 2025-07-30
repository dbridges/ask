(import spork/json)
(import spork/sh)

(defn parse-body [body]
  (json/decode body true true))

(defn get [url &opt auth-key]
  (def header-args @["-H" "Content-Type: application/json"])
  (when auth-key
      (array/push header-args "-H")
      (array/push header-args (string "Authorization: Bearer " auth-key)))
  (parse-body (sh/exec-slurp "curl" "-s" url)))

(defn post [url rawbody &opt auth-key]
  (def body (json/encode rawbody))
  (def header-args @["-H" "Content-Type: application/json"])
  (when auth-key
      (array/push header-args "-H")
      (array/push header-args (string "Authorization: Bearer " auth-key)))
  (->>
    (sh/exec-slurp "curl" "-s" "-d" (string body) url)
    (parse-body)))

