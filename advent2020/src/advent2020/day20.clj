(ns advent2020.day20
  (:require [clojure.string :as str]
            [clojure.set :as set]))

(defn lift-right-edge
  [strs]
  (let [idx (dec (count strs))]
    (apply str (map #(.charAt % idx) strs))))

(defn lift-left-edge
  [strs]
  (apply str (map #(.charAt % 0) strs)))

(defn lift-edges
  [rows]
  [(first rows)
   (lift-right-edge rows)
   (last rows)
   (lift-left-edge rows)])

(defn parse-tile
  [tile-str]
  (let [[id-str & rows] (str/split-lines tile-str)
        id              (->> id-str
                             (re-find #"Tile (\d+):")
                             (last)
                             (Integer/parseInt))]
    {:id id
     :rows  rows
     :edges (lift-edges rows)}))

(defn flip-x
  [{rows :rows :as tile}]
  (let [new-rows (into [] (reverse rows))]
    (-> tile
        (assoc :rows new-rows)
        (assoc :edges (lift-edges new-rows)))))

(defn flip-y
  [{rows :rows :as tile}]
  (let [new-rows (mapv str/reverse rows)]
    (-> tile
        (assoc :rows new-rows)
        (assoc :edges (lift-edges new-rows)))))

(def flip-xy (comp flip-x flip-y))

(defn transpose-strs
  [strs]
  (vec (apply (partial map str) strs)))

(defn transpose
  [{rows :rows :as tile}]
  (let [new-rows (transpose-strs rows)]
    (-> tile
        (assoc :rows new-rows)
        (assoc :edges (lift-edges new-rows)))))

(def input (slurp "resources/day_20_input.txt"))

(defn permutations
  [tile]
  [tile
   (flip-x tile)
   (flip-y tile)
   (flip-xy tile)])

(def intersection? (comp not empty? set/intersection))

(def aligns?
  (memoize
   (fn [tile edges]
     (->> tile
          (permutations)
          (some (fn [p]
                  (if (intersection? edges (into #{} (:edges p)))
                    p)))))))

(defn corner?
  [{id :id :as tile} tiles]
  (let [edges (into #{} (:edges tile))]
    (->> tiles
         (remove #(= id (:id %)))
         (filter #(aligns? % edges))
         (count)
         (= 2))))

(defn part-one
  [input]
  (let [tiles (->> (str/split input #"\n\n")
                   (map parse-tile))]
    (reduce (fn [acc {id :id :as tile}]
              (if (corner? tile tiles)
                (* acc id)
                acc))
            1
            tiles)))

(defn full-permutations
  [tile]
  (->> [(transpose tile) tile]
       (map permutations)
       (flatten)))

(defn top-edge [{:keys [edges]}] (nth edges 0))
(defn right-edge [{:keys [edges]}] (nth edges 1))
(defn bottom-edge [{:keys [edges]}] (nth edges 2))
(defn left-edge [{:keys [edges]}] (nth edges 3))

(defn neighbors
  [{:keys [edges id]} tiles]
  (let [es (into #{} edges)]
    (->> tiles
         (remove #(= id (:id %)))
         (filter #(aligns? % es))
         (take 4))))

(defn align-edges
  [tile neighbor]
  (cond
    (= (top-edge tile) (bottom-edge neighbor)) [:top neighbor]
    (= (bottom-edge tile) (top-edge neighbor)) [:bottom neighbor]
    (= (right-edge tile) (left-edge neighbor)) [:right neighbor]
    (= (left-edge tile) (right-edge neighbor)) [:left neighbor]
    true                                       [:drop neighbor]))

(defn align-neighbors
  [tile-map {:keys [id] :as tile}]
  (let [attempted (->> (get-in tile-map [id :neighbors])
                       (mapcat full-permutations)
                       (map (partial align-edges tile)))]
    (->> attempted
         (remove (comp (partial = :drop) first))
         (sort-by first))))

(defn right-neighbor
  [tile-map tile]
  (->> tile
       (align-neighbors tile-map)
       (filter (comp (partial = :right) first))
       (first)
       (second)))

(defn bottom-neighbor
  [tile-map tile]
  (->> tile
       (align-neighbors tile-map)
       (filter (comp (partial = :bottom) first))
       (first)
       (second)))

(defn align-row
  "assuming the tile has been rotated appropriately before starting, just find its
  neighbors to the right"
  [tile-map tile dim]
  (loop [acc     [tile]
         col-idx 1]
    (if (>= col-idx dim)
      acc
      (recur (conj acc (right-neighbor tile-map (last acc)))
             (inc col-idx)))))

(defn choose-start
  [corners tile-map]
  (first (filter #(and (right-neighbor tile-map %)
                       (bottom-neighbor tile-map %))
                 corners)))

(defn generate-image
  [input]
  (let [tiles (->> (str/split input #"\n\n")
                   (map parse-tile))
        tile-map (into {} (map (juxt :id #(assoc % :neighbors (neighbors % tiles))) tiles))
        corners (->> tile-map
                     (map (fn [[k v]] [k (count (:neighbors v))]))
                     (filter (fn [[k v]] (= 2 v)))
                     (map #(get tile-map %)))
        dim     (int (Math/sqrt (count tiles)))]
    (loop [curr    start
           row-idx 0
           acc     []]
      (if (>= row-idx dim)
        acc
        (recur (bottom-neighbor tile-map curr)
               (inc row-idx)
               (conj acc (align-row tile-map curr dim)))))))

(defn trim-edge
  [s]
  (->> s
       (drop 1)
       (drop-last)
       (apply str)))

(defn crop-border
  [{:keys [rows]}]
  (->> rows
       (drop 1)
       (drop-last)
       (mapv trim-edge)))

(defn stitch-rows
  [rs]
  (for [r (range 0 (count (first rs)))]
    (apply str (map #(nth % r) rs))))

(defn stitch-image
  "now that all strings are oriented properly, remove the borders to compose the complete image"
  [image]
  (let [indices (for [r (range 0 (count image))
                      c (range 0 (count image))]
                  [r c])
        remaining (reduce #(update-in %1 %2 crop-border)
                          image
                          indices)]
    {:id :image
     :rows (into [] (flatten (map stitch-rows remaining)))}))

(defn count-heads
  [str]
  (count (re-seq #".{18}#" str)))

(defn count-bodies
  [str]
  (count (re-seq #"#.{4}##.{4}##.{4}###" str)))

(defn count-tails
  [str]
  (count (re-seq #".#..#..#..#..#..#" str)))

(defn count-sea-monsters
  [{:keys [rows]}]
  (->> rows
       (partition 3 1)
       (map (fn [[x y z]]
              (min (count-heads x)
                   (count-bodies y)
                   (count-tails z))))
       (reduce + 0)))

(defn part-two
  [input]
  (let [image        (generate-image input)
        composite    (stitch-image image)
        sea-monsters (->> composite
                          (full-permutations)
                          (map count-sea-monsters)
                          (apply max))
        hash-count   (->> composite
                          (:rows)
                          (mapcat char-array)
                          (filter #(= % \#))
                          (count))]
    ;; 15 = number characters occupied per sea monster
    (- hash-count (* 15 sea-monsters))))
