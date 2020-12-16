(ns advent2020.day15)

(defn turn-num
  "turn number is a 1-based index"
  [a b]
  [b (inc a)])

(def sample-input (map-indexed turn-num [0 3 6]))
(def input (map-indexed turn-num [16 1 0 18 12 14 19]))

(defn say-next
  [seen [lv lt]]
  (let [pt      (seen lv)
        ct      (inc lt)]
    (if-let [pt (seen lv)]
      [(- lt pt) ct]
      [0         ct])))

(defn find-nth
  "map based approach to memory: reduces the memory footprint by preserving the
  values and the last turn they were seen; for this to work, the last turn does
  not overwrite the value slot until after say-next has computed without it."
  [input stop-at]
  (loop [[last-val turn-num :as last-turn]  (last input)
         seen                               (into {} (drop-last input))]
    (if (= turn-num stop-at)
      last-val
      (let [curr-turn (say-next seen last-turn)]
        (recur curr-turn (assoc seen last-val turn-num))))))

(defn part-one
  [input]
  (find-nth input 2020))

(defn part-two
  [input]
  (find-nth input 30000000))
