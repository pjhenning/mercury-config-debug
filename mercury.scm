(define-module (mercury)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages readline)
)

(define-public mercury
  (package
    (name "mercury")
    (version "14.01.1")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://dl.mercurylang.org/release/mercury-srcdist-" version ".tar.gz"
              ))
              (sha256
                (base32 
                  "12z8qi3da8q50mcsjsy5bnr4ia6ny5lkxvzy01a3c9blgbgcpxwq"
                )
              )
    ))
    (build-system gnu-build-system)
    (native-inputs (list
      (list "bison" bison)
      (list "flex" flex)
      (list "texinfo" texinfo)
      (list "readline" readline)
    ))
    (arguments (list
      #:config-flags (list "--disable-most-grades")
    ))
    (synopsis "The Mercury programming language")
    (description 
      "Mercury is a logic/functional programming language which combines the clarity and expressiveness of declarative programming with advanced static analysis and error detection features. \n\nIts highly optimized execution algorithm delivers efficiency far in excess of existing logic programming systems, and close to conventional programming systems. Mercury addresses the problems of large-scale program development, allowing modularity, separate compilation, and numerous optimization/time trade-offs."
    )
    (home-page "http://www.mercurylang.org/index.html")
    (license gpl3+)
  )
)
mercury
