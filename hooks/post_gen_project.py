import json
from pathlib import Path
from collections import OrderedDict

context = OrderedDict({{cookiecutter}})

# Path to the output file
output_file = Path("../selected_values.json")

# Write the context to the output file
with open(output_file, 'w') as f:
    json.dump(context, f, indent=4)
