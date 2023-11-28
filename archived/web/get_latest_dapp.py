from os import path, walk
import json
from pathlib import Path
import shutil

this_path = Path(path.abspath(__file__)).parent
out_data_dir = path.join(this_path, "public", "data")
in_data_dir = path.join(this_path, "..", "dapp")

in_data_file_names = next(walk(in_data_dir), (None, None, []))[2]

for files in in_data_file_names:
    src = path.join(in_data_dir, files)
    dst = path.join(out_data_dir, files)
    shutil.copyfile(src, dst)
