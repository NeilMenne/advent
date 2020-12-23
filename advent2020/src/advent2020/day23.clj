(ns advent2020.day23
  (:require [clojure.string :as str]))

(def input [1 2 3 4 8 7 5 9 6])

(defn seq->vector
  [[frst & _ :as input]]
  (let [base (vec (repeat (inc (count input)) nil))]
    (assoc (->> input
                (cycle)
                (drop 1)
                (map vector input)
                (reduce #(assoc %1 (first %2) (second %2)) base))
           0 frst)))

(defn play-round
  "mutates the input vector directly"
  [state high]
  (let [curr  (state 0)
        frst  (state curr)
        scnd  (state frst)
        thrd  (state scnd)
        next  (state thrd)
        skip? #{frst scnd thrd 0}
        dest  (loop [i (dec curr)]
                (if (skip? i)
                  (recur (mod (dec i) (inc high)))
                  i))
        targ (state dest)]
    (assoc state
           0    next
           curr next
           dest frst
           thrd targ)))

(defn play-rounds
  [input times]
  (let [high (apply max input)]
    (loop [n    times
           curr (seq->vector input)]
      (if (= n 0)
        curr
        (recur (dec n) (play-round curr high))))))

(defn part-one
  [input]
  (let [final (play-rounds input 100)]
    (loop [curr 1
           out []]
      (if (= 8 (count out))
        (str/join "" out)
        (let [next (final curr)]
          (recur next (conj out next)))))))

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
