
#!/bin/bash

show_line_numbers=false
invert_match=false
search_string=""
filename=""
usage="Usage: $0 [-n] [-v] search_string filename"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n)
            show_line_numbers=true
            shift
            ;;
        -v)
            invert_match=true
            shift
            ;;
        -vn|-nv)
            show_line_numbers=true
             invert_match=true
            shift
            ;;
        --help)
            echo "Mini grep command"
            echo "$usage"
            echo "Options:"
            echo "  -n      Show line numbers"
            echo "  -v      Invert match (show non-matching lines)"
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            echo "$usage" >&2
            exit 1
            ;;
        *)
            if [[ -z "$search_string" ]]; then
                search_string="$1"
             elif [[ -z "$filename" ]]; then
                filename="$1"
            else
                echo "Error: Too many arguments" >&2
                echo "$usage" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$search_string" ]]; then
    echo "Error: Missing search string" >&2
    echo "$usage" >&2
    exit 1
fi

if [[ -z "$filename" ]]; then
  echo "Error: Missing filename" >&2
    echo "$usage" >&2
    exit 1
fi

if [[ ! -f "$filename" ]]; then
    echo "Error: File '$filename' not found" >&2
    exit 1
fi

line_number=0
while IFS= read -r line; do
    ((line_number++))
    
  
    if [[ "${line,,}" == *"${search_string,,}"* ]]; then
        match=true
    else
        match=false
     fi
    
 
    if [[ $invert_match == true ]]; then
        match=$(! $match)
    fi
    
  
    if $match; then
        if $show_line_numbers; then
            printf "%d:" "$line_number"
        fi
        printf "%s\n" "$line"
    fi
done < "$filename"
