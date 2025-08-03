(use sh)

(defn kv? [ds]
  (or (struct? ds) (table? ds)))

(defn deep-merge [tbl & rest]
  (def rv (merge tbl))
  (loop [t :in rest
         [k v] :pairs t]
    (if (and (kv? (rv k)) (kv? v))
      (put rv k (deep-merge (rv k) v))
      (put rv k v)))
  rv)

(defn exit-error [err]
  (eprint err)
  (os/exit 1))

(defn expand-user [p]
  (if (string/has-prefix? "~" p)
    (string (os/getenv "HOME") (string/slice p 1 -1))
    p))

(defn cmd-exists? [cmd]
  ($? command -v ,cmd > [stdout :null]))

(defn image? [name]
  (or (string/has-suffix? ".jpg" name)
      (string/has-suffix? ".jepg" name)
      (string/has-suffix? ".png" name)
      (string/has-suffix? ".heic" name)
      (string/has-suffix? ".heif" name)
      (string/has-suffix? ".webp" name)))

(defn url? [name]
  (or (string/has-prefix? "http://" name)
      (string/has-prefix? "https://" name)))

(defn image-url? [name]
  (and (url? name) (image? name)))

