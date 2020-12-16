(ns advent2020.day16
  (:require [clojure.string :as str]
            [clojure.set :as set]))

(defn to-range-set
  [lstr rstr]
  (->> (Integer/parseInt rstr)
       (inc)
       (range (Integer/parseInt lstr))
       (into #{})))

(defn line->rule
  [line]
  (let [[_ name r01 r02 r11 r12] (re-matches #"([a-z\s]*)\: (\d+)-(\d+) or (\d+)-(\d+)" line)]
    [(keyword (str/replace name #" " "-"))
     [(to-range-set r01 r02) (to-range-set r11 r12)]]))

(defn parse-rules
  [rule-str]
  (->> rule-str
       (str/split-lines)
       (map line->rule)
       (into {})))

(defn line->ticket
  [line]
  (mapv #(Integer/parseInt %) (str/split line #",")))

(defn to-input
  [str]
  (let [[rstr tstr sstr] (str/split str #"\n\n")
        rules            (parse-rules rstr)
        ticket           (->> tstr
                              (str/split-lines)
                              (last)
                              (line->ticket))
        samples          (->> sstr
                              (str/split-lines)
                              (drop 1)
                              (mapv line->ticket))]
    {:rules   rules
     :ticket  ticket
     :samples samples}))

(def input (->> "resources/day_16_input.txt"
                (slurp)
                (to-input)))

(defn compile-super-set
  [rules]
  (->> rules
       (vals)
       (flatten)
       (reduce into #{})))

(defn part-one
  "part one is only concerned with the set of numbers that are invalid; it does
  not care about their corresponding rule nor does it care about 'my' input
  ticket"
  [{:keys [rules samples]}]
  (let [valid-nums (compile-super-set rules)]
    (reduce (fn [total ticket]
              (->> ticket
                   (remove valid-nums)
                   (reduce + total)))
            0
            samples)))

(defn valid-ticket?
  [valid-nums ticket]
  (->> ticket
       (remove valid-nums)
       (empty?)))

(defn satisfying-rules
  [rules tix idx]
  (reduce (fn [acc [name [s0 s1]]]
            (let [s (into s0 s1)]
              (if (every? s (map #(nth % idx) tix))
                (conj acc name)
                acc)))
          #{}
          rules))

(defn find-valid-selections
  [rules tix]
  (let [field-count (count (first tix))]
    (loop [idx 0
           acc {}]
      (if (= idx field-count)
        acc
        (recur (inc idx)
               (assoc acc idx (satisfying-rules rules tix idx)))))))

(defn drop-resolved
  [curr resolved]
  (reduce-kv (fn [acc idx sels]
               (let [sels (set/difference sels resolved)]
                 (if (empty? sels)
                   acc
                   (assoc acc idx sels))))
             {}
             curr))

(defn resolve-choices
  "iteratively decides final mappings of names to indices from the selections map
  of indices to possible names; works by resolving all indices where there's
  only a single selection and removing it from the other indices' choices."
  [choices]
  (loop [curr      choices
         final     {}]
    (if (empty? curr)
      final
      (let [{ones 1} (group-by (comp count second) curr)
            resolved (apply set/union (flatten (map second ones)))]
        (recur (drop-resolved curr resolved)
               (reduce (fn [acc [idx names]]
                         (assoc acc (first names) idx))
                       final
                       ones))))))

(defn part-two
  [{:keys [rules ticket samples]}]
  (let [valid-nums  (compile-super-set rules)
        valid-tix   (filter (partial valid-ticket? valid-nums) samples)
        dep-keys    (->> rules
                         (keys)
                         (filter (comp #(str/starts-with? % "departure") name)))
        choices-map (find-valid-selections rules valid-tix)
        resolved    (resolve-choices choices-map)]
    (->> dep-keys
         (map resolved)
         (map #(nth ticket %))
         (reduce * 1))))
