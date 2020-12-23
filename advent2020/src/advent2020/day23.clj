(ns advent2020.day23
  (:require [clojure.string :as str]))

(def input [1 2 3 4 8 7 5 9 6])

(defn play-round-v1
  [[w x y z & xs]]
  (let [target     (->> (range 9 0 -1)
                        (cycle)
                        (drop-while #(not= w %))
                        (drop 1)
                        (remove #{x y z})
                        (first))]
    (if (= target w)
      (concat [x y z] xs [w])
      (conj (reduce (fn [acc v]
                     (if (= v target)
                       (conj acc v x y z)
                       (conj acc v)))
                   []
                   xs)
            w))))

(defn part-one
  [input]
  (let [final (loop [n 100
                     i input]
                (if (= 0 n)
                  i
                  (recur (dec n) (play-round-v1 i))))]
    (->> (cycle final)
         (drop-while (partial not= 1))
         (drop 1)
         (take 8)
         (str/join ""))))

(defn play-round-v2
  [state]
  (let [curr  (state 0)
        frst  (state curr)
        scnd  (state frst)
        thrd  (state scnd)
        next  (state thrd)
        skip? #{frst scnd thrd 0}
        dest  (loop [i (dec curr)]
                (if (skip? i)
                  (recur (mod (dec i) 1000001))
                  i))
        targ (state dest)]
    (assoc state
           0    next
           curr next
           dest frst
           thrd targ)))

(defn seq->linked-list
  [[frst & _ :as input]]
  (let [base (vec (repeat (inc (count input)) nil))]
    (assoc (->> input
                (cycle)
                (drop 1)
                (map vector input)
                (reduce #(assoc %1 (first %2) (second %2)) base))
           0 frst)))

(defn play-rounds
  [input times]
  (loop [n    times
         curr (seq->linked-list input)]
    (if (= n 0)
      curr
      (recur (dec n) (play-round-v2 curr)))))

(defn extend-sequence
  [seq len]
  (let [start     (inc (apply max seq))
        remaining (- len (count seq))]
    (concat seq (range start (+ start remaining)))))

(defn part-two
  [input]
  (let [new-input (extend-sequence input 1000000)
        final     (play-rounds new-input 10000000)
        x         (final 1)
        y         (final x)]
    (* x y)))
