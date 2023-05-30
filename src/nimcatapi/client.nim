import std/[asyncdispatch, httpclient, json, strutils, strformat, options]
import ./typedefs

using
    api: AnimalApi
    url: string
    request: Request

var client: AsyncHttpClient = newAsyncHttpClient()



# -----------------------------------------------------------------------------
# Error handling:
# -----------------------------------------------------------------------------

proc errorLog(msg: string) =
    stderr.writeLine("[nimcatapi] " & msg)



# -----------------------------------------------------------------------------
# API client creation:
# -----------------------------------------------------------------------------

proc getNewClient(T: AnimalApiKind, token: string): AnimalApi =
    result = AnimalApi(
        kind: T,
        token: none string
    )
    if token != "": result.token = some token
    return result

proc newCatApiClient*(token: string = ""): AnimalApi =
    ## Creates a new AnimalApi with thecatapi.com url.
    ## Token is optional, as you can request from the API without it as well.
    getNewClient(TheCatApi, token)
proc newDogApiClient*(token: string = ""): AnimalApi =
    ## Creates a new AnimalApi with thedogapi.com url.
    ## Token is optional, as you can request from the API without it as well.
    getNewClient(TheDogApi, token)



# -----------------------------------------------------------------------------
# URL stuff:
# -----------------------------------------------------------------------------

proc getResponse*(url): Future[string] {.async.} =
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

proc getImagesFromResponse(response: JsonNode): seq[string] =
    ## Loops over response json and pick `"url"` field from objects.
    if response.kind == JObject:
        if response.hasKey("msg"):
            errorLog(response["msg"].str)

    try:
        for i in response:
            if not i.hasKey("url"): continue
            result.add(i["url"].str)
    except CatchableError:
        errorLog("Invalid response received: " & $response)



# -----------------------------------------------------------------------------
# Public request procs:
# -----------------------------------------------------------------------------

proc requestImageUrl*(api): string =
    ## Requests a single image from the API.
    let response: JsonNode = api.sendRequest(Request())
    return response.getImagesFromResponse()[0]


proc requestImageUrls*(api, request): seq[string] =
    ## Requests images with custom parameters in `Request` object.
    ## 
    ## Without a token you can request 1 or 10 images only, with a token you can request 1-100.
    let response: JsonNode = api.sendRequest(request)
    return response.getImagesFromResponse()

proc requestImageUrls*(api; amount: Positive): seq[string] =
    ## Requests multiple images.
    ## 
    ## Without a token you can request 1 or 10 images only, with a token you can request 1-100.
    let response: JsonNode = api.sendRequest(Request(
        limit: some int amount
    ))
    return response.getImagesFromResponse()

proc requestImageUrls*(api; size: ImageSize = sizeNone, formats: seq[ImageFormat], amount: Positive = 1): seq[string] =
    ## Requests images with custom parameters.
    ## 
    ## Without a token you can request 1 or 10 images only, with a token you can request 1-100.

    var request: Request = Request()
    if size != sizeNone:
        request.size = some size
    if formats.len() != 0:
        request.mime_types = some formats
    if amount > 0:
        request.limit = some int amount

    let response: JsonNode = api.sendRequest(request)
    return response.getImagesFromResponse()

proc requestImageUrls*(api; size: ImageSize = sizeNone, format: ImageFormat, amount: Positive = 1): seq[string] =
    ## Requests images with custom parameters.
    ## 
    ## Without a token you can request 1 or 10 images only, with a token you can request 1-100.
    return api.requestImageUrls(size, @[format], amount)


