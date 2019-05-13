module Bases

import StaticArrays: SVector, SMatrix

const Nullable{T} = Union{Nothing, T}
const Vector3 = SVector{3, Float64}
const Matrix3 = SMatrix{3, 3, Float64}

end
