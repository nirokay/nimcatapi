# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import std/[unittest, options]
import nimcatapi


test "create api client":
    let
        apiCat: AnimalApi = newCatApiClient(token = "catto")
        apiDog: AnimalApi = newDogApiClient(token = "doggo")
    
    check apiCat.token.get() == "catto"
    check apiDog.token.get() == "doggo"

test "search single image":
    let
        apiCatNoToken: AnimalApi = newCatApiClient()
        apiCatToken: AnimalApi = newCatApiClient(token = "catto")
        emptyRequest: Request = Request()
    
    check apiCatNoToken.buildRequest(emptyRequest) == "https://api.thecatapi.com/v1/images/search"
    check apiCatToken.buildRequest(emptyRequest) == "https://api.thecatapi.com/v1/images/search?api_key=catto"

test "search multiple images":
    let
        apiCatNoToken: AnimalApi = newCatApiClient()
        apiCatToken: AnimalApi = newCatApiClient(token = "catto")


    check apiCatNoToken.buildRequest(Request( limit: some 10 )) == "https://api.thecatapi.com/v1/images/search?limit=10"
    check apiCatNoToken.buildRequest(Request( limit: some 5 ))  == "https://api.thecatapi.com/v1/images/search?limit=5"
    check apiCatToken.buildRequest(Request( limit: some 5 ))    == "https://api.thecatapi.com/v1/images/search?limit=5&api_key=catto"

    # Apparently without a token you can request either 1 or 10... so yeah, this is a test with 10:
    check apiCatNoToken.requestImageUrls(10).len() == 10




