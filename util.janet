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
