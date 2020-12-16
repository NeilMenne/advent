(ns advent2020.day11
  (:require [clojure.string :as str]
            [clojure.set :as set]))

(defn process-line
  [grid row-idx line]
  (->> line
       (char-array)
       (map-indexed vector)
       (reduce (fn [grid [col-idx char]]
                 (let [val (cond
                             (= char \L) :empty
                             (= char \.) :floor
                             (= char \#) :occupy)]
                   (assoc grid [row-idx col-idx] {:state val})))
               grid)))

(defn exclude-self?
  [r0 c0 r1 c1]
  (not (and (= r0 r1)
            (= c0 c1))))

(defn seat?
  [v]
  (#{:empty :occupy} (:state v)))

(defn get-neighbors
  [grid row col]
  (for [x (range (dec row) (+ 2 row))
        y (range (dec col) (+ 2 col))
        :when (and (exclude-self? row col x y)
                   (seat? (grid [x y])))]
    [x y]))

(defn with-neighbors
  "part one neighbors: all points surrounding the field in the grid"
  [grid]
  (->> grid
       (filter (fn [[k v]] (seat? v)))
       (keys)
       (reduce (fn [grid [row col :as pos]]
                 (->> (get-neighbors grid row col)
                      (assoc-in grid [pos :neighbors])))
               grid)))

(defn abs [n]
  (if (neg? n) (- n) n))

(defn above [s r c _h _w] (first (filter s (map vector (range (dec r) -1 -1) (repeat c)))))
(defn below [s r c h _w] (first (filter s (map vector (range (inc r) h) (repeat c)))))
(defn left [s r c _h _w] (first (filter s (map vector (repeat r) (range (dec c) -1 -1)))))
(defn right [s r c _h w] (first (filter s (map vector (repeat r) (range (inc c) w)))))
(defn diag-lu [s r c _h _w] (first (filter s (map vector (range (dec r) -1 -1) (range (dec c) -1 -1)))))
(defn diag-ld [s r c h _w] (first (filter s (map vector (range (inc r) h) (range (dec c) -1 -1 )))))
(defn diag-ru [s r c _h w] (first (filter s (map vector (range (dec r) -1 -1) (range (inc c) w)))))
(defn diag-rd [s r c h w] (first (filter s (map vector (range (inc r) h) (range (inc c) w)))))

(defn project-axes
  [{{:keys [width height]} :state :as grid} all-seats row col]
  (->> [above below left right diag-lu diag-ld diag-ru diag-rd]
       (map #(% all-seats row col height width))
       (reduce (fn [acc val]
                 (if (nil? val)
                   acc
                   (conj acc val)))
               #{})))

(defn with-line-of-sight
  [grid]
  (let [all-seats (->> grid (filter (fn [[k v]] (seat? v))) (keys) (into #{}))]
    (reduce (fn [grid [row col :as pos]]
              (->> (project-axes grid all-seats row col)
                   (assoc-in grid [pos :line-of-sight])))
            grid
            all-seats)))

(defn to-grid
  [lines]
  (->> lines
       (map-indexed vector)
       (reduce (fn [acc [row-idx line]] (process-line acc row-idx line))
               {:state {:height (count lines) :width (count (first lines))}})
       (with-neighbors)
       (with-line-of-sight)))

(defn crowded?
  [grid neighbors limit]
  (->> neighbors
       (map (comp :state grid))
       (filter (partial = :occupy))
       (count)
       (<= limit)))

(defn avail?
  [grid neighbors]
  (->> neighbors
       (map (comp :state grid))
       (filter (partial = :occupy))
       (empty?)))

(defn advance-state-p1
  [old {:keys [state neighbors]}]
  (cond
    (and (= state :occupy) (crowded? old neighbors 4)) :empty
    (and (= state :empty) (avail? old neighbors))      :occupy
    true                                               state))

(defn occupy-seats-p1
  "a single pass of the rules of the game:
  - If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
  - If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
  - Otherwise, the seat's state does not change."
  [grid]
  (reduce-kv (fn [new-grid key val]
               (if (not= key :state)
                 (let [[row-id col-id] key
                       new-state (advance-state-p1 grid val)]
                   (assoc-in new-grid [key :state] new-state))
                 new-grid))
             grid
             grid))

(defn advance-state-p2
  [old {:keys [state line-of-sight]}]
  (cond
    (and (= state :occupy) (crowded? old line-of-sight 5)) :empty
    (and (= state :empty)  (avail? old line-of-sight))     :occupy
    true                                                   state))

(defn occupy-seats-p2
  "a single pass of the updated rules:
  - If a seat is empty (L) and there are no occupied seats in line of sight, the
    seat becomes occupied.
  - If a seat is occupied (#) and there are five or more seats in line of sight
    that are also occupied, the seat becomes empty.
  - Otherwise, the seat's state does not change.
  "
  [grid]
  (reduce-kv (fn [new-grid key val]
               (if (not= key :state)
                 (let [[row-id col-id] key
                       new-state (advance-state-p2 grid val)]
                   (assoc-in new-grid [key :state] new-state))
                 new-grid))
             grid
             grid))

(defn unchanged?
  [old new]
  (->> old
       (keys)
       (map (juxt (comp :state old) (comp :state new)))
       (remove (partial apply =))
       (empty?)))

(defn settle-grid
  [occupy-fn input-grid]
  (loop [curr input-grid]
    (let [next (occupy-fn curr)]
      (if (unchanged? curr next)
        curr
        (recur next)))))

(defn input
  []
  (->> "resources/day_11_input.txt"
       (slurp)
       (str/split-lines)
       (to-grid)))

(defn part-one
  [input-grid]
  (->> input-grid
       (settle-grid occupy-seats-p1)
       (vals)
       (map :state)
       (frequencies)
       :occupy))

(defn part-two
  [input-grid]
  (->> input-grid
       (settle-grid occupy-seats-p2)
       (vals)
       (map :state)
       (frequencies)
       :occupy))
