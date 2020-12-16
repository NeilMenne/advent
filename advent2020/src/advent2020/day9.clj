(ns advent2020.day9
  (:require [clojure.string :as str]))

(def input
  (->> "resources/day_9_input.txt"
       (slurp)
       (str/split-lines)
       (mapv #(Long/parseLong %))))

(defn in-window?
  [v nums]
  (first
   (for [x nums
         y nums
         :when (and (not= x y)
                    (= (+ x y) v))]
     [x y])))

(defn find-weakness
  [nums preamble-len]
  (let [[preamble remaining] (split-at preamble-len nums)]
    (loop [remaining remaining
           window    (into [] preamble)]
      (if (in-window? (first remaining) window)
        (recur (drop 1 remaining)
               (-> window (subvec 1) (conj (first remaining))))
        (first remaining)))))

(defn part-one
  []
  (find-weakness input 25))

(defn contiguous-subvecs
  [nums]
  (let [len (count nums)]
    (for [x (range 0 len)
          y (range x len)
          :when (>= (- y x) 2)]
      (subvec nums x y))))

(defn sum [xs] (apply + xs))

(defn part-two
  []
  (let [weakness (find-weakness input 25)
        subvec   (->> input
                      (contiguous-subvecs)
                      (filter #(= weakness (sum %)))
                      (first)
                      (sort))]
    (+ (first subvec) (last subvec))))
