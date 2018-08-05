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
center(sphere::FancySphere) = sphere.center
radius(sphere::FancySphere) = sphere.radius
surface_color(sphere::FancySphere) = sphere.surface_color
reflection(sphere::FancySphere) = sphere.reflection
transparency(sphere::FancySphere) = sphere.transparency
emission_color(sphere::FancySphere) = sphere.emission_color

