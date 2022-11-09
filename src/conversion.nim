import std/[json, strformat, sequtils]

proc createTabs(num: int): string =
    result = ""
    for i in 0 ..< (2*num):
        result.add("  ")


proc convertJsonToNim*(jsonInput: string, public: bool, objName = 1): string =
    var parsedJson: JsonNode

    try:
        parsedJson = parseJson(jsonInput)
    except:
        raise newException(ValueError, "Invalid JSON")


    var typeLines: seq[string] =
        if public:
            @["type", fmt"{createTabs(objName)}NimObj{objName}*: object"]
        else:
            @["type", fmt"{createTabs(objName)}NimObj{objName}: object"]


    for key, val in parsedJson:
        case val.kind
        of JString:
            if public:
                typeLines.add(fmt("{createTabs(objName+1)}{key}*: string"))
            else:
                typeLines.add(fmt("{createTabs(objName+1)}{key}: string"))

        of JInt:
            if public:
                typeLines.add(fmt("{createTabs(objName+1)}{key}*: int"))
            else:
                typeLines.add(fmt("{createTabs(objName+1)}{key}: int"))

        of JFloat:
            if public:
                typeLines.add(fmt("{createTabs(objName+1)}{key}*: float"))
            else:
                typeLines.add(fmt("{createTabs(objName+1)}{key}: float"))

        of JBool:
            if public:
                typeLines.add(fmt("{createTabs(objName+1)}{key}*: bool"))
            else:
                typeLines.add(fmt("{createTabs(objName+1)}{key}: bool"))

        of JArray: #TODO: fix this, recursive??
            discard

        of JObject: #TODO fix this, recursive??
            discard

        of JNull:
            discard


    result = typeLines.foldr(a & "\n" & b)




#TODO:
    # - add support for arrays
    # - add support for nested objects
    # - add support for null values
    # - add support for ref objects
    # - README
    # - webpage and website?
