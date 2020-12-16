(ns advent2020.day3
  (:require [clojure.string :as str]))

(defn read-input
  [file-name]
  (-> file-name
      (slurp)
      (str/split-lines)))

(defn to-sparse-row
  [line]
  (loop [curr-pos 0
         acc #{}]
    (if-let [next-pos (str/index-of line "#" curr-pos)]
      (recur (inc next-pos)
             (conj acc next-pos))
      acc)))

(defn tree?
  [pos sparse-row row-len]
  (let [in-range (if (> pos row-len) (mod pos row-len) pos)]
    (number? (sparse-row in-range))))

(defn traverse-slope
  "from the input lines, do the following:
   1. convert the lines into a sparse representation of just the trees
   2. drop the first m rows as they will be effectively skipped
   3. take every mth row so that rows that are not used are not considered
   4. see if there is a tree collision on the remaining rows
   5. count the number of collisions"
  [lines [n m]]
  (let [len (count (first lines))
        x-pos-seq (->> (range)
                       (filter #(= 0 (mod % n)))
                       (drop 1))]
    (->> lines
         (map to-sparse-row)
         (drop m)
         (take-nth m)
         (map #(tree? %1 %2 len) x-pos-seq)
         (filter true?)
         (count))))

(defn part-one
  "move right 3 down 1"
  [lines]
  (traverse-slope lines [3 1]))

(defn part-two
  "use multiple alternative moving configurations to try multiple traversals;
  multiply the results together upon completion"
  [lines]
  (let [configs [[1 1] [3 1] [5 1] [7 1] [1 2]]]
    (->> configs
         (map #(traverse-slope lines %))
         (reduce * 1))))
