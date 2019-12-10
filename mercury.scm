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
    (version "rotd-2019-12-04")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/Mercury-Language/mercury-srcdist/archive/" version ".tar.gz"
              ))
              (sha256
                (base32 
                  "0n1ppc4jzjpr0z265h2vf0ad1f97475k9wxaasjffzm5svq6zb73"
                )
              )
              (patches (search-patches 
                "mercury-configure.patch"
                "murcury-mgnuc.in.patch"))
    ))
    (build-system gnu-build-system)
    (native-inputs (list
      (list "bison" bison)
      (list "flex" flex)
      (list "texinfo" texinfo)
      (list "readline" readline)
    ))
    (arguments `(
      ;#:configure-flags (list "--enable-libgrades=asm_fast.gc,reg.gc")
      #:configure-flags 
        '(
          ,@(let 
              ((system 
                (or (%current-target-system) (%current-system))
              ))
              (cond 
                ((string-prefix? "aarch64" system)
                  ;; Limited testing has shown 'none.gc' to be 
                  ;; one of the only grades certain to compile 
                  ;; successfully on aarch64.
                  '("--enable-libgrades=none.gc")
                )
                (else '())
              )
            )
        )
      #:parallel-build? #f
      #:make-flags (list (string-append "PARALLEL=-j" (number->string (parallel-job-count))))
      #:tests? #f
      #:phases
        (modify-phases %standard-phases
          (add-after 'unpack 'fix-hardcoded-paths
            (lambda _
              (for-each 
                (lambda (hcp_file) 
                  (substitute* hcp_file
                    (("/bin/sh") (string-append "" (which "sh"))))
                ) 
                (list
                  "Makefile"
                  "bindist/bindist.Makefile"
                  "bindist/bindist.Makefile.in"
                  "tests/benchmarks/Makefile.mercury"
                  "scripts/Mmake.vars.in"
                  "boehm_gc/PCR-Makefile"
                  "boehm_gc/Makefile.direct"
                  "boehm_gc/autogen.sh"
                  "boehm_gc/libatomic_ops/configure"
                )
              )
              (substitute* "configure"
                (("export SHELL") (string-append "export CONFIG_SHELL=" (which "sh") "\nexport SHELL=" (which "sh"))))
              (substitute* "boehm_gc/libatomic_ops/configure"
                (("export SHELL") (string-append "export CONFIG_SHELL=" (which "sh") "\nexport SHELL=" (which "sh"))))
              (for-each 
                (lambda (hcp_file) 
                  (substitute* hcp_file
                    (("/bin/pwd") (string-append "" (which "pwd"))))
                ) 
                (list
                  "Mmakefile"
                  "scripts/prepare_install_dir.in"
                )
              )
              (for-each 
                (lambda (hcp_file) 
                  (substitute* hcp_file
                    (("/bin/pwd") (string-append "" "pwd")))
                ) 
                (list
                  "tools/binary"
                  "tools/binary_step"
                  "tools/bootcheck"
                  "tools/cvdd"
                  "tools/linear"
                  "tools/make_java_csharp_arena_base"
                  "tools/make_java_csharp_arena_diff"
                  "tools/speedtest"
                  "tools/unary"
                )
              )
            #t)
          )
        )
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
