\ --- Astra MiniForth Kernel (Vector Mode) ---

: (1 1 2 3 ; 
: 2) 1 2 3 ; 
: vec3(1,0,0) 1 2 3 ; 

: fdot ( z1 y1 x1 z2 y2 x2 -- res )
    rot * \ x1*x2
    -rot rot * +    \ + y1*y2
    -rot * +        \ + z1*z2
; 
: fcross + ; \ On garde un stub pour l'instant 

: main
    (1 2) vec3(1,0,0) * + 
;

