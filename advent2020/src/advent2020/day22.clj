(ns advent2020.day22
  (:require [clojure.string :as str]))

(def input (slurp "resources/day_22_input.txt"))

(defn lines->deck
  [lines]
  (->> lines
       (str/split-lines)
       (drop 1)
       (mapv #(Integer/parseInt %))))

(defn play-combat
  [deck1 deck2]
  (loop [[c1 & _ :as d1] deck1
         [c2 & _ :as d2] deck2]
    (cond
      (nil? c1) d2
      (nil? c2) d1
      (> c1 c2) (recur (-> d1 (subvec 1) (conj c1 c2)) (subvec d2 1))
      true      (recur (subvec d1 1) (-> d2 (subvec 1) (conj c2 c1))))))

(defn part-one
  [input]
  (let [[d1 d2] (->> (str/split input #"\n\n")
                     (map lines->deck))]
    (->> (play-combat d1 d2)
         (reverse)
         (map-indexed (fn [idx v] (* v (inc idx))))
         (reduce + 0))))

(defn build-subdeck
  [l x]
  (into [] (take x l)))

(defn play-recursive-combat
  [deck1 deck2]
  (loop [prev?    #{}
         [c1 & l1 :as d1] deck1
         [c2 & l2 :as d2] deck2]
    (cond
      (prev? [d1 d2])          {:winner :p1 :deck d1}
      (nil? c1)                {:winner :p2 :deck d2}
      (nil? c2)                {:winner :p1 :deck d1}
      (and (<= c1 (count l1))
           (<= c2 (count l2))) (let [{:keys [winner]}
                                     (play-recursive-combat (build-subdeck l1 c1)
                                                            (build-subdeck l2 c2))
                                     next-d1 (if (= winner :p1)
                                               (-> d1 (subvec 1) (conj c1 c2))
                                               (subvec d1 1))
                                     next-d2 (if (= winner :p2)
                                               (-> d2 (subvec 1) (conj c2 c1))
                                               (subvec d2 1))]
                                 (recur (conj prev? [d1 d2]) next-d1 next-d2))
      (> c1 c2)                (recur (conj prev? [d1 d2])
                                      (-> d1 (subvec 1) (conj c1 c2))
                                      (subvec d2 1))
      true                     (recur (conj prev? [d1 d2])
                                      (subvec d1 1)
                                      (-> d2 (subvec 1) (conj c2 c1))))))

(defn part-two
  [input]
  (let [[d1 d2] (->> (str/split input #"\n\n")
                     (map lines->deck))]
    (->> (play-recursive-combat d1 d2)
         :deck
         (reverse)
         (map-indexed (fn [idx v] (* v (inc idx))))
         (reduce + 0))))
