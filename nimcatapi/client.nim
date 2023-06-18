## Client documentation
## ====================
## 
## This page covers all procs you can call in detail. For a basic introduction, see the main page.
## 


import std/[json, options]
import ./typedefs, ./internal

using
    api: AnimalApi
    url: string
    request: Request



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
    ## 
    ## Token is optional, as you can request from the API without it as well.
    getNewClient(TheCatApi, token)
proc newDogApiClient*(token: string = ""): AnimalApi =
    ## Creates a new AnimalApi with thedogapi.com url.
    ## 
    ## Token is optional, as you can request from the API without it as well.
    getNewClient(TheDogApi, token)



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


