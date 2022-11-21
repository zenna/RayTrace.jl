abstract type Sphere <: Geometry end

struct SimpleSphere{T1, T2} <: Sphere
  center::T1  # position of center the sphere
  radius::T2        # radius of sphere
end

center(sphere::SimpleSphere) = sphere.center
radius(sphere::SimpleSphere) = sphere.center

struct FancySphere{TC, TR, TSC, TRF, TRA, TE} <: Sphere
  center::TC  # position of center the sphere
  radius::TR      # radius of sphere
  surface_color::TSC  # color of surface
  reflection::TRF
  transparency::TRA
  emission_color::TE
end

# Can remove in julia 0.7 with .dot overloading
center(sphere) = sphere.center
radius(sphere) = sphere.radius
surface_color(sphere) = sphere.surface_color
reflection(sphere) = sphere.reflection
transparency(sphere) = sphere.transparency
emission_color(sphere) = sphere.emission_color

