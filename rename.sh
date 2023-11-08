#!/bin/bash

# Create the target directory if it doesn't exist
mkdir -p app/javascript/components

# Find and move/rename .js files that are not inside "form_components"
find app/components -name 'script.js' -not -path 'app/components/form_components/*' -exec bash -c '
    file="$1"
    dir_name=$(basename $(dirname "$file"))
    new_path="app/javascript/components/${dir_name}.js"
    mv "$file" "$new_path"
' bash {} \;

# Handle the "form_components" directory separately
find app/components/form_components -name 'script.js' -exec bash -c '
    file="$1"
    path_without_prefix="${file#app/components/}"
    sub_path="${path_without_prefix%/script.js}"
    mkdir -p "app/javascript/components/${sub_path}"
    new_path="app/javascript/components/${sub_path}.js"
    mv "$file" "$new_path"
' bash {} \;
