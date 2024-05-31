#!/bin/bash

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null
then
    echo "exiftool is not installed. Please install using 'brew install exiftool'."
    exit
fi

# Function to display usage instructions
usage() {
    echo "Usage: $0 [-b] [-t <tag>] [-e] [-v] <files...>"
    echo "  -b            Backup original files"
    echo "  -t <tag>      Remove specific metadata tag (can be used multiple times)"
    echo "  -e            Process multiple file types (jpg, jpeg, png, gif, bmp, tiff, mp4, mov)"
    echo "  -v            View EXIF metadata"
    exit 1
}

# Parse options
BACKUP=false
TAGS=()
EXTENSIONS=false
VIEW_METADATA=false

while getopts "bt:ev" opt; do
    case $opt in
        b)
            BACKUP=true
            ;;
        t)
            TAGS+=("$OPTARG")
            ;;
        e)
            EXTENSIONS=true
            ;;
        v)
            VIEW_METADATA=true
            ;;
        *)
            usage
            ;;
    esac
done

# Shift to get file arguments
shift $((OPTIND - 1))

# Check if files are provided
if [ $# -eq 0 ]; then
    usage
fi

# Function to remove metadata
remove_metadata() {
    local file=$1
    local options=""

    if $BACKUP; then
        options+=" -overwrite_original_in_place"
    else
        options+=" -overwrite_original"
    fi

    if [ ${#TAGS[@]} -eq 0 ]; then
        options+=" -all="
    else
        for tag in "${TAGS[@]}"; do
            options+=" -${tag}="
        done
    fi

    exiftool $options "$file"
}

# Function to view metadata
view_metadata() {
    local file=$1
    exiftool -n "$file"
}

# Process files
for file in "$@"; do
    if $EXTENSIONS; then
        if [[ $file =~ \.(jpg|jpeg|png|gif|bmp|tiff|mp4|mov)$ ]]; then
            if $VIEW_METADATA; then
                view_metadata "$file"
            else
                remove_metadata "$file"
            fi
        fi
    else
        if $VIEW_METADATA; then
            view_metadata "$file"
        else
            remove_metadata "$file"
        fi
    fi
done

if $VIEW_METADATA; then
    echo "EXIF metadata displayed."
else
    echo "Metadata removal completed."
fi
