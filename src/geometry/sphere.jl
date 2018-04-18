abstract type Sphere{T} <: Geometry end

struct SimpleSphere{T} <: Sphere{T}
  center::Vec3{T}  # position of center the sphere
  radius::T        # radius of sphere
end

center(sphere::SimpleSphere) = sphere.center
radius(sphere::SimpleSphere) = sphere.center

# struct FancySphere{T} <: Sphere{T}
#   center::Vec3{T}  # position of center the sphere
#   radius::T      # radius of sphere
#   surface_color::Vec3{T}  # color of surface
#   reflection::T
#   transparency::T
#   emission_color::Vec3{T}
# end

struct FancySphere <: Sphere{Real}
  center::Vec3  # position of center the sphere
  radius      # radius of sphere
  surface_color::Vec3  # color of surface
  reflection
  transparency
  emission_color
end


# Can remove in julia 0.7 with .dot overloading
center(sphere::FancySphere) = sphere.center
radius(sphere::FancySphere) = sphere.radius
surface_color(sphere::FancySphere) = sphere.surface_color
reflection(sphere::FancySphere) = sphere.reflection
transparency(sphere::FancySphere) = sphere.transparency
emission_color(sphere::FancySphere) = sphere.emission_color

