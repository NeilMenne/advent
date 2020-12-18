(ns advent2020.day18
  (:require [clojure.string :as str]
            [clojure.walk :as walk]))

(def sample-input "8 + 6 + ((2 * 2 + 7) * 7 + (8 + 2 + 2)) + 6 * 5")

(def input-strs (str/split-lines (slurp "resources/day_18_input.txt")))

(def p1-precedence '{* 0, + 0})
(def p2-precedence '{* 1, + 0})

(defn apply-precedence
  "precedence is only considered when there are adjoining operators; we
  parenthesize the lower precedent thing so that it is evaluated first"
  [input precedence]
  (loop [[x op1 y op2 z & rest :as curr] input]
    (let [ret (if (<= (precedence op1) (precedence op2))
                (list (list x op1 y) op2 z)
                (list x op1 (list y op2 z)))]
      (if rest
        (recur (concat ret rest))
        ret))))

(defn with-precedence
  [l prec]
  (if (seq? l)
    (let [c (count l)]
      (cond (= c 1) (first l)
            (= c 3) l
            (>= 5)  (apply-precedence l prec)))
    l))

(defn add-parens
  "exploit postwalk's depth first traversal to parenthesize innermost operands
  out. after the walk, every parenthesized op will have two operands"
  [s prec]
  (walk/postwalk #(with-precedence % prec) s))

(defn wrap-line
  [line]
  (str "(" line ")"))

(defn make-ast
  "parenthesize operands, parse ints and operations into numbers and symbols
  respectively"
  [prec line]
  (-> (wrap-line line)
      (read-string)
      (add-parens prec)))

(defn apply-op
  "given a sequence of infix operator surrounded by two operands, apply the
  operator to the operands and return the result"
  [[a op b]]
  ((resolve op) a b))

(defn eval-ast
  [ast]
  (walk/postwalk #(if (seq? %) (apply-op %) %) ast))

(defn part-one
  [input]
  (transduce (comp (map (partial make-ast p1-precedence))
                   (map eval-ast))
             +
             0
             input))

(defn part-two
  [input]
  (transduce (comp (map (partial make-ast p2-precedence))
                   (map eval-ast))
             +
             0
             input))
