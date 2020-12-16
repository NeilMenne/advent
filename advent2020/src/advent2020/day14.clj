(ns advent2020.day14
  (:require [clojure.string :as str]))

(defn parse-mask
  [mask-str]
  (let [[_ bit-str] (str/split mask-str #" = ")]
    (->> bit-str
         (map (fn [bit op] {:bit bit :op op}) (range 35 -1 -1))
         (into []))))

(defn parse-mem
  [mem-str]
  (let [[_ addr val] (re-matches #"mem\[(\d+)\] = (\d+)" mem-str)]
    {:addr (Long/parseLong addr) :val (Long/parseLong val)}))

(defn parse-input
  [lines]
  (for [[mask mems :as tup] (->> lines
                         (str/split-lines)
                         (partition-by #(str/starts-with? % "mask"))
                         (partition 2))]
    [(parse-mask (first mask)) (mapv parse-mem mems)]))

(def input (->> "resources/day_14_input.txt"
                (slurp)
                (parse-input)))

(defn apply-all-masks
  [masks value]
  (reduce (fn [val {:keys [bit op]}]
            (cond
              (= op \1) (bit-set val bit)
              (= op \0) (bit-clear val bit)
              true      val))
          value
          masks))

(defn process-chunk
  [state [masks mem-vals]]
  (reduce #(assoc %1 (:addr %2) (apply-all-masks masks (:val %2)))
          state
          mem-vals))

(defn part-one
  [parsed-input]
  (->> parsed-input
       (reduce process-chunk {})
       (vals)
       (reduce + 0)))

(defn float-bit
  [{:keys [bit]} addrs]
  (->> addrs
       (map (juxt #(bit-set % bit) #(bit-clear % bit)))
       (flatten)))

(defn apply-address-masks
  "2 phase address expansion: apply all 1s, explode all Xs to create a sequence of
  addresses to edit, all 0s are ignored"
  [address masks]
  (let [groups          (group-by :op masks)
        ones            (get groups \1)
        floaters        (get groups \X)
        new-addr        (apply-all-masks ones address)]
    (loop [remaining-masks floaters
           addresses       [new-addr]]
      (if (empty? remaining-masks)
        addresses
        (recur (rest remaining-masks)
               (float-bit (first remaining-masks) addresses))))))

(defn process-chunk-v2
  [state [masks mem-vals]]
  (reduce (fn [state {:keys [addr val]}]
            (let [addrs (apply-address-masks addr masks)]
              (reduce #(assoc %1 %2 val) state addrs)))
          state
          mem-vals))

(defn part-two
  [parsed-input]
  (->> parsed-input
       (reduce process-chunk-v2 {})
       (vals)
       (reduce + 0)))
