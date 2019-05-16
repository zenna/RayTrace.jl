"Linear interpolation between `a` and `b` by factor `mix`"
mix(a, b, mix::Real) = b * mix + a * (1 - mix)

"norm(x)^2"
dot_self(x) = dot_(x, x)

"dot product (without BLAS etc for generality)"
dot_(xs, ys) = sum(xs .* ys)

"normalized x: `x/norm(x)`"
# simplenormalize(x) =  sqrt.(dot_self(x))

# norm(x) = sqrt(dot(x, x))

# simplenormalize(x) =  x ./ norm(x)

# simplenormalize(x) =  x + 10

simplenormalize(x) = x

"x iff x > 0 else 0"
rlu(x) = max(zero(x), x)

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
    if inter.doesintersect > 0.0
      if inter.t0 < 0.0
        inter.t0 = t1
      end
      if inter.t0 < tnear
        tnear = inter.t0
        sphere = scene[i]
        hit = true
      end
    end
  end
  return hit, sphere, tnear
end

"Position where ray hits object"
hitposition(r::Ray, tnear) = r.orig + r.dir * tnear 

"Light contribution from all objects in scene"
function light(scene::Scene, geom, hitpos, nhit, bias = 1e-4)
  surface_color_ = Vec3(0.0, 0.0, 0.0)
  for i = 1:length(scene)
    if emission_color(scene[i])[1] > 0.0 # scene[i] is a light
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
      surface_color_ += map(*, lhs, emission_color(scene[i]))
    end
  end
  surface_color_
end

sigmoid(x; k=1, x0=0) = 1 / (1+exp(-k*(x - x0)))

"Trace a ray `r` to return a pixel colour.  Bounce ray at most `depth` times"
function trcdepth(r::Ray,
                  scene::Scene,
                  background = 1.0,
                  bias = 1e-4,
                  sigtnear = 0.0)
  # didhit, geom, tnear = sceneintersect(r, scene) # FIXME Type instability
  sc = sceneintersect(r, scene)
  # hitpos = hitposition(r, tnear)
  if !(sc[1])
    return background
  else
    # 0.3
    sc[3]
  end
end

"Trace a ray `r` to return a pixel colour.  Bounce ray at most `depth` times"
function fresneltrc(r::Ray,
                    scene::Scene,
                    depth::Integer = 0,
                    background::Vec3 = Vec3(1.0, 1.0, 1.0),
                    bias = 1e-4)
  didhit, geom, tnear = sceneintersect(r, scene) # FIXME Type instability
  if !didhit
    return background
  else
    hitpos = hitposition(r, tnear)
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
      reflection_ = fresneltrc(reflray, scene, depth + 1, background)

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

"$(SIGNATURES) Render `scene` to image of given `width` and `height`"
function render(scene::Scene;
                width = 100,
                height = 100,
                fov = 30.0,
                trc = fresneltrc,
                image = Array{Vec3{Float64}}(undef, height, width))
  inv_width = 1.0 / width
  angle = tan(pi * 0.5 * fov / 100.0)
  inv_height = 1.0 / height
  aspect_ratio = width / height
 
  for x = 1:width
    for y = 1:height
      xx = (2 * ((x + 0.5) * inv_width) - 1.0) * angle * aspect_ratio
      yy = (1 - 2 * ((y + 0.5) * inv_height)) * angle
      raydir = normalize(Vec3(xx, yy, -1.0))
      pixel = trc(Ray(Point(0.0, 0.0, 0.0), raydir), scene)
      @inbounds image[y, x] = pixel
    end
  end
  image
end

function renderpixel(scene, ci, rorig, width, inv_width, inv_height, angle, aspect_ratio, trc)
  y = ci[1]
  x = ci[2]
  # Convert from raster coords to NDC and hten to screen coords
  xx = (2 * ((x + 0.5) * inv_width) - 1.0) * angle * aspect_ratio
  yy = (1 - 2 * ((y + 0.5) * inv_height)) * angle
  raydir = Vec3(xx, yy, -1.0)
  raydir = simplenormalize(raydir)
  trc(Ray(rorig, raydir), scene)
end

# "Pixel coordinates in NDC space (Normalized Device Coordinates):"
# function pixelndx(x, y, inv_height, inv_width)
#   # By convention film plane is 1 unit from cameras origin
#   xndc = x + 0.5 * inv_width
#   yndc = y + 0.5 * inv_height
# end

# function 

"$(SIGNATURES) Render `scene` to image of given `width` and `height`"
function renderfunc(scene::Scene;
                    width = 100,
                    height = 100,
                    fov = 30.0,
                    rorig = Point(0.0, 0.0, 0.0),
                    trc = fresneltrc)
  inv_width = 1.0 / width
  angle = tan(pi * 0.5 * fov / 100.0)
  inv_height = 1.0 / height
  aspect_ratio = width / height
  pixels = map(ci -> renderpixel(scene, ci, rorig, width, inv_width, inv_height,
                                 angle, aspect_ratio, trc),
               CartesianIndices((height, width)))
  reshape(pixels, height, width )
end

"Generate ray dirs from origin"
function rdirs(width = 200, height = 200, fov = 30.0)
  image = Array{Vec3{Float64}}(undef, height, width)

  inv_width = 1 / width
  angle = tan(pi * 0.5 * fov / 100.0)
  inv_height = 1 / height
  aspect_ratio = width / height
  for x = 1:width
    for y = 1:height
      xx = (2 * ((x + 0.5) * inv_width) - 1.0) * angle * aspect_ratio
      yy = (1 - 2 * ((y + 0.5) * inv_height)) * angle
      raydir = normalize(Vec3(xx, yy, -1.0))
      @inbounds image[y, x] = raydir
    end
  end
  image
end