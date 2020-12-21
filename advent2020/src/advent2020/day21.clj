(ns advent2020.day21
  (:require [clojure.string :as str]
            [clojure.set :as set]))

(def input (slurp "resources/day_21_input.txt"))

(defn process-allergens
  [alls]
  (if (empty? alls)
    []
    (->> alls
         (drop 1)
         (mapv #(str/replace % #",|\)" "")))))

(defn line->food
  [line]
  (let [[ingredients allergens] (split-with #(not (str/starts-with? % "("))
                                            (str/split line #" "))]
    {:ingredients     (into #{} ingredients)
     :allergens (process-allergens allergens)}))

(defn food->allergens
  [{:keys [ingredients allergens]}]
  (for [allergen allergens]
    [allergen ingredients]))

(defn intersect-allergens
  "the set of ingredients that probably contain an a particular allergen are those
  that are common to all foods where the allergen is listed"
  [foods]
  (->> foods
       (mapcat food->allergens)
       (reduce (fn [acc [allergen ingredients]]
                 (if-let [candidates (get acc allergen)]
                   (assoc acc allergen (set/intersection candidates ingredients))
                   (assoc acc allergen ingredients)))
               {})))

(defn part-one
  [input]
  (let [foods (->> input
                   (str/split-lines)
                   (map line->food))
        allergens (intersect-allergens foods)
        probables (->> allergens (vals) (reduce set/union #{}))]

    (transduce (comp (map :ingredients)
                     (map #(set/difference % probables))
                     (map count))
               +
               0
               foods)))

(defn resolve-allergens
  [allergens]
  (loop [remaining allergens
         acc       {}]
    (if (empty? remaining)
      acc
      (let [solved  (into #{} (vals acc))
            updated (reduce-kv (fn [acc k v] (assoc acc k (set/difference v solved))) {} remaining)
            new     (->> updated
                         (filter (comp (partial = 1) count second))
                         (map (fn [[k v]] [k (first v)]))
                         (into {}))]
        (recur (apply (partial dissoc remaining) (keys new))
               (merge acc new))))))

(defn part-two
  [input]
  (let [foods (->> input
                   (str/split-lines)
                   (map line->food))
        allergens (intersect-allergens foods)]
    (->> allergens
         (resolve-allergens)
         (sort-by first)
         (map second)
         (str/join ","))))
