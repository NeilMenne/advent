(ns advent2020.day2
  (:require [clojure.string :as str]))

(defn- to-int
  [i]
  (Integer/parseInt i))

(defn- parse-line
  "translate a line into the min/max tuple, the target character (as a string),
  and the password

  i.e. '1-3 a: abcde' into [[1 3] 'a' 'abcde']"
  [line]
  (let [[low-high-str char pass] (str/split line #" ")
        [low-str high-str] (str/split low-high-str #"-")
        char (.charAt char 0)]
    [[(to-int low-str) (to-int high-str)] char pass]))

(def parse-lines (partial map parse-line))

(defn read-input
  [file-name]
  (-> file-name
      (slurp)
      (str/split #"\n")
      (parse-lines)))

(defn- between?
  [freq min max]
  (when freq
    (<= min freq max)))

(defn p1-valid?
  "part one validity: the required character should appear between min and max
  number of times (inclusive on both sides)"
  [[[min max] req pass]]
  (-> pass
      (char-array)
      (frequencies)
      (get req)
      (between? min max)))

(defn part-one
  "count the number of passwords that are valid"
  [lines]
  (->> lines
       (filter p1-valid?)
       (count)))

(def xor not=)

(defn p2-valid?
  "part two validity: the required character must appear at exactly one of the
  specified positions (low or high); passwords are specified in 1-based array
  values"
  [[[low high] req pass]]
  (let [lchar (.charAt pass (dec low))
        hchar (.charAt pass (dec high))]
    (xor (= lchar req) (= hchar req))))

(defn part-two
  "count the number of valid passwords by the new criteria"
  [lines]
  (->> lines
       (filter p2-valid?)
       (count)))
