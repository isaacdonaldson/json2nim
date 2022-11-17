import std/[json, strformat, strutils, sequtils, oids]


# Creates the proper tab spacing that Nim requires since it is indentation based
# createTabs(1) returns "  "
# createTabs(2) returns "    "
proc createTabs(num: int): string =
    result = ""
    for i in 0 ..< (2*num):
        result.add("  ")


# forward definition
proc parseJArray(val: JsonNode, key: string, public: bool, objNumber: int,
        recursionIdx = 1): (string, string, string)



proc parseJObject(incomingVal: JsonNode, public: bool,
        objNumber = 1, recursionIdx = 1): (string, string) =
    if recursionIdx > 1000:
        raise newException(ValueError, "Too many nested objects")

    # set the result to empty and append to it at the end
    result = ("", "")

    let newTypeName = fmt"NimObj{$genOid()}{objNumber}"

    # this is different because for nested objects we want to create a new object
    var typeLines: seq[string] =
        if public:
            # the '*' is needed for public types
            @["type", fmt"{createTabs(recursionIdx)}{newTypeName}* = object"]
        else:
            @["type", fmt"{createTabs(recursionIdx)}{newTypeName} = object"]


    for key, val in incomingVal:
        case val.kind
        of JString:
            if public:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}*: string"))
            else:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}: string"))

        of JInt:
            if public:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}*: int"))
            else:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}: int"))

        of JFloat:
            if public:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}*: float"))
            else:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}: float"))

        of JBool:
            if public:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}*: bool"))
            else:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}: bool"))

        of JArray: #TODO: fix this, recursive??
            let (typeLine, typeDef, newTypeName) = parseJArray(val[0], key,
                    public, objNumber, recursionIdx)

            typeLines.add(typeLine)

            if typeDef != "":
                result = (result[0] & typeDef, newTypeName)



        of JObject: #TODO fix this, recursive??
            # prepend a new object definition to the start of this type def
            # now add the type def in this current object definition in place of '^TYPE'
            let (newTypeDef, newTypeName) = parseJObject(val, public,
                    objNumber+1, 1)

            if public:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}*: {newTypeName}"))
            else:
                typeLines.add(fmt("{createTabs(recursionIdx+1)}{key}: {newTypeName}"))

            result = (fmt"{newTypeDef}" & "\n\n" & result[0], newTypeName)


        of JNull:
            discard

    result = (result[0] & typeLines.foldr(a & "\n" & b), newTypeName)



proc parseJArray(val: JsonNode, key: string, public: bool,
        objNumber: int, recursionIdx = 1): (string, string, string) =

    # Since this can be called recursively, we add a guard to prevent infinite recursion at 1000 times
    if recursionIdx > 1000:
        raise newException(ValueError, "Too many nested objects")


    result = ("", "", "")

    if public:
        result = (fmt"{createTabs(recursionIdx+1)}{key}*: ^TYPE", "", "")
    else:
        result = (fmt"{createTabs(recursionIdx+1)}{key}: ^TYPE", "", "")


    var numSeq = "^TYPE"
    for num in 0 ..< recursionIdx:
        numSeq = "seq[" & numSeq & "]"

    result = (result[0].replace("^TYPE", numSeq), "", "")

    case val.kind
    of JString:
        result = (result[0].replace("^TYPE", "string"), "", "")


    of JInt:
        result = (result[0].replace("^TYPE", "int"), "", "")

    of JFloat:
        result = (result[0].replace("^TYPE", "float"), "", "")

    of JBool:
        result = (result[0].replace("^TYPE", "bool"), "", "")


    of JArray:
        #this is a recursive call
        result = parseJArray(val[0], key, public, objNumber, recursionIdx)

    of JObject:
        # prepend a new object definition to the start of this type def
        # now add the type def in this current object definition in place of '^TYPE'
        let (newTypeDef, newTypeName) = parseJObject(val, public, objNumber+1, 1)

        result = (result[0].replace("^TYPE",
                newTypeName), fmt"{newTypeDef}" & "\n\n", newTypeName)


    of JNull:
        discard





# This does the main conversion from JSON to Nim type
# It takes the input string and whether the Nim struct should be public
# the objName defaults to 1, but is used to create the proper indentation, and can be increased for recursion
# This function will return a string containing the Nim code that can then be written to a file
proc convertJsonToNim*(jsonInput: string, public: bool, objName = 1): string =
    var parsedJson: JsonNode

    # Attempt to parse the JSON
    # unsuccessful parsing will throw an exception
    try:
        parsedJson = parseJson(jsonInput)
    except:
        raise newException(ValueError, "Invalid JSON")



    # join the lines together to send back
    let (strResult, _) = parseJObject(parsedJson, public)

    result = strResult


