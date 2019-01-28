module Page exposing (Page(..), view)

import Api exposing (Cred)
import Avatar
import Browser exposing (Document)
import Constants
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Route exposing (Route)
import Session exposing (Session)
import Ui.IconInjector as IconInjector
import Username exposing (Username)
import Viewer exposing (Viewer)


type Page
    = Other
    | Home
    | Login
    | Register


view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Rollover"
    , body =
        [ IconInjector.view
        , Html.div
            [ Attributes.class "h-full flex justify-center overflow-y-auto scrolling-touch"
            , Attributes.style "background" "#46c141"
            ]
            [ Html.div [ Attributes.class "max-w-xs w-full sm:flex hidden flex-col items-center" ]
                [ Html.img
                    [ Attributes.src (Constants.toAsset "images/rollover-logo.svg")
                    , Attributes.class "my-8 w-2/3"
                    ]
                    []
                , Html.div [ Attributes.class "relative w-full justify-center" ]
                    [ Html.div
                        [ Attributes.class "px-6 pt-12"
                        , Attributes.style "transform" "scale(.8)"
                        , Attributes.style "transform-origin" "top"
                        ]
                        [ content ]
                    , Html.div [ Attributes.class "absolute pin pointer-events-none" ]
                        [ Html.img
                            [ Attributes.src (Constants.toAsset "images/iphone.svg")
                            , Attributes.class "w-full"
                            ]
                            []
                        ]
                    ]
                ]
            , Html.div [ Attributes.class "w-full h-full sm:hidden px-6 pt-6" ] [ content ]
            ]
        ]
    }