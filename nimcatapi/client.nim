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

proc getToken(token: string): Option[string] =
    if token == "":
        return none string
    else:
        return some token

proc newCatApiClient*(token: string = ""): TheCatApi =
    ## Creates a new AnimalApi with thecatapi.com url.
    ## 
    ## Token is optional, as you can request from the API without it as well.
    return TheCatApi(
        url: $TheCatApiUrl,
        token: token.getToken()
    )
proc newDogApiClient*(token: string = ""): TheDogApi =
    ## Creates a new AnimalApi with thedogapi.com url.
    ## 
    ## Token is optional, as you can request from the API without it as well.
    return TheDogApi(
        url: $TheDogApiUrl,
        token: token.getToken()
    )



# -----------------------------------------------------------------------------
# Public request procs:
# -----------------------------------------------------------------------------

# Images:

proc requestImageUrl*(api): string =
    ## Requests a single image from the API.
    let response: JsonNode = api.sendRequest(imageSearch, Request())
    return response.getImagesFromResponse()[0]


proc requestImageUrls*(api, request): seq[string] =
    ## Requests images with custom parameters in `Request` object.
    ## 
    ## Without a token you can request 1 or 10 images only, with a token you can request 1-100.
    let response: JsonNode = api.sendRequest(imageSearch, request)
    return response.getImagesFromResponse()

proc requestImageUrls*(api; amount: Positive): seq[string] =
    ## Requests multiple images.
    ## 
    ## Without a token you can request 1 or 10 images only, with a token you can request 1-100.
    let response: JsonNode = api.sendRequest(imageSearch, Request(
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

    let response: JsonNode = api.sendRequest(imageSearch, request)
    return response.getImagesFromResponse()

proc requestImageUrls*(api; size: ImageSize = sizeNone, format: ImageFormat, amount: Positive = 1): seq[string] =
    ## Requests images with custom parameters.
    ## 
    ## Without a token you can request 1 or 10 images only, with a token you can request 1-100.
    return api.requestImageUrls(size, @[format], amount)


# Breeds:

proc requestBreeds*(api: TheCatApi): seq[CatBreed] =
    ## Requests sequence of all cat breeds from the api.
    let response: JsonNode = api.sendRequest(breedSearch)
    return getBreedsFromApiBreeds[ApiBreedCat, CatBreed](api, response)

proc requestBreeds*(api: TheDogApi): seq[DogBreed] =
    ## Requests sequence of all dog breeds from the api.
    let response: JsonNode = api.sendRequest(breedSearch)
    return getBreedsFromApiBreeds[ApiBreedDog, DogBreed](api, response)

