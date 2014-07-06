{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}

import Data.Text
import Text.Blaze.Renderer.String (renderHtml)
import Text.Hamlet hiding (renderHtml)

data Url = Haskell | Yesod

renderUrl Haskell _ = pack "http://haskell.org"
renderUrl Yesod   _ = pack "http://www.yesodweb.com"

title = pack "This is in scope of the template below"

template :: Hamlet Url
template = [hamlet|
<html>
    <head>
        #{title}
    <body>
        <p>
            <a href=@{Haskell}>Haskell
            <a href=@{Yesod}>Yesod
|]

main = do
    let html = template renderUrl
    putStrLn $ renderHtml html
