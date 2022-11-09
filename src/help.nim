proc writeHelpSection*() =
    echo """
json2nim is a tool to convert JSON schema to Nim type declarations.

Usage:
    json2nim

Options:

    -f:<filename>, --file:<filename>       # The input file containing the json schema
    
    -o:<filename>, --outfile:<filename>    # The output file the will contain the nim type declatations

    -p, --public                           # Make the generated types public

    -h, --help                             # Show this help message

    -v, --version                          # Show the version number
    
Example:
    json2nim -f:mySchema.json -o:myTypes.nim -p
"""
