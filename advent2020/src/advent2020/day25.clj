(ns advent2020.day25)

(def input [19241437 17346587])

(def sample-input [5764801 17807724])

(defn encrypt-once [subj val] (rem (* subj val) 20201227))

(defn part-one
  [[card-pub door-pub]]
  (loop [pub-key   1
         enc-key   1]
    (if (= pub-key card-pub)
      enc-key
      (recur (encrypt-once 7 pub-key)
             (encrypt-once door-pub enc-key)))))
