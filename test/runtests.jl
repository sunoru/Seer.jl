using Seer

# Load structure from vasp data.
Seer.DataIO.load_data(NetworkInput.Structure, "../examples/diamond-carbon/data/1", DataFile.VASP)
