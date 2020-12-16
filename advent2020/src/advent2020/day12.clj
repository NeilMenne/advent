(ns advent2020.day12
  (:require [clojure.string :as str]))

(defn line->to-instruction
  [line]
  (let [[_ command value] (re-matches #"([NSEWFLR])(\d+)" line)]
    {:command (keyword command) :value (Integer/parseInt value)}))

(def input
  (->> "resources/day_12_input.txt"
       (slurp)
       (str/split-lines)
       (map line->to-instruction)))

(def sample-input
  (->> "F10
N3
F7
R90
F11"
       (str/split-lines)
       (map line->to-instruction)))

(def turn-comm? #{:L :R})

;; taken in the order such that initial heading is first (east) and ordered such
;; that the next heading is the equivalent of a single 90 degree right turn
(def cardinalities [:E :S :W :N])

(defn turn
  [curr-heading l-or-r value]
  (let [cards (if (= l-or-r :L) (reverse cardinalities) cardinalities)]
    (->> cards
         (cycle)
         (drop-while #(not= curr-heading %))
         (drop (/ value 90))
         (first))))

(defn move-distance
  [{:keys [heading] :as state} value]
  (cond
    (= heading :N) (update state :north-pos + value)
    (= heading :S) (update state :north-pos - value)
    (= heading :E) (update state :east-pos + value)
    (= heading :W) (update state :east-pos - value)))

(defn apply-instruction-p1
  [{:keys [heading] :as state} {:keys [command value]}]
  (cond
    (turn-comm? command)   (assoc state :heading (turn heading command value))
    (= :F command)         (move-distance state value)
    true                   (-> state
                               (assoc :heading command)
                               (move-distance value)
                               (assoc :heading heading))))

(defn abs [x] (if (neg? x) (- x) x))

(defn manhattan-distance
  [{:keys [north-pos east-pos]}]
  (+ (abs north-pos) (abs east-pos)))

(defn part-one
  [commands]
  (->> commands
       (reduce apply-instruction-p1
               {:heading   :E
                :north-pos 0
                :east-pos  0})
       (manhattan-distance)))

(defn rotate-waypoint
  [{x :waypoint-east y :waypoint-north :as state} command value]
  (let [[waypoint-east waypoint-north]
        (loop [x x
               y y
               v (if (= command :L) (- 360 value) value)]
          (if (= 0 v)
            [x y]
            (recur y (- x) (- v 90))))]
    (-> state
        (assoc :waypoint-north waypoint-north)
        (assoc :waypoint-east  waypoint-east))))

(defn adjust-waypoint
  [state command value]
  (cond
    (= :N command) (update state :waypoint-north + value)
    (= :S command) (update state :waypoint-north - value)
    (= :E command) (update state :waypoint-east  + value)
    (= :W command) (update state :waypoint-east  - value)))

(defn utilize-waypoint
  [{:keys [waypoint-north waypoint-east] :as state} value]
  (-> state
      (update :north-pos + (* value waypoint-north))
      (update :east-pos + (* value waypoint-east))))

(def cardinality? #{:N :S :E :W})

(defn apply-instruction-p2
  [state {:keys [command value]}]
  (cond
    (turn-comm? command)   (rotate-waypoint state command value)
    (cardinality? command) (adjust-waypoint state command value)
    (= :F command)         (utilize-waypoint state value)))

(defn part-two
  [commands]
  (->> commands
       (reduce apply-instruction-p2
               {:waypoint-east  10
                :waypoint-north 1
                :north-pos      0
                :east-pos       0})
       (manhattan-distance)))
