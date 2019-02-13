center(sphere::Sphere) = sphere.center
radius(sphere::Sphere) = sphere.r

u(::Type{T}) where T = Union{T, MaterialGeom{T}}
# const US = u(Sphere) 

const US{T, MAT} = Union{Sphere{T}, MaterialGeom{Sphere{T}, MAT}}

"Intersection information between ray `r` and sphere `s`"
function rayintersect(r::Ray, s::US)
  l = s.center - r.orig
  tca = dot_(l, r.dir)
  radius2 = s.r * s.r

  if tca < 0
    return Intersection(tca, 0.0, 0.0)
  end

  d2 = dot_(l, l) - tca * tca
  if d2 > radius2
    return Intersection(s.r - d2, 0.0, 0.0)
  end

  thc = sqrt(radius2 - d2)
  t0 = tca - thc
  t1 = tca + thc
  Intersection(radius2 - d2, t0, t1)
end

"Normal between `r` and `sphere`"
function normal(hitpos, s::US, tnear::Real)
  nhit = hitpos .- s.center
  nhit = simplenormalize(nhit)
end