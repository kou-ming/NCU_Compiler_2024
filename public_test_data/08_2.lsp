(define bar (fun (x) (+ x 1)))
(define bar-z (fun () 2))
(print-num (bar (bar-z)))

(define bar-z (fun () 2))
(define fact (fun (n) (if (< n (bar-z)) n 9)))


(define bar (fun (x y z) (+ x y z)))
(define bar-z (fun (z) z))
(print-num (bar 5 (bar-z 3) 4))


(define bar (fun (x y) (+ x y)))
(define bar-z (fun (z) z))
(print-num (bar 5 (bar-z 3)))