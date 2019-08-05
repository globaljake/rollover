module Web.Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Html
import Json.Decode exposing (Value)
import Url exposing (Url)
import Wallets.Session as Session exposing (Session)
import Web.Page as Page
import Web.Page.Blank as Blank
import Web.Page.Home as Home
import Web.Page.NotFound as NotFound
import Web.Page.WalletDetail as WalletDetail
import Web.Route as Route exposing (Route)


type Model
    = Redirect Session
    | NotFound Session
    | Home Home.Model
    | WalletDetail WalletDetail.Model


init : Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.fromViewer navKey))



-- VIEW


view : Model -> Document Msg
view model =
    let
        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        NotFound _ ->
            viewPage Page.Other (\_ -> Ignored) NotFound.view

        Redirect _ ->
            viewPage Page.Other (\_ -> Ignored) Blank.view

        Home subModel ->
            viewPage Page.Home HomeMsg (Home.view subModel)

        WalletDetail subModel ->
            viewPage Page.Home WalletDetailMsg (WalletDetail.view subModel)



-- UPDATE


type Msg
    = Ignored
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | HomeMsg Home.Msg
    | WalletDetailMsg WalletDetail.Msg


toSession : Model -> Session
toSession page =
    case page of
        NotFound session ->
            session

        Redirect session ->
            session

        Home subModel ->
            Home.toSession subModel

        WalletDetail subModel ->
            WalletDetail.toSession subModel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Navigation.load href
                    )

        ( Ignored, _ ) ->
            ( model
            , Cmd.none
            )

        ( HomeMsg subMsg, Home subModel ) ->
            Home.update subMsg subModel
                |> updateWith Home HomeMsg model

        ( WalletDetailMsg subMsg, WalletDetail subModel ) ->
            WalletDetail.update subMsg subModel
                |> updateWith WalletDetail WalletDetailMsg model

        ( _, _ ) ->
            ( model
            , Cmd.none
            )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Home ->
            Home.init session
                |> updateWith Home HomeMsg model

        Just (Route.WalletDetail id) ->
            WalletDetail.init session id
                |> updateWith WalletDetail WalletDetailMsg model



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Redirect session ->
            Sub.none

        NotFound session ->
            Sub.none

        Home subModel ->
            Home.subscriptions subModel
                |> Sub.map HomeMsg

        WalletDetail subModel ->
            WalletDetail.subscriptions subModel
                |> Sub.map WalletDetailMsg


main : Program Value Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }