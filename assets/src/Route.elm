module Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)
import Username exposing (Username)



-- ROUTING


type Route
    = Root
    | Profile
    | Logout


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Root Parser.top
        , Parser.map Profile (s "profile")
        , Parser.map Logout (s "logout")
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url



-- INTERNAL


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Profile ->
                    [ "profile" ]

                Root ->
                    []

                Logout ->
                    [ "logout" ]
    in
    "/" ++ String.join "/" pieces
