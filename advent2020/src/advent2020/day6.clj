(ns advent2020.day6
  (:require [clojure
             [set :as set]
             [string :as str]]))

(defn to-groups
  [file-name]
  (-> file-name
      (slurp)
      (str/split #"\n\n")))

(defn to-set
  [str]
  (->> str
       (re-seq #"\S")
       (into #{})))

(defn part-one
  [file-name]
  (->> file-name
       (to-groups)
       (map to-set)
       (map count)
       (reduce + 0)))

(defn find-common-declarations
  [lines]
  (->> lines
       (str/split-lines)
       (map to-set)
       (apply set/intersection)))

(defn part-two
  [file-name]
  (->> file-name
       (to-groups)
       (map find-common-declarations)
       (map count)
       (reduce + 0)))
