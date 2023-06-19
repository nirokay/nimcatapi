import std/[unittest, options, strformat]
import nimcatapi

test "query thecatapi breeds":
    let
        client: TheCatApi = newCatApiClient()
        breeds: seq[CatBreed] = client.requestBreeds()

    check breeds.len() > 0
    echo &"Got {breeds.len()} cat breeds!"


test "query thedogapi breeds":
    let
        client: TheDogApi = newDogApiClient()
        breeds: seq[DogBreed] = client.requestBreeds()

    check breeds.len() > 0
    echo &"Got {breeds.len()} dog breeds!"

