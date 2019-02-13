"Result of intersection between ray and object"
mutable struct Intersection{T1, T2, T3}
  doesintersect::T1
  t0::T2
  t1::T3
end