struct Sphere{T} <: Geometry
  center::Vec3{T}  # position of center the sphere
  radius::T      # radius of sphere
  surface_color::Vec3{T}  # color of surface
  reflection::T
  transparency::T
  emission_color::Vec3{T}
end

# Can remove in julia 0.7 with .dot overloading
center(sphere::Sphere) = sphere.center
radius(sphere::Sphere) = sphere.radius
surface_color(sphere::Sphere) = sphere.surface_color
reflection(sphere::Sphere) = sphere.reflection
transparency(sphere::Sphere) = sphere.transparency
emission_color(sphere::Sphere) = sphere.emission_color

