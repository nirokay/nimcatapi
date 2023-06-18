import std/[strutils, options]

type
    # API client:

    AnimalApiKind* = enum
        TheCatApi = "https://api.thecatapi.com/v1/images/search"
        TheDogApi = "https://api.thedogapi.com/v1/images/search"

    AnimalApi* = object
        kind*: AnimalApiKind
        token*: Option[string]


    # Request stuff:

    ImageSize* = enum
        sizeNone   = "", ## sizeNone is an internal value for signaling no specific selection, do not use manually
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
        has_breeds*: Option[bool]


    # Breed stuff:

    ReferenceImage* = tuple
        id, url: string
        width, height: Option[int]

    ImperialMetricValues* = tuple
        imperial, metric: string

    ApiBreed* = object of RootObj
        id*, name*, description*, life_span*: string
        weight*: Option[ImperialMetricValues]
        temperament*: string
        ## General Information

        origin*: string
        country_code*: Option[string]
        ## Origin country (countries for thedogapi)

    ApiBreedCat* = object of ApiBreed
        cfa_url*, vetstreet_url*, vcahospitals_url*, wikipedia_url*: Option[string]

        country_codes: string
        ## Only for parsing, not meant to be accessable.

        affection_level*, adaptability*, cat_friendly*, child_friendly*, dog_friendly*,
            energy_level*, grooming*, health_issues*, intelligence*, shedding_level*,
            social_needs*, stranger_friendly*, vocalisation*: Option[range[0..5]]
        ## 5-star ratings

        natural*, hypoallergenic*, suppressed_tail*, experimental*,
            hairless*, short_legs*, rex*, rare*: Option[range[0..1]]
        ## Booleans as numbers, because that makes sense

        indoor*, lap*, bidability*: Option[int]
        ## My best guess is, these are also booleans (they are never used by the api)
    
    ApiBreedDog* = object of ApiBreed
        height*: Option[ImperialMetricValues]
        bred_for*, breed_group*: string

        reference_image_id*: Option[string]
        image*: Option[ReferenceImage]
        ## Reference Image

    Breed* = object of RootObj
        id*, name*, lifeSpan*: string
        description*: Option[string]
        temperament*: Option[seq[string]]
        weight*: Option[ImperialMetricValues]

    CatBreed* = object of Breed
        informationUrls*: Option[seq[string]]
        ## Links to websites with information about breed

        originCountry*: tuple[name, code: string]

        rating*: tuple[affectionLevel, adaptability, catFriendly, childFriendly,
            dogFriendly, energyLevel, grooming, healthIssues, intelligence, sheddingLevel,
            socialNeeds, strangerFriendly, vocalisation: Option[float]
        ]
        ## Percentage ratings
        
        attributes*: tuple[natural, hypoallergenic, suppressedTail, experimental,
            hairless, shortLegs, rex, rare,
            
            # Who knows if these are also booleans aahhhhhhh:
            indoor, lap, bidability: Option[bool]
        ]
        ## Breed attributes
    
    DogBreed* = object of Breed
        height*: Option[ImperialMetricValues]
        referenceImage*: Option[ReferenceImage]
        group*, purpose*: Option[string]

        originCountries*: seq[string]

    Response* = object
        id*, url*: string
        width*, height*: Option[int]
        breeds*: Option[seq[Breed]]



# -----------------------------------------------------------------------------
# Object procs:
# -----------------------------------------------------------------------------

proc convert*(apiBreed: ApiBreedCat): CatBreed =
    ## Converts breed information from the api into easy to use object with some QoL conversions
    ## like for example `range[0..1]` converted to `bool`!
    let a = apiBreed
    result = CatBreed(
        weight: a.weight,
        id: a.id,
        name: a.name,
        description: some a.description,
        lifeSpan: a.life_span,
        originCountry: (name: a.origin, code: a.country_code.get())
    )

    # Add temprament as sequence:
    var temperament: seq[string]
    for temp in a.temperament.split(','):
        temperament.add(temp.strip())
    if temperament.len() != 0: result.temperament = some temperament

    # Add all available urls:
    var urls: seq[string]
    for url in [a.cfa_url, a.vetstreet_url, a.wikipedia_url, a.vcahospitals_url]:
        if url.isSome(): urls.add(url.get())
    if urls.len() != 0: result.informationUrls = some urls

    # Add ratings and attributes:
    proc toPercentage(i: Option[range[0..5]]): Option[float] =
        ## Returns percentage value for `range[0..5]`
        if i.isNone(): return none float
        return some i.get().toFloat() / 5

    result.rating = (
        affectionLevel: a.affection_level.toPercentage(),
        adaptability: a.adaptability.toPercentage(),
        catFriendly: a.cat_friendly.toPercentage(),
        childFriendly: a.child_friendly.toPercentage(),
        dogFriendly: a.dog_friendly.toPercentage(),
        energyLevel: a.energy_level.toPercentage(),
        grooming: a.grooming.toPercentage(),
        healthIssues: a.health_issues.toPercentage(),
        intelligence: a.intelligence.toPercentage(),
        sheddingLevel: a.shedding_level.toPercentage(),
        socialNeeds: a.social_needs.toPercentage(),
        strangerFriendly: a.stranger_friendly.toPercentage(),
        vocalisation: a.vocalisation.toPercentage()
    )

    proc toBool(i: Option[int] | Option[range[0..1]]): Option[bool] =
        ## Returns `true` if not 0
        if i.isNone(): return none bool
        if i.get() == 0: return some false
        else: return some true

    result.attributes = (
        natural: a.natural.toBool(),
        hypoallergenic: a.hypoallergenic.toBool(),
        suppressedTail: a.suppressed_tail.toBool(),
        experimental: a.experimental.toBool(),
        hairless: a.hairless.toBool(),
        shortLegs: a.short_legs.toBool(),
        rex: a.rex.toBool(),
        rare: a.rare.toBool(),

        # Who knows, are these booleans?
        indoor: a.indoor.toBool(),
        lap: a.lap.toBool(),
        bidability: a.bidability.toBool()
    )

proc convert*(apiBreed: seq[ApiBreedCat]): seq[CatBreed] =
    ## Converts breed information from the api into easy to use object with some QoL conversions
    ## like for example `range[0..1]` converted to `bool`!
    for breed in apiBreed:
        result.add(breed.convert())
