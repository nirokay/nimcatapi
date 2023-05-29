import std/options

type
    # API client:

    AnimalApiKind* = enum
        TheCatApi = "https://api.thecatapi.com/v1/search/images"
        TheDogApi = "https://api.thedogapi.com/v1/search/images"

    AnimalApi* = object
        kind*: AnimalApiKind
        token*: Option[string]


    # Request stuff:

    ImageSize* = enum
        sizeNone   = "",     # Internal value for signaling no specific selection
        sizeFull   = "full",
        sizeMed    = "med",
        sizeSmall  = "small"

    ImageFormat* = enum
        formatGif  = "gif",
        formatPng  = "png",
        formatJpg  = "jpg"

    Request* = object
        limit*: Option[int]
        size*: Option[ImageSize]
        mime_types*: Option[seq[ImageFormat]]

