## Internal procs
## ==============
## 
## These procs are used internally. Only manually call them if you know what you are doing! :)
## 

import std/[asyncdispatch, httpclient, json, strutils, strformat, options]
import ./typedefs

type Re = typedefs.Response

using
    api: AnimalApi
    url: string
    request: Request

var client: AsyncHttpClient = newAsyncHttpClient()


# -----------------------------------------------------------------------------
# Error handling:
# -----------------------------------------------------------------------------

proc errorLog*(msg: string) =
    ## Very basic error handler/debugger:
    stderr.writeLine("[nimcatapi error] " & msg)



# -----------------------------------------------------------------------------
# URL stuff:
# -----------------------------------------------------------------------------

proc getResponse(url): Future[string] {.async.} =
    ## Local proc to send GET requests.
    return await client.getContent(url)


proc buildRequest*(api, request): string =
    ## Builds an url string from request data, that can be sent to the API.
    ## 
    ## Should not be called manually, used internally.
    var args: seq[string]

    # Amount of pictures:
    if request.limit.isSome():
        args.add(&"limit={request.limit.get()}")
    
    # Image size:
    if request.size.isSome():
        args.add(&"size={$request.size}")

    # File types:
    if request.mime_types.isSome():
        var list: seq[string]
        for frmt in request.mime_types.get():
            list.add($frmt)
        
        let joinedList: string = list.join(",")
        args.add(&"mime_types={joinedList}")
    
    # Breeds:
    if request.has_breeds.isSome():
        args.add(&"has_breeds=1")

    # Token:
    if api.token.isSome():
        args.add(&"api_key={api.token.get()}")

    # Final construction:
    result = $api.kind
    if args.len() != 0:
        result.add("?")
        result.add(args.join("&"))

    return result


proc sendRequest*(api, request): JsonNode =
    ## Get raw json result from the API.
    ## 
    ## Should not be called manually just to get images. Use `requestImageUrl()` and `requestImageUrls()` instead!
    ## 
    ## See **https://developers.thecatapi.com/** for information on how data is structured.
    let response: string = waitFor api.buildRequest(request).getResponse()
    try:
        result = response.parseJson()
    except JsonParsingError:
        result = """{"message": "Could not parse response from api."}""".parseJson()
        errorLog("Could not parse response from api.")



# -----------------------------------------------------------------------------
# Parsing procs:
# -----------------------------------------------------------------------------

proc getImagesFromResponseRawJsonNode*(response: JsonNode): seq[string] =
    ## Loops over response json and pick `"url"` field from objects.
    ## 
    ## (old implementation)
    if response.kind == JObject:
        if response.hasKey("msg"):
            errorLog(response["msg"].str)

    try:
        for i in response:
            if not i.hasKey("url"): continue
            result.add(i["url"].str)
    except CatchableError:
        errorLog("Invalid response received: " & $response)


proc getImagesFromResponse*(response: seq[Re]): seq[string] =
    for i in response:
        result.add(i.url)

proc getImagesFromResponse*(response: JsonNode): seq[string] =
    ## Converts response to `Response` object and returns only images:
    try:
        let r: seq[Re] = response.to(seq[Re])
        return r.getImagesFromResponse()
    except CatchableError:
        errorLog("Got invalid JsonNode from api - tried to convert to Response obj:\n" & $response)
        return @[]


