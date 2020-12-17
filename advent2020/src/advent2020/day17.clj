(ns advent2020.day17
  (:require [clojure.string :as str]
            [clojure.set :as set]))
(def sample-str
  ".#.
   ..#
   ###")

(def input-str
  "##...#.#
   #..##..#
   ..#.####
   .#..#...
   ########
   ######.#
   .####..#
   .###.#..")

(defn line->active-cells
  [line]
  (->> line
       (str/trim)
       (map-indexed vector)
       (remove (comp (partial = \.) second))
       (map first)))

(defn cell-addr
  [dims x y]
  (into [x y] (take (- dims 2) (repeat 0))))

(defn to-initial-grid
  "textual input is structured assuming the following:
  - z = 0 for the provided string; non-zero z indices emerge after t0
  - 0,0,0 is therefore the upper left character

  - sparse representations are preferred, only active cells are guaranteed to
    exist after parsing"
  ([str] (to-initial-grid str 3))
  ([str dims]
   (->> str
        (str/split-lines)
        (map-indexed vector)
        (map (fn [[x line]] [x (line->active-cells line)]))
        (reduce (fn [acc [x ys]]
                  (reduce #(assoc %1 (cell-addr dims x %2) :active)
                          acc
                          ys))
                {}))))

(def sample-input (to-initial-grid sample-str))

(def input (to-initial-grid input-str))

(def get-3d-neighbors
  (memoize
   (fn [[x y z]]
     (for [x_off (range -1 2)
           y_off (range -1 2)
           z_off (range -1 2)
           :when (not= x_off y_off z_off 0)]
       [(+ x_off x) (+ y_off y) (+ z_off z)]))))

(def get-4d-neighbors
  (memoize
   (fn [[x y z w]]
     (for [x_off (range -1 2)
           y_off (range -1 2)
           z_off (range -1 2)
           w_off (range -1 2)
           :when (not= x_off y_off z_off w_off 0)]
       [(+ x_off x) (+ y_off y) (+ z_off z) (+ w_off w)]))))

(defn decide-cell
  [grid neighbor-fn curr]
  (let [state  (grid curr)
        ncount (->> curr
                    (neighbor-fn)
                    (map grid)
                    (remove nil?)
                    (count))]
    (cond
      (and state (<= 2 ncount 3))     :active
      state                           :inactive
      (and (nil? state) (= ncount 3)) :active
      true                            :inactive)))

(def active? (partial = :active))

(defn assoc-if
  [m k v f]
  (if (f v)
    (assoc m k v)
    m))

(defn cycle-once
  [grid neighbor-fn]
  (let [ks (into #{} (keys grid))
        ns (->> ks
                (mapcat neighbor-fn)
                (into #{})
                (set/union ks))]
    (loop [[curr & remaining]  ns
           next-state          {}]
      (if (nil? curr)
        next-state
        (recur remaining
               (assoc-if next-state
                         curr
                         (decide-cell grid neighbor-fn curr)
                         active?))))))


(defn cycle-n
  [grid n neighbor-fn]
  (loop [times n
         next  grid]
    (if (= times 0)
      next
      (recur (dec times) (cycle-once next neighbor-fn)))))

(defn part-one
  [grid]
  (-> grid
      (cycle-n 6 get-3d-neighbors)
      (keys)
      (count)))

(defn part-two
  [str]
  (-> str
      (to-initial-grid 4)
      (cycle-n 6 get-4d-neighbors)
      (keys)
      (count)))
