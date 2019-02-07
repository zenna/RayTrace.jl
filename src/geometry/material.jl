struct Material{TSC, TRF, TRA, TE}
  surface_color::TSC  # color of surface
  reflection::TRF
  transparency::TRA
  emission_color::TE
end

struct MaterialGeom{Geom, Material} <: Geometry
  geom::Geom          # Geometry Type
  material::Material  # Material
end

Base.getproperty(m::MaterialGeom)