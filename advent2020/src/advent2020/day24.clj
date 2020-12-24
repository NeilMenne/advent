(ns advent2020.day24
  (:require [clojure.string :as str]
            [clojure.set :as set]))

(def pattern (re-pattern "e|se|sw|w|nw|ne"))

(def input (slurp "resources/day_24_input.txt"))

(defn line->path
  [line]
  (map keyword (re-seq pattern line)))

(def sample-str "nwwswee")

(defn apply-step
  [[x y] step]
  (cond
    (= :e step) [(inc x) y]
    (= :w step) [(dec x) y]
    (= :ne step) [x (inc y)]
    (= :sw step) [x (dec y)]
    (= :nw step) [(dec x) (inc y)]
    (= :se step) [(inc x) (dec y)]))

(defn flip [tile] (if (= tile :white) :black :white))

(defn flip-one
  [grid path]
  (let [dest (reduce apply-step [0 0] path)
        tile (get grid dest :white)]
    (assoc grid dest (flip tile))))

(defn count-black-tiles
  [grid]
  (let [freqs (->> grid
                   (vals)
                   (frequencies))]
    (freqs :black 0)))

(defn part-one
  [input]
  (let [paths (->> input
                   (str/split-lines)
                   (map line->path))]
    (->> paths
         (reduce flip-one {})
         (count-black-tiles))))

(def neighbors
  (memoize
   (fn [[x y]]
     (for [x_off (range -1 2)
           y_off (range -1 2)
           :when (not= x_off y_off)]
       [(+ x x_off) (+ y y_off)]))))

(defn with-neighbors
  [known]
  (let [init (into #{} known)]
    (->> known
         (map neighbors)
         (reduce set/union init))))

(defn next-state
  [grid curr tile]
  (let [freqs (->> tile
                   (neighbors)
                   (map #(grid % :white))
                   (frequencies))
        bns   (get freqs :black 0)]
    (cond
      (and (= curr :black) (or (= 0 bns) (> bns 2))) :white
      (and (= curr :white) (= 2 bns))                :black
      true                                           curr)))

(defn simulate-day
  "in order to slow the growth of the grid, only tiles that are noteworthy are
  added (i.e. those that are currently black or those that have changed)"
  [grid]
  (let [tiles (with-neighbors (keys grid))]
    (reduce (fn [new-grid tile]
              (let [curr (grid tile :white)
                    next (next-state grid curr tile)]
                (if (or (not= next curr) (= curr :black))
                  (assoc new-grid tile next)
                  new-grid)))
            {}
            tiles)))

(defn simulate-days
  [init days]
  (loop [days days
         grid init]
    (if (= 0 days)
      grid
      (recur (dec days) (simulate-day grid)))))

(defn part-two
  [input]
  (let [paths (->> input
                   (str/split-lines)
                   (map line->path))
        grid  (reduce flip-one {} paths)]
    (count-black-tiles (simulate-days grid 100))))
