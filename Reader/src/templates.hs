{-# LANGUAGE OverloadedStrings #-} -- we're using Text below
{-# LANGUAGE QuasiQuotes #-}
import Text.Hamlet (HtmlUrl, hamlet)
import Data.Text (Text)
import Text.Blaze.Html.Renderer.String (renderHtml)

data SPRoute = Javascript | Stylesheet


data Stanza = Stanza {
      fig :: String,
      title :: String,
      slines :: [ String ]
} deriving ( Eq, Ord, Show )

sample_s = Stanza {
             fig = "A1",
             title = "SAMPLE",
             slines = [ "Line 1", "Line 2", "Line 3" ]
           }


render :: SPRoute -> [(Text, Text)] -> Text
render Javascript _ = "sp.js"
render Stylesheet _ = "sp.css"

template :: [ Stanza ] -> HtmlUrl SPRoute
template stanzas = [hamlet|
$doctype 5
<html>
    <head>
        <title>Stepwise Palace
        <link rel=stylesheet href=@{Stylesheet}>
        <script type="text/javascript" src=@{Javascript}></script>
    <body>
        <h1>Stepwise Palace
        $forall Stanza fig title slines <- stanzas
            <div .stanza>
                <h2>Figure #{fig} #{title}
                <p .lines>
                    $forall line <- slines
                        <div .line>#{line}
|]

main :: IO ()
main = putStrLn $ renderHtml $ template [ sample_s, sample_s ] render



-- {-# LANGUAGE OverloadedStrings #-} -- we're using Text below
-- {-# LANGUAGE QuasiQuotes #-}

-- -- Render Stepwise Palace as static html


-- import Text.Hamlet (HtmlUrl, hamlet)
-- import Data.Text (Text)
-- import Text.Blaze.Html.Renderer.String (renderHtml)




-- data MyRoute = Stylesheet

-- render :: MyRoute -> [(Text, Text)] -> Text
-- render Stylesheet _ = "stepwise.css"

-- template :: [ Stanza ] -> HtmlUrl MyRoute
-- template stanzas = [hamlet|
-- $doctype 5
-- <html>
--     <head>
--         <title>The Stepwise Palace
--             <link rel=stylesheet href=@{Stylesheet}>
--     <body>
--         <h1>The Stepwise Palace
       
--         $forall Stanza fig title slines <- stanzas
--             <div .stanza>
--                 <h2>Figure #{fig} #{title}
--                 <p .lines>
--                     $forall line <- slines
--                         <div .line>#{line}
-- |]


