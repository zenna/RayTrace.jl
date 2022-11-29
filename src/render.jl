"Light ray with origin `orig` and direction `dir`"
struct Ray{T1, T2}
  orig::T1
  dir::T2
end

"Linear interpolation between `a` and `b` by factor `mix`"
mix(a, b, mix::Real) = b * mix + a * (1 - mix)

"norm(x)^2"
dot_self(x) = dot_(x, x)

# function map3(f, xs)
#   [f(xs[1]), f(xs[2]), f(xs[3])]
# end

# function map3(f, xs, ys)
#   [f(xs[1], ys[1]), f(xs[2], ys[2]), f(xs[3], ys[3])]
# end

"dot product (without BLAS etc for generality)"
dot_(xs, ys) = sum(map(*, xs, ys))

"normalized x: `x/norm(x)`"
simplenormalize(x) = (den = sqrt(dot_self(x)); x / den)

"x iff x > 0 else 0"
rlu(x) = max(0, x)

"Result of intersection between ray and object"
mutable struct Intersection{T1, T2, T3}
  doesintersect::T1
  t0::T2
  t1::T3
end

"Intersection information between ray `r` and sphere `s`"
function rayintersect(r::Ray, s)
  l = map(-, s.center, r.orig)
  tca = dot_(l, r.dir)
  d2 = dot_(l, l) - tca * tca
  radius2 = s.radius * s.radius
  # d2_greater(d2, tca, r) = (r - d2, 0.0, 0.0)
  d2_greater(d2, r) = (r - d2, 0.0, 0.0)
  function d2_lesser(d2, tca, r2)
    # r2 = r * r
    tch = sqrt(r2 - d2)
    (r2 - d2, tca - tch, tca + tch)
  end
  # return Intersection(ifelse(tca < 0, (tca, 0.0, 0.0), (d2 > radius2, d2_greater, d2_lesser, d2, tca, s.radius))...)
  return Intersection(ifelse(tca < 0, (tca, 0.0, 0.0), cond(d2 > radius2, d2_greater, d2_lesser, (d2, s.radius), (d2, tca, radius2)))...)
end

"`x`, where `x ∈ scene` and "
function sceneintersect(r::Ray, scene)
  tnear = Inf # closest intersection point, FIXME: Type stability
  areintersections = false

  # Determine whether this ray hits any of the spheres, and if so, which one
  hit = false
  sphere = first(scene) # 1 is arbitrary
  for (i, target_sphere) in enumerate(scene.geoms)
    # FIXME: Get rid of these constants
    t0 = Inf
    t1 = Inf
    r
    inter = rayintersect(r, target_sphere)
    # if inter.doesintersect > 0.0
    #   if inter.t0 < 0.0
    #     inter.t0 = t1
    #   end
    #   if inter.t0 < tnear
    #     tnear = inter.t0
    #     sphere = scene[i]
    #     hit = true
    #   end
    # end
    inter = Intersection(inter.doesintersect, ifelse((inter.doesintersect > 0.0) & (inter.t0 < 0.0), t1, inter.t0), inter.t1)
    tnear = ifelse((inter.doesintersect > 0.0) & (inter.t0 < tnear), inter.t0, tnear)
    sphere = ifelse((inter.doesintersect > 0.0) & (inter.t0 < tnear), scene[i], sphere)
    hit = ifelse((inter.doesintersect > 0.0) & (inter.t0 < tnear), true, hit)
  end
  return hit, sphere, tnear
end

"Position where ray hits object"
hitposition(r::Ray, tnear) = r.orig + r.dir * tnear 

"Normal between `r` and `sphere`"
function normal(hitpos, sphere, tnear)
  nhit = map(-, hitpos, center(sphere))
  # nhit = hitpos .- center(sphere)
  nhit = simplenormalize(nhit)
end

"Light contribution from all objects in scene"
function light(scene, geom, hitpos, nhit, bias = 1e-4)
  surface_color_ = Float64[0.0, 0.0, 0.0]
  for i = 1:length(scene)
    transmission = 1.
    light_dir = scene[i].center - hitpos
    light_dir = simplenormalize(light_dir)
    for j = 1:length(scene)
      x = hitpos + nhit * bias
      r2 = Ray(x, light_dir)
      inter = rayintersect(r2, scene[j])
      transmission = ifelse(!(i == j) & (inter.doesintersect > 0), 0.0, transmission)
    end
    lhs = surface_color(geom) * transmission * rlu(dot_(nhit, light_dir))
    surface_color_ += map(*, lhs, scene[i].emission_color)
  end
  surface_color_
end

sigmoid(x; k=1, x0=0) = 1 / (1+exp(-k*(x - x0)))

"Trace a ray `r` to return a pixel colour.  Bounce ray at most `depth` times"
function trcdepth(r::Ray,
                  scene::Scene,
                  depth::Integer,
                  background = Float64[1.0, 1.0, 1.0],
                  bias = 1e-4,
                  sigtnear = 0.0)
  didhit, geom, tnear = sceneintersect(r, scene) # FIXME Type instability
  # hitpos = hitposition(r, tnear)
  # if !didhit
  #   return background
  # else
  #   # @show sigtnear = sigmoid(tnear, k=0.001 )
  #   Float64[sigtnear, sigtnear, sigtnear]
  # end
  return ifelse(!didhit, background, Float64[sigtnear, sigtnear, sigtnear])
end

"Trace a ray `r` to return a pixel colour.  Bounce ray at most `depth` times"
function fresneltrc(r::Ray,
                    scene,
                    depth::Integer,
                    background = Float64[1.0, 1.0, 1.0],
                    bias = 1e-4)
  didhit, geom, tnear = sceneintersect(r, scene) # FIXME Type instability

  function λt(scene, geom, hitpos, nhit, bias, r, background)
    minusrdir = r.dir * -1.0
    facingratio = dot_(minusrdir, nhit)

    # change the mix value to tweak the effect
    fresneleffect = mix((1.0 - facingratio)^3, 1.0, 0.1)

    # reflection direction (already normalized)
    refldir = simplenormalize(r.dir - nhit * 2 * dot_(r.dir, nhit))
    reflray = Ray(hitpos + nhit * bias, refldir)
    reflection_ = fresneltrc(reflray, scene, depth + 1, background)

    # the result is a mix of reflection_ and refraction (if the sphere is transparent)
    prod = reflection_ * fresneleffect
    map(*, prod, surface_color(geom))
  end
  hitpos = hitposition(r, tnear)
  nhit = normal(hitpos, geom, tnear)
  inside = dot_(r.dir, nhit)
  nhit = ifelse(dot_(r.dir, nhit) > 0.0, -nhit, nhit)
  p = (((transparency(geom) > 0.0) | (reflection(geom) > 0.0)) & (depth < 1))
  # surface_color_ = cond(p, λt, (scene, geom, hitpos, nhit, bias, r, background) -> light(scene, geom, hitpos, nhit, bias), scene, geom, hitpos, nhit, bias, r, background)
  surface_color_ = cond(p, λt, light, (scene, geom, hitpos, nhit, bias, r, background), (scene, geom, hitpos, nhit, bias))
  ifelse(!didhit, background, surface_color_ + emission_color(geom))
end

"Render `scene` to image of given `width` and `height`"
function render(scene::Scene;
                width::Int = 100,
                height::Int = 100,
                fov::Float64 = 30.0,
                trc = fresneltrc,
                image = zeros(width, height, 3))
  inv_width = 1.0 / width
  angle = tan(pi * 0.5 * fov / 100.0)
  inv_height = 1.0 / height
  aspect_ratio = width / height
  pixels = []
 
  for y = 1:height
    for x = 1:width
      xx = (2 * ((x + 0.5) * inv_width) - 1.0) * angle * aspect_ratio
      yy = (1 - 2 * ((y + 0.5) * inv_height)) * angle
      minus1 = -1.0
      raydir = simplenormalize(Float64[xx, yy, -1.0])
      pixel = trc(Ray(Float64[0.0, 0.0, 0.0], raydir), scene, 0)
      Base.push!(pixels, pixel)
      # image[x, y, :] = pixel
    end
  end
  pixels
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
  rdirs = Array{Float64}(undef, width * height, 3)
  rorigs = Array{Float64}(undef, width * height, 3)
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


"Render `scene` to image of given `width` and `height`"
function render_map(scene::Scene;
                    rdirs,
                    trc = fresneltrc)
  map(dir -> trc(Ray(Float64[0.0, 0.0, 0.0], @show(dir)), scene, 0), eachrow(rdirs))  
end

function test(scene)
  rdirs, rorigs = rdirs_rorigs(100, 100)
  render_map(scene; rdirs = rdirs, trc = trcdepth)
end
