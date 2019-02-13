struct Material{TSC, TRF, TRA, TE}
  surface_color::TSC  # color of surface
  reflection::TRF
  transparency::TRA
  emission_color::TE
end

struct MaterialGeom{Geom, Material}
  geom::Geom          # Geometry Type
  material::Material  # Material
end

# Base.getproperty(m::MaterialGeom)

function Base.getproperty(x::MaterialGeom, k::Symbol)
  if k == :geom || k == :material
    getfield(x, k)
  else
    getfield(getfield(x, :geom), k)
  end
end

surface_color(geom::MaterialGeom) = geom.material.surface_color
reflection(geom::MaterialGeom) = geom.material.reflection
transparency(geom::MaterialGeom) = geom.material.transparency
emission_color(geom::MaterialGeom) = geom.material.emission_color


msphere(c, r, su, re, tr, em) = MaterialGeom(Sphere(c, r), Material(su, re, tr, em))
