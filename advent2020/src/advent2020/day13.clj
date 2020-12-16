(ns advent2020.day13
  (:require [clojure.string :as str]))

(defn line->busses
  [line]
  (->> (str/split line #",")
       (map-indexed vector)
       (remove (comp (partial = "x") second))
       (mapv (fn [[offset id]] {:id (Integer/parseInt id) :offset offset}))))

(def input
  (let [[arrival-time bus-str] (->> "resources/day_13_input.txt"
                                    (slurp)
                                    (str/split-lines))]
    {:arrival-time (Long/parseLong arrival-time)
     :busses       (line->busses bus-str)}))

(defn to-nearest-time
  [arrival id]
  (* (inc (int (/ arrival id)))
     id))

(defn part-one
  [{:keys [arrival-time busses]}]
  (let [[bus bus-time] (->> busses
                            (map :id)
                            (map (juxt identity (partial to-nearest-time arrival-time)))
                            (sort-by second)
                            (first))]
    (* bus (- bus-time arrival-time))))

(defn offset-val?
  [{:keys [id offset]} ts]
  (= 0 (mod (+ ts offset)
            id)))

(defn valid-timestamps
  "using the current step size and the next bus, generate the sequence of
  timestamps that match"
  [curr-bus step-size initial-timestamp]
  (for [x (range)
        :let [ts (+ initial-timestamp (* step-size x))]
        :when (offset-val? curr-bus ts)]
    ts))

(defn part-two
  [{:keys [busses]}]
  (loop [step-size (:id (first busses))
         timestamp 0
         remaining (rest busses)]
    (if (empty? remaining)
      timestamp
      (let [[{:keys [id] :as curr-bus} & tail] remaining]
        (recur (* step-size id)
               (first (valid-timestamps curr-bus step-size timestamp))
               tail)))))
