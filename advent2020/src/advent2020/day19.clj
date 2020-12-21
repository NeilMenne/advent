(ns advent2020.day19
  (:require [clojure.string :as str]
            [instaparse.core :as instaparse]))

(def input (slurp "resources/day_19_input.txt"))

(defn part-one
  [input]
  (let [[rules msgs] (str/split input #"\n\n")
        parser       (instaparse/parser rules :start :0)
        msgs         (str/split-lines msgs)]
    (->> msgs
         (map (partial instaparse/parse parser))
         (remove instaparse/failure?)
         (count))))

(defn with-modifications
  [rule-str]
  (-> rule-str
      (str/replace #"8: 42" "8: 42 | 42 8")
      (str/replace #"11: 42 31" "11: 42 31 | 42 11 31")))

(defn part-two
  [input]
  (let [[rules msgs] (str/split input #"\n\n")
        rules        (with-modifications rules)
        parser       (instaparse/parser rules :start :0)
        msgs         (str/split-lines msgs)]
    (->> msgs
         (map (partial instaparse/parse parser))
         (remove instaparse/failure?)
         (count))))
