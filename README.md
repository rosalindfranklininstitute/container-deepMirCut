# container-deepMirCut

Install as a module share module using `shpc`.

```
# Install
cd /path/to/registry
git clone git@github.com:rosalindfranklininstitute/container-deepMirCut.git
shpc install deepMirCut

# Update
cd /path/to/registry/deepMirCut
git pull
shpc install deepMirCut

# Usage
module load deepMirCut

# Open deepMirCut GUI by running
deepMirCut

# Run commands against the container
deepMirCut-run which deepMirCut
# gives the path within the container to the install location
/usr/local/deepMirCut/bin/deepMirCut

# Print the module usage help
module help deepMirCut
```

This module aliases `deepMirCut` to `/usr/local/deepMirCut/bin/deepMirCut` within the container. 