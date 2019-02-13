# const UB{T, MAT} = Union{AABB{T}, MaterialGeom{AABB{T}, MAT}}

# function rayintersect(r::Ray, s::UB)
#   tmin = (bounds[r.sign[0]].x - r.orig.x) * r.invdir.x; 
#   if (tmin > tymax) || (tymin > tmax)
#     return false
#   end

#   if (tymin > tmin)
#     tmin = tymin
#   end
#   if (tymax < tmax)
#     tmax = tymax
#   end
#   tzmin = (bounds[r.sign[2]].z - r.orig.z) * r.invdir.z
#   tzmax = (bounds[1-r.sign[2]].z - r.orig.z) * r.invdir.z; 

#   if ((tmin > tzmax) || (tzmin > tmax))
#     return false
#   end

#   if (tzmin > tmin)
#     tmin = tzmin
#   end
#   if (tzmax < tmax)
#     tmax = tzmax
#   end

#   t = tmin

#   if (t < 0)
#     t = tmax
#     if (t < 0)
#       return false
#     end
#   end

#   return Intersection(true, t)
# end
   

# function normal(hitpos, b::UB, tnear)
# end