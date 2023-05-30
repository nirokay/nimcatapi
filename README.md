# nimcatapi

## About

**nimcatapi** is a library that lets you easily request images from [thecatapi](https://thecatapi.com/) and/or [thedogapi](https://thedogapi.com/).

## Installation

`nimble install nimcatapi`

To use it in your projects, include `requires "nimcatapi"` in your `.nimble` file and import it!

## Usage

```nim
import std/options
import nimcatapi

# Both APIs work the same way and share a single object:
let
    cats*: AnimalApi = newCatApiClient(token = "meow")
    dogs*: AnimalApi = newDogApiClient() # works without a token as well!

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
