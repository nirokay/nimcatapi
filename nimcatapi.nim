## Welcome to the nimcatapi documentation!
## 
## Getting Started
## ===============
## 
## Creating the API client:
## 
## .. code-block:: nim
##   import std/options
##   import nimcatapi
## 
##   let
##       cats*: AnimalApi = newCatApiClient(token = "meow")
##       dogs*: AnimalApi = newDogApiClient() # works without a token as well!
##   
## 
## This is how you request a single image from the API:
## 
## .. code-block:: nim
##   let singleImage*: string = cats.requestImageUrl()
## 
## It is also possible to request multiple images at once:
## 
## .. code-block:: nim
##   let multipleImages*: seq[string] = cats.requestImageUrls(10)
## 
## You can customize the image search patterns like this:
## 
## .. code-block:: nim
##   let customImages*: seq[string] = cats.requestImageUrls(
##       size = sizeFull,
##       formats = @[formatGif, formatJpg, formatPng],
##       amount = 5
##   )
##   
##   # Same but with Request object (used internally):
##   let customImagesWithObj*: seq[string] = cats.requestImageUrls(Request(
##       size: some sizeFull,
##       mime_types: some @[formatGif, formatJpg, formatPng],
##       limit: some 5
##   ))
## 
## **Note:**
## 
## Without a token, you may only request 1 *or* 10 images!
## 

{.define: ssl.}

import nimcatapi/[typedefs, client]
export typedefs, client
