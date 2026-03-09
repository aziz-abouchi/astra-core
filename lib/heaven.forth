\ Multiplication Scalaire-Vecteur ( s x y z -- s*x s*y s*z )
: smul { s x y z }
  x s * y s * z s * ;

\ Affichage d'un vecteur ( x y z -- )
: print-vec3 ( x y z -- )
  ." [" . ." ," . ." ," . ." ]" cr ;
