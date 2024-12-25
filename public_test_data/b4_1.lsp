(define add-x
  (fun (x) (fun (y) (+ x y))))

(define z (add-x 10))

(print-num (z 1))


(define chose
  (fun (chose-fun x y)
    (if (chose-fun x y) x y)))

(print-num (chose (fun (x y) (> x y)) 2 1))

