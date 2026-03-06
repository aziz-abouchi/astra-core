program astra_kernel
  implicit none
  real(8), dimension(3) :: (1
  real(8), dimension(3) :: 2)
  real(8), dimension(3) :: vec3(1,0,0)
  real(8) :: res_scalar
  real(8), dimension(3) :: res_vec

  ! NOTE: L'expression ci-dessous mélange scalaire et vecteur.
  ! res_vec = ... (Le résultat final doit être cohérent)
  res_vec = ((1 + (2) * vec3(1,0,0)))
  print *, "Calcul terminé."
contains
  pure function astra_cross_product(u, v) result(res)
    real(8), dimension(3), intent(in) :: u, v
    real(8), dimension(3) :: res
    res(1) = u(2)*v(3) - u(3)*v(2)
    res(2) = u(3)*v(1) - u(1)*v(3)
    res(3) = u(1)*v(2) - u(2)*v(1)
  end function astra_cross_product
end program astra_kernel

