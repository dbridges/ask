(import spork/path)

(def dir (path/join (os/getenv "HOME") ".ask"))
(def session-dir (path/join dir "sessions"))
(def file (path/join dir "config.janet"))

(os/mkdir dir)
(os/mkdir session-dir)

(def config 
  (if (os/stat file)
      (eval-string (slurp file))
      {}))
