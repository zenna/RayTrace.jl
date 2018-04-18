"Light ray with origin `orig` and direction `dir`"
struct Ray
  orig::Vec3
  dir::Vec3
end

"Linear interpolation between `a` and `b` by factor `mix`"
mix(a, b, mix::Real) = b * mix + a * (1 - mix)

"norm(x)^2"
dot_self(x) = dot_(x, x)

"dot product (without BLAS etc for generality)"
dot_(xs, ys) = sum(xs .* ys)

"normalized x: `x/norm(x)`"
simplenormalize(x::Vector) = x / sqrt(dot_self(x))

"x iff x > 0 else 0"
rlu(x) = max(zero(x), x)

"Result of intersection between ray and object"
mutable struct Intersection{T}
  doesintersect::T
  t0::T
  t1::T
end

"Intersection information between ray `r` and sphere `s`"
function rayintersect(r::Ray, s::Sphere{T})::Intersection where T
  l = s.center - r.orig
  tca = dot_(l, r.dir)
  radius2 = s.radius^2

  if tca < 0
    return Intersection{T}(tca, zero(T), zero(T))
  end

  d2 = dot_(l, l) - tca * tca
  if d2 > radius2
    return Intersection{T}(s.radius - d2, zero(T), zero(T))
  end

  thc = sqrt(radius2 - d2)
  t0 = tca - thc
  t1 = tca + thc
  Intersection{T}(radius2 - d2, t0, t1)
end

"`x`, where `x ∈ scene` and "
function sceneintersect(r::Ray, scene::ListScene)
  tnear = Inf # closest intersection point, FIXME: Type stability
  areintersections = false

  # Determine whether this ray hits any of the spheres, and if so, which one
  hit = false
  sphere = first(scene) # 1 is arbitrary
  for (i, target_sphere) in enumerate(scene)
    # FIXME: Get rid of these constants
    t0 = Inf
    t1 = Inf
    r
    inter = rayintersect(r, target_sphere)
    if inter.doesintersect > 0
      if inter.t0 < 0
        inter.t0 = t1
      end
      if inter.t0 < tnear
        tnear = inter.t0
        sphere = scene[i]
        hit = true
      end
    end
  end
  if hit
    return sphere, tnear
  else
    return nothing, tnear
  end
end

"Position where ray hits object"
hitposition(r::Ray, tnear) = r.orig + r.dir * tnear 

"Normal between `r` and `sphere`"
function normal(hitpos::Vec3, sphere::Sphere, tnear::Real)
  nhit = hitpos - center(sphere)
  nhit = simplenormalize(nhit)
end

"Light contribution from all objects in scene"
function light(scene::Scene, geom::Geometry, hitpos::Vec3, nhit::Vec3, bias = 1e-4)
  surface_color_ = Vec3([0.0, 0.0, 0.0])
  for i = 1:length(scene)
    if scene[i].emission_color[1] > 0.0 # scene[i] is a light
      transmission = 1.0
      light_dir = scene[i].center - hitpos  # FIXME: Don't have this
      light_dir = simplenormalize(light_dir)

      for j = 1:length(scene)
        if (i != j)
          r2 = Ray(hitpos + nhit * bias, light_dir)
          inter = rayintersect(r2, scene[j])
          if (inter.doesintersect > 0)
            transmission = 0.0
          end
        end
      end
      lhs = surface_color(geom) * transmission * rlu(dot_(nhit, light_dir))
      surface_color_ += map(*, lhs, scene[i].emission_color)
    end
  end
  surface_color_
end

sigmoid(x; k=1, x0=0) = 1 / (1+exp(-k*(x - x0)))

"Trace a ray `r` to return a pixel colour.  Bounce ray at most `depth` times"
function trcdepth(r::Ray,
                  scene::Scene,
                  depth::Integer,
                  background::Vec3=Vec3([2.0, 2.0, 2.0]),
                  bias = 1e-4)
  geom, tnear = sceneintersect(r, scene) # FIXME Type instability
  hitpos = hitposition(r, tnear)
  if geom == nothing
    return background
  else
    # @show sigtnear = sigmoid(tnear, k=0.001 )
    sigtnear = 0.5
    Vec3([sigtnear, sigtnear, sigtnear])
  end
end

"Trace a ray `r` to return a pixel colour.  Bounce ray at most `depth` times"
function trc(r::Ray,
             scene::Scene,
             depth::Integer,
             background::Vec3=Vec3([2.0, 2.0, 2.0]),
             bias = 1e-4)
  geom, tnear = sceneintersect(r, scene) # FIXME Type instability
  hitpos = hitposition(r, tnear)
  if geom == nothing
    return background
  else
    # return Vec3([0.5, 0.5, 0.5])
    nhit = normal(hitpos, geom, tnear)
    # If the normal and the view direction are not opposite to each other
    # reverse the normal direction. That also means we are inside the sphere so
    # set the inside bool to true. Finally reverse the sign of IdotN which we
    # want positive.
    # add some bias to the point from which we will be tracing
    inside = false

    if dot_(r.dir, nhit) > 0.0
      nhit = -nhit
      inside = true
    end

    # Another bounce if obj isn't reflective and not transparent
    # Problem: Data dependent branching
    # Want blem: Data dependent branching
    # Want to split some of the branch and not some of the rest
    if ((transparency(geom) > 0.0 || reflection(geom) > 0.0) && depth < 1)
      minusrdir = r.dir * -1.0
      facingratio = dot_(minusrdir, nhit)

      # change the mix value to tweak the effect
      fresneleffect = mix((1.0 - facingratio)^3, 1.0, 0.1)

      # reflection direction (already normalized)
      refldir = simplenormalize(r.dir - nhit * 2 * dot_(r.dir, nhit))
      reflray = Ray(hitpos + nhit * bias, refldir)
      reflection_ = trc(reflray, scene, depth + 1, background)

      # the result is a mix of reflection_ and refraction (if the sphere is transparent)
      prod = reflection_ * fresneleffect
      surface_color_ = map(*, prod, surface_color(geom))
    else
      # Each light contributes to pixel colour
      surface_color_ = light(scene, geom, hitpos, nhit, bias)
    end
    surface_color_ + emission_color(geom)
  end
end

"Render `scene` to image of given `width` and `height`"
function render(scene::Scene,
                width::Integer=100,
                height::Integer=100,
                fov::Real=30.0,
                trc=trc,
                ImgT::T = Real) where T
  inv_width = 1 / width
  angle = tan(pi * 0.5 * fov / 100.0)
  inv_height = 1 / height
  aspect_ratio = width / height

  image = Array{ImgT}(width, height, 3)
  for y = 1:height, x = 1:width
    xx = (2 * ((x + 0.5) * inv_width) - 1) * angle * aspect_ratio
    yy = (1 - 2 * ((y + 0.5) * inv_height)) * angle
    minus1 = -1.0
    raydir = simplenormalize(Vec3([xx, yy, -1.0]))
    pixel = trc(Ray(Vec3([0.0, 0.0, 0.0]), raydir), scene, 0)
    image[x, y, :] = pixel
  end
  image
end

"Generate ray dirs and ray origins"
function rdirs_rorigs(width::Integer=200,
                      height::Integer=200,
                      fov::Real=30.0)
  inv_width = 1 / width
  angle = tan(pi * 0.5 * fov / 100.0)
  inv_height = 1 / height
  aspect_ratio = width / height

  image = zeros(width, height, 3)
  rdirs = Array{Float64}(width * height, 3)
  rorigs = Array{Float64}(width * height, 3)
  j = 1
  for y = 1:height, x = 1:width
    xx = (2 * ((x + 0.5) * inv_width) - 1) * angle * aspect_ratio
    yy = (1 - 2 * ((y + 0.5) * inv_height)) * angle
    minus1 = -1.0
    raydir = simplenormalize(Vec3([xx, yy, -1.0]))
    rorig = Vec3([0.0, 0.0, 0.0])
    rdirs[j, :] = raydir
    rorigs[j, :] = rorig
    # pixel = trc(Ray(Vec3([0.0, 0.0, 0.0]), raydir), spheres, 0)
    # image[x, y, :] = pixel
    j += 1
  end
  rdirs, rorigs
end