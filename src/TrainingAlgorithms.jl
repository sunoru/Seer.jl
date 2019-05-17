module TrainingAlgorithms

import Flux

import ..Utils

Utils.@type_enum TrainingAlgorithmType begin
    RMSProp
end

optimizer(::Type{RMSProp}) = Flux.RMSProp()

end
