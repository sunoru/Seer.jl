module Main

import ..DataIO: Data, DataFile
import ..Configurations: Config

function train(data::Data, config::Config; datatype::DataFile.DataFileType = DataFile.VASP)
end

function validate(data::Data, config::Config; datatype::DataFile.DataFileType = DataFile.VASP)
end

end
