import std/[os, parseopt, sequtils]
import help, conversion

# TODO:
    #- CLI for streaming, stdin, from file
    #- CLI options for types (public exports, etc...)
    #- TODO add ability for nim objects to be references
    #- webpage and online tool??

const VERSION = "0.1.0"
proc writeVersion() = echo VERSION


proc main() =
    # opts:
    # -f, --file:<filename>
    # -o, --outfile:<filename>
    # -p, --public
    # -h, --help, default
    # -v, --version

    let cmdParams = commandLineParams()
    var optParser =
        if cmdParams.len == 0:
        initOptParser("")
      else:
        initOptParser(cmdParams.foldr(a & " " & b))

    var input = stdin
    var output = stdout
    var public = false

    defer: input.close()
    defer: output.close()

    var shouldContinue = true

    # Command line parsing loop
    for kind, key, val in optParser.getopt():
        case kind
        of cmdShortOption, cmdLongOption:
            case key

            of "h", "help":
                writeHelpSection()
                shouldContinue = false
                break

            of "v", "version":
                writeVersion()
                shouldContinue = false
                break

            of "f", "file":
                # this overwrites stdin as the input file
                try:
                    input = open(val, fmRead)

                except:
                    echo "Error: problem encountered when attempting to open '" &
                            val & "'"
                    shouldContinue = false
                    break


            of "o", "outfile":
                # this overwrites stdout as the output file
                try:
                    output = open(val, fmWrite)

                except:
                    echo "Error: problem encountered when attempting to open '" &
                            val & "'"
                    shouldContinue = false
                    break

            of "p", "public":
                # makes the nim type definitions public outside the module
                public = true

            else:
                echo "Invalid usage\n"
                writeHelpSection()
                shouldContinue = false
                break

        else:
            break

    # We should exit here if there was a problem with the setup
    if not shouldContinue:
        return


    var inputLines = ""

    # This will block on stdin until EOF or read a file line by line
    for line in input.lines():
        inputLines &= line & "\n"

    var nimTypeString = ""

    try:
        nimTypeString = convertJsonToNim(inputLines, public)

    except:
        echo "Error: problem encountered when attempting to convert json to nim"
        return

    output.write(nimTypeString)


    # read input (block on stdin or read file)
    # do the actual conversions
    # write output to file or stdout




when isMainModule:
    main()
