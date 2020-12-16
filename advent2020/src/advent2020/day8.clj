(ns advent2020.day8
  (:require [clojure.string :as str]))

(defn to-num
  [sign val]
  (let [sign (if (= sign "+") 1 -1)]
    (* sign (Integer/parseInt val))))

(defn line->op
  [line]
  (let [[_ op sign val] (re-matches #"(\w+) (\+|-)(\d+)" line)]
    {:op op :val (to-num sign val)}))

(defn perform-op
  [ops pos acc]
  (let [{:keys [op val]} (nth ops pos {:op "term" :val 0})]
    (cond
      (= op "nop") [(inc pos) acc]
      (= op "jmp") [(+ pos val) acc]
      (= op "acc") [(inc pos) (+ acc val)]
      (= op "term") [-1 acc])))

(defn single-pass
  [ops]
  (loop [cur 0
         acc 0
         vis #{}]
    (cond
      (vis cur)  {:reason :cycle :acc acc}
      (= -1 cur) {:reason :term :acc acc}
      true       (let [[new acc] (perform-op ops cur acc)]
                   (recur new acc (conj vis cur))))))

(defn part-one
  [file-name]
  (->> file-name
       (slurp)
       (str/split-lines)
       (map line->op)
       (single-pass)))

(defn replace-nth
  [ops {idx :idx}]
  (update-in ops [idx :op] (fn [op] (if (= op "nop") "jmp" "nop"))))

(defn part-two
  [file-name]
  (let [ops (->> file-name
                 (slurp)
                 (str/split-lines)
                 (mapv line->op))]
    (->> ops
         (map-indexed #(assoc %2 :idx %1))
         (filter (comp (partial not= "acc") :op))
         (map #(replace-nth ops %))
         (map single-pass)
         (filter #(= (:reason %) :term))
         (first))))
