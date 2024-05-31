# Metadata Remover Script

A Bash script to remove metadata from files using `exiftool`. The script can remove all metadata, specific tags, and process multiple file types.

## Features

- **Remove All Metadata:** Strip all metadata from specified files.
- **Backup Original Files:** Option to create backups before removing metadata.
- **Remove Specific Tags:** Option to remove specific metadata tags.
- **Process Multiple File Types:** Option to process files with various extensions (jpg, png, mp4, etc.).

## Prerequisites

- **Homebrew:** Make sure you have Homebrew installed on your macOS. If not, install it from [brew.sh](https://brew.sh/).
- **exiftool:** A tool for reading, writing, and editing metadata.

## Installation

### 1. Install `exiftool`

Open your terminal and run:
```sh
brew install exiftool
```
2. Download the Script
Save the following script as `remove_metadata.sh`:
```
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
```

### Explanation
- Regex for File Extensions: Updated the script to use a regular expression to check for file extensions when the `-e` option is used.
- Process Files: The script now correctly processes each file matching the specified extensions in the provided directory.
- 
Usage
- Remove All Metadata:


- Copy code
```sh
./metadata_tool.sh file1.jpg file2.png
```

Backup Original Files:

Copy code
```sh
./metadata_tool.sh -b file1.jpg file2.png
```
- Remove Specific Metadata Tags:


- Copy code
```sh
./metadata_tool.sh -t "GPS*" -t "EXIF:DateTimeOriginal" file1.jpg file2.png
```

- View EXIF Metadata:


Copy code
```sh
./metadata_tool.sh -v file1.jpg file2.png
```
Process Multiple File Types in Directory:


Copy code

```sh
./metadata_tool.sh -e /Users/rio/Desktop/*
```

- Testing
Ensure the script is executable:


Copy code
```sh
chmod +x metadata_tool.sh
```

Run the script with the desired options and verify that it processes files correctly. If the issue persists, please provide additional details so I can further assist.
