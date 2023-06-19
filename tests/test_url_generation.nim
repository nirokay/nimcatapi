import std/[unittest, options]
import nimcatapi/[client, typedefs, internal]


test "create api client":
    let
        apiCat: TheCatApi = newCatApiClient(token = "catto")
        apiDog: TheDogApi = newDogApiClient(token = "doggo")
    
    check apiCat.token.get() == "catto"
    check apiDog.token.get() == "doggo"


test "search single image":
    let
        apiCatNoToken: TheCatApi = newCatApiClient()
        apiCatToken: TheCatApi = newCatApiClient(token = "catto")
        emptyRequest: Request = Request()
    
    check apiCatNoToken.buildRequest(imageSearch, emptyRequest) == "https://api.thecatapi.com/v1/images/search"
    check apiCatToken.buildRequest(imageSearch, emptyRequest) == "https://api.thecatapi.com/v1/images/search?api_key=catto"


test "search multiple images":
    let
        apiCatNoToken: TheCatApi = newCatApiClient()
        apiCatToken: TheCatApi = newCatApiClient(token = "catto")


    check apiCatNoToken.buildRequest(imageSearch, Request( limit: some 10 )) == "https://api.thecatapi.com/v1/images/search?limit=10"
    check apiCatNoToken.buildRequest(imageSearch, Request( limit: some 5 ))  == "https://api.thecatapi.com/v1/images/search?limit=5"
    check apiCatToken.buildRequest(imageSearch, Request( limit: some 5 ))    == "https://api.thecatapi.com/v1/images/search?limit=5&api_key=catto"

    # Apparently without a token you can request either 1 or 10... so yeah, this is a test with 10:
    check apiCatNoToken.requestImageUrls(10).len() == 10




