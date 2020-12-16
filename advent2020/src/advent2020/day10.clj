(ns advent2020.day10
  (:require [clojure.string :as str]
            [clojure.set :as set]))

(def input
  (let [raw (->> "resources/day_10_input.txt"
                 (slurp)
                 (str/split-lines)
                 (map #(Integer/parseInt %)))]
    (-> raw
        (conj 0)
        (conj (+ 3 (apply max raw)))
        (sort))))

(defn dist [[x y]] (- y x))

(defn map-values
  [f m]
  (reduce-kv #(assoc %1 %2 (f %3)) {} m))

(defn part-one
  [nums]
  (let [dists (->> nums
                   (partition 2 1)
                   (map dist)
                   (frequencies))]
    (* (get dists 1) (get dists 3))))

(defn reach
  "returns the unordered set of numbers that are in the input set that are
  reachable from x"
  [x existing]
  (-> (into #{} (range (inc x) (+ 4 x)))
      (set/intersection existing)))

(defn count-routes
  "The problem input is effectively a directed acyclic graph and is inherently
  sorted in topological order when sorted ascending; if we operate from the sink
  to the source (i.e. from (max nums) to 0) rather than from source to sink, we
  can avoid needing memoization since it's guaranteed that any child's count
  will have been computed prior to reaching the parent."
  [nums reach-map]
  (loop [[curr & remaining] (reverse nums)
         acc reach-map]
    (if (nil? curr)
      (inc (get-in acc [0 :count]))
      (let [children      (get-in reach-map [curr :children])
            path-count    (if (empty? children) 0 (dec (count children)))
            with-children (->> children
                               (map #(get-in acc [%1 :count] 0))
                               (reduce + path-count))]
        (recur remaining
               (assoc-in acc [curr :count] with-children))))))

(defn part-two
  [nums]
  (let [num-set   (into #{} nums)
        reachable (->> nums
                       (map (juxt identity #(reach % num-set)))
                       (reduce #(assoc %1 (first %2) {:children (second %2)})
                               {}))]
    (count-routes nums reachable)))
