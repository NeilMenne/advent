(ns advent2020.day5
  (:require [clojure
             [string :as str]
             [set :as set]]))

(defn lower?
  [char]
  (#{\F \L} char))

(defn new-pos
  [low high]
  (int (/ (+ low high) 2)))

(defn binary-search
  [chars max]
  (loop [low 0
         high max
         xs chars]
    (let [[x & xs] xs]
      (cond
        (empty? xs) (if (lower? x) low high)
        (lower? x)  (recur low (new-pos low high) xs)
        true        (recur (inc (new-pos low high)) high xs)))))

(defn line->seat-id
  [line]
  (let [[row-chars col-chars] (->> line (char-array) (split-at 7))
        row-num (binary-search row-chars 127)
        col-num (binary-search col-chars 7)]
    (+ (* row-num 8) col-num)))

(defn file->seat-ids
  [file-name]
  (let [lines (-> file-name
                  (slurp)
                  (str/split-lines))]
    (map line->seat-id lines)))

(defn part-one
  [file-name]
  (apply max (file->seat-ids file-name)))

(defn missing-num
  [seq]
  (let [all-ids (into #{} (range (first seq) (last seq)))
        seq-ids (into #{} seq)]
    (-> all-ids
        (set/difference seq-ids)
        (first))))

(defn part-two
  [file-name]
  (->> file-name
       (file->seat-ids)
       (sort)
       (missing-num)))
