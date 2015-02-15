{-# LANGUAGE OverloadedStrings #-} -- For Data.Text literals
{-# LANGUAGE TemplateHaskell #-}       -- For Hamlet
{-# LANGUAGE DeriveGeneric #-}     -- For Generic interface to Aeson


-- Render Stepwise Palace as static html

import Data.Aeson
import Control.Applicative
import Control.Monad
import qualified Data.ByteString.Lazy as B
import GHC.Generics

import qualified Data.Map as M

import Text.Hamlet (HtmlUrl, hamletFile)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Text.Blaze.Html.Renderer.String (renderHtml)
import Text.Blaze.Html as BH

import Text.Regex.Posix ((=~))
import Data.List.Split
import Data.Maybe

import System.Directory (getDirectoryContents)

poemdir = "/Users/mike/Desktop/Personal/FSVO/stepwise-palace/Reader/Poem/"

-- Datatype to read the coords.json file using Data.Aeson and generics

data Room = Room {
      name :: !T.Text
    , coords :: [ Int ]
} deriving (Show, Generic)

-- Stanza datatype

-- the spacetime and elements records are lists of lists of figures to
-- be rendered into the two navigation controls on each stanza:


data Stanza = Stanza {
      fig :: T.Text
    , title :: T.Text
    , slines :: [ BH.Html ]
    , spacetime :: [ [ T.Text ] ]
    , elements :: [ [ T.Text ] ]
} 


instance FromJSON Room
instance ToJSON Room

jsonFile :: FilePath
jsonFile = "coords.json"

getJSON :: IO B.ByteString
getJSON = B.readFile jsonFile

-- figToCoords gets a room's coordinates based on its 'figure' code

figToCoords :: [ Room ] -> T.Text -> [ Int ]
figToCoords rooms fig = case Prelude.filter (\x -> name x == fig) rooms of
                      [] -> [] 
                      r:rs -> coords r


-- coordsTofig is the inverse: gets a figure based on its coordinates

coordsToFig :: [ Room ] -> [ Int ] -> T.Text
coordsToFig rooms cs = case Prelude.filter (\x -> coords x == cs) rooms of
                     [] -> ""
                     r:rs -> name r


-- addCoords stitches the room coordinates into the spacetime and elements
-- fields of a Stanza

addCoords :: [ Room ] -> Stanza -> Stanza
addCoords rooms stanza = stanza { spacetime = st, elements = el }
    where st = spacetimeNeighbours rooms figure 
          el = elementsNeighbours rooms figure
          figure = fig stanza

spacetimeNeighbours :: [ Room ] -> T.Text -> [ [ T.Text ] ]
spacetimeNeighbours rooms fig = heights
    where x = coords !! 0
          y = coords !! 1
          coords = figToCoords rooms fig
          heights = [ times z | z <- [ 1, 0, -1 ] ]
          times z = [ coordsToFig rooms [ x, y, z, t ] | t <- [ -1, 0, 1 ] ]


elementsNeighbours :: [ Room ] -> T.Text -> [ [ T.Text ] ]
elementsNeighbours rooms fig = ys
    where z = coords !! 2
          t = coords !! 3
          coords = figToCoords rooms fig
          ys = [ xs y | y <- [ 1, 0, -1 ] ]
          xs y = [ coordsToFig rooms [ x, y, z, t ] | x <- [ -1, 0, 1 ] ]

-- typed-URL renderer for Hamlet

data SPRoute = Javascript | Stylesheet


render :: SPRoute -> [(T.Text, T.Text)] -> T.Text
render Javascript _ = "stepwise.js"
render Stylesheet _ = "stepwise.css"

-- template for a list of Stanzas -> HTML

-- The coordinates of each room are rendered as a pair of 3-by-3 grids.
-- One grid is the elements axes (N = Fire, W = Air, S = Water, E = Stone)
-- The other grid is the time and depth/scale axis (time is X, depth is Y)

-- The coordinates are read from a json file where each room's location
-- is :

-- [ X Y Z T ]

--      X     Y      Z        T
-- -1   West  South  Deep     Past
--  0                Surface  Present
--  1   East  North  Sky      Future


template :: [ Room ] -> [ Stanza ] -> HtmlUrl SPRoute
template rooms stanzas = $(hamletFile "template.hamlet")


-- code to parse the text files and create a list of Stanzas to feed
-- to the Hamlet template

headerRE :: String
headerRE = "^Figure"

splitOnHeaders :: [ T.Text ] -> [ [ T.Text ] ]
splitOnHeaders = splitter reHeader
    where splitter = split . keepDelimsL . whenElt
          reHeader = (\x -> (T.unpack x) =~ headerRE)




toStanza :: [ T.Text ] -> Maybe Stanza
toStanza (header:ls) = case parseTitle header of
                         Just ( fig, title ) -> Just Stanza {
                                             fig = fig,
                                             title = title,
                                             slines = stanzaLines ls,
                                             spacetime = [],
                                             elements = []
                                           }
                         Nothing -> Nothing
toStanza _           = Nothing



stanzaLines ls = map preEscapedToHtml $ filter (not . T.null) ls

titleRE :: String
titleRE = "Figure ([A-Z][0-9]+): ([A-Z]+)"

parseTitle :: T.Text -> Maybe ( T.Text, T.Text )
parseTitle t = case ms of
                 [] -> Nothing
                 otherwise -> Just ( T.pack ((head ms) !! 1), T.pack ((head ms) !! 2))
    where ms = ((T.unpack t) =~ titleRE) :: [[ String ]]




poemfileRE :: String
poemfileRE = "^SP[A-Z].*\\.txt"

spfile :: String -> Bool
spfile f = (f =~ poemfileRE)



parseFile :: String -> IO [ Stanza ]
parseFile file = do
  text <- TIO.readFile (poemdir ++ file)
  return ( catMaybes $ (map toStanza (splitOnHeaders $ T.lines text)))



main :: IO ()
main = do
   dircontents <- getDirectoryContents poemdir
   poemfiles <- return $ filter spfile dircontents
   jsonrms <- (eitherDecode <$> getJSON) :: IO (Either String [Room])
   stanzas <- mapM parseFile poemfiles
   rooms <- case jsonrms of
     Left error -> fail ("Error parsing rooms" ++ error)
     Right rs -> return rs
   rstanzas <- return $ map (addCoords rooms) (concat stanzas)
   putStrLn $ renderHtml $ template rooms rstanzas render

-- (show stanzas)
