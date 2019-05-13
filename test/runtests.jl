using Seer

BASE_DIR = abspath(joinpath(@__DIR__, ".."))

test_filename = joinpath(BASE_DIR, "examples/diamond-carbon/data/1")
# Load structure from vasp data.
Seer.DataIO.load_data(NetworkInput.Structure, test_filename, DataFile.VASP)
