#!/usr/bin/env bb

(require '[babashka.process :as process]
         '[clojure.string :as str])

(-> {:devs {"109069886+alberto-of@users.noreply.github.com" "ALBERTO"
            "32617+amiorin@users.noreply.github.com" "AMIORIN"}}
    ((fn [{:keys [devs]}]
       (let [ssh-add-cmd-output (:out (process/shell {:out :string} "ssh-add -l"))]
         (reduce-kv (fn [a k v]
                      (if (str/includes? ssh-add-cmd-output k)
                        v
                        a)) nil devs))))
    println)
