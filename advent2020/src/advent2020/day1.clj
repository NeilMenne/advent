(ns advent2020.day1
  (:require [clojure.string :as str]
            [clojure.math.combinatorics :as combo]))

(defn- to-int
  [i]
  (Integer/parseInt i))

(defn read-input
  [file-name]
  (->> file-name
       (slurp)
       (str/split-lines)
       (map to-int)))

(defn part-one
  "find a pair of ints that add up to 2020

  multiply the pair and return a single copy
  "
  [list-of-ints]
  (first
   (for [x list-of-ints
         y list-of-ints
         :when (= (+ x y) 2020)]
     (* x y))))

(defn part-two
  "find a triple of ints that add up to 2020

  multiply the triple and return a single copy
  "
  [list-of-ints]
  (first
   (for [x list-of-ints
         y list-of-ints
         z list-of-ints
         :when (= (+ x y z) 2020)]
     (* x y z))))


;; for fun, let's do it with combinatorics lib to see if we can eliminate the
;; duplicates in a more concise manner

(defn find-combination
  [size list-of-ints]
  (let [combo (combo/combinations list-of-ints size)]
    (->> combo
         (filter #(= (apply + %) 2020))
         (first)
         (reduce * 1))))

(def part-one-combo (partial find-combination 2))
(def part-two-combo (partial find-combination 3))
