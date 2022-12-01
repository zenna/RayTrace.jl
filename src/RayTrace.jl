__precompile__()

"Simple RayTracer. Modified from:
https://www.scratchapixel.com/code/upload/introduction-rendering/raytracer.cpp"
module RayTrace
import Jaxy: cond, eachrow_eager, mapg
export cond

"3 element vector"
Vec3{T} = Vector{T}

include("geometry/geometry.jl")
include("geometry/sphere.jl")
include("scene.jl")
include("render.jl")
include("view.jl")

end
