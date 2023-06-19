# nimcatapi

## About

**nimcatapi** is a library that lets you easily request images from [thecatapi](https://thecatapi.com/) and/or [thedogapi](https://thedogapi.com/).

## Installation

`nimble install nimcatapi`

To use it in your projects, include `requires "nimcatapi"` in your `.nimble` file and import it!

## Usage

Most of the functionality works without a token. If you however would like to request a specific amount of images (except just one or ten), you will need to request an API token: [thecatapi](https://thecatapi.com/#pricing) / [thedogapi](https://thedogapi.com/#pricing)

### Requesting images

You can easily request one or multiple random images.

```nim
import std/options
import nimcatapi

# Both APIs work the same way:
let
    cats*: TheCatApi = newCatApiClient(token = "meow")
    dogs*: TheDogApi = newDogApiClient() # works without a token as well!

# A single image:
let singleImage*: string = cats.requestImageUrl()

# Multiple images (without token you can only request 1 or 10 images, with a token 1-100):
let multipleImages*: seq[string] = cats.requestImageUrls(10)

# Customise search patterns:
let customImages*: seq[string] = cats.requestImageUrls(
    size = sizeFull,
    formats = @[formatGif, formatJpg, formatPng],
    amount = 5
)

# Same but with Request object (used internally):
let customImagesWithObj*: seq[string] = cats.requestImageUrls(Request(
    size: some sizeFull,
    mime_types: some @[formatGif, formatJpg, formatPng],
    limit: some 5
))
```

### Requesting breeds

Requesting breeds functions the same across both APIs, however you will get differently structured responses.

```nim
import nimcatapi

let
    dogs: TheDogApi = newDogApiClient()
    breeds: seq[DogBreed] = dogs.requestBreeds()
echo "Got " & breeds.len() & " dog breeds!"
```

For proper documentation about `DogBreed` and `CatBreed` objects, please visit [the docs](https://nirokay.github.io/nim-docs/nimcatapi/nimcatapi/typedefs.html#Breed)!

## Documentation

For detiled documentation, please visit [the nim generated docs page](https://nirokay.github.io/nim-docs/nimcatapi/nimcatapi)!
