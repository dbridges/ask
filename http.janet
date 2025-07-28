(import spork/json)
(import spork/sh)

(defn parse-body [body]
  (json/decode body true true))

(defn get [url]
  (parse-body (sh/exec-slurp "curl" "-s" url)))

(defn post [url rawbody]
  (def body (json/encode rawbody))
  (->>
    (sh/exec-slurp "curl" "-s" "-d" (string body) url)
    (parse-body)))

