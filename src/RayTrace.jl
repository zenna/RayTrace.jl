"Simple RayTracer. Modified from:
https://www.scratchapixel.com/code/upload/introduction-rendering/raytracer.cpp"
module RayTrace
using GeometryTypes

# Issues, we should move whole thing to geometry types
# Have issue when using with forward diff with some input values being tracked and some not
# but forward diff doesnt work anyway
# Need to use type unions to make dispatch fast, is there a generic function that can do that

"3 element vector"
Vec3{T} = Vector{T}

include("geometry/geometry.jl")
include("geometry/sphere.jl")
include("scene.jl")
include("render.jl")
include("view.jl")

end
