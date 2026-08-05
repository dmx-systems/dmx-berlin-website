module Site exposing (config)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import SiteConfig exposing (SiteConfig)



config : SiteConfig
config =
    { canonicalUrl = "https://dmx.berlin"
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    BackendTask.succeed
        [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1") ]
