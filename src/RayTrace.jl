"Simple RayTracer. Modified from:
https://www.scratchapixel.com/code/upload/introduction-rendering/raytracer.cpp"
module RayTrace
using GeometryTypes
using DocStringExtensions

include("material.jl")
include("ray.jl")
include("intersection.jl")

include("geometry/geometry.jl")
include("geometry/sphere.jl")
include("geometry/box.jl")
include("scene.jl")

include("render.jl")
include("view.jl")
include("example.jl")

end
