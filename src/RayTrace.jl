__precompile__()

"Simple RayTracer. Modified from:
https://www.scratchapixel.com/code/upload/introduction-rendering/raytracer.cpp"
module RayTrace

"3 element vector"
Vec3{T} = Vector{T}

include("geometry/geometry.jl")
include("geometry/sphere.jl")
include("scene.jl")
include("render.jl")

end
