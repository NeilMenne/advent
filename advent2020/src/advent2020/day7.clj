(ns advent2020.day7
  (:require [clojure.string :as str]))

(defn to-sub-bag
  [str]
  (if (nil? str)
    []
    (let [[num type] (str/split str #" " 2)]
      [type (Integer/parseInt num)])))

(defn to-bag-rule
  [l]
  (let [[k vs] (str/split l #" bags contain ")
        vs (->> vs
                (re-seq #"\d \w+ \w+")
                (map to-sub-bag))]
    [k vs]))

(defn invert-map
  "reverse the graph of outer->inner bags to inner->outer for finding all bags
  that can reach a particular inner bag"
  [bag-rules]
  (reduce (fn [acc [outer sub-bags]]
            (reduce #(update %1 (first %2) conj outer) acc sub-bags))
          {}
          bag-rules))

(defn reachable-bags
  "starting with the desired color, find all bags that are immediately reachable,
  then all bags that can reach those, etc until no new bags can be found"
  [inv-bag-map desired-color]
  (loop [acc (into #{} (inv-bag-map desired-color))]
    (if-let [new-bags (->> acc
                           (map inv-bag-map)
                           (flatten)
                           (filter some?)
                           (filter #(not (contains? acc %)))
                           (seq))]
      (recur (into acc new-bags))
      acc)))

(defn part-one
  [file-name]
  (let [bag-graph (->> file-name
                       (slurp)
                       (str/split-lines)
                       (map to-bag-rule)
                       (invert-map))]
    (count (reachable-bags bag-graph "shiny gold"))))

(defn calc-weight
  "weighted depth first traversal of the map of bags to sub-bags"
  [type bag-map]
  (if-let [sub-bags (seq (bag-map type))]
    (reduce (fn [wgt [subtype subwgt]]
              (+ wgt subwgt (* subwgt (calc-weight subtype bag-map))))
            0
            sub-bags)
    0))

(defn part-two
  [file-name]
  (->> file-name
       (slurp)
       (str/split-lines)
       (map to-bag-rule)
       (into {})
       (calc-weight "shiny gold")))
