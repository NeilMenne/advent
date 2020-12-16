(ns advent2020.day4
  (:require [clojure.string :as str]))

(defn read-input
  [file-name]
  (-> file-name
      (slurp)
      (str/split #"\n\n")))

(defn to-passport
  [raw-str]
  (let [fields (str/split raw-str #"\n|\s")]
    (into {} (map #(str/split % #":") fields))))

(defn p1-valid?
  [passport]
  (let [field-count (count passport)]
    (or (= 8 field-count)
        (and (= 7 field-count) (not (contains? passport "cid"))))))

(defn part-one
  [file-name]
  (->> file-name
       (read-input)
       (map to-passport)
       (filter p1-valid?)
       (count)))

(defn to-int
  [i]
  (Integer/parseInt i))

(defn in-range [low high i] (<= low i high))

(defn valid-int?
  [k min max m]
  (let [v (to-int (get m k))]
    (in-range min max v)))

(def valid-birthday? (partial valid-int? "byr" 1920 2002))
(def valid-issue-year? (partial valid-int? "iyr" 2010 2020))
(def valid-expiration? (partial valid-int? "eyr" 2020 2030))

(def inches-range (partial in-range 59 76))
(def centimeters-range (partial in-range 150 193))

(defn valid-height?
  [{:strs [hgt]}]
  (if-let [[orig digits units] (re-matches #"(\d+)(in|cm)" hgt)]
    (let [height (to-int digits)
          range-fn (if (= units "in") inches-range centimeters-range)]
      (and (#{"in" "cm"} units)
           (range-fn height)))))

(defn valid-hair-color?
  [{:strs [hcl]}]
  (some? (re-matches #"#[0-9a-f]{6}" hcl)))

(def eye-colors #{"amb" "blu" "brn" "gry" "grn" "hzl" "oth"})

(defn valid-eye-color?
  [{:strs [ecl]}]
  (eye-colors ecl))

(defn valid-passport-id?
  [{:strs [pid]}]
  (some? (re-matches #"[0-9]{9}" pid)))

(defn p2-valid?
  [passport]
  (every? #(% passport)
          [p1-valid?
           valid-birthday?
           valid-issue-year?
           valid-expiration?
           valid-height?
           valid-hair-color?
           valid-eye-color?
           valid-passport-id?]))

(defn part-two
  [file-name]
  (->> file-name
       (read-input)
       (map to-passport)
       (filter p2-valid?)
       (count)))
