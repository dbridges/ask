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
