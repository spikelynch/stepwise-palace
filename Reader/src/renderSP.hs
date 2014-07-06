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

instance FromJSON Room
instance ToJSON Room

jsonFile :: FilePath
jsonFile = "coords.json"

getJSON :: IO B.ByteString
getJSON = B.readFile jsonFile

-- getCoords gets a room based on its 'figure' code

getCoords :: [ Room ] -> T.Text -> [ Int ]
getCoords rooms fig = case Prelude.filter (\x -> name x == fig) rooms of
                      [] -> [] 
                      r:rs -> coords r


-- getCoords looks up a room by its coordinates and returns the
-- figure.  This is used to populate the links in the squares (to rooms
-- in the same two slices)

getRoom :: [ Room ] -> [ Int ] -> T.Text
getRoom rooms cs = case Prelude.filter (\x -> coords x == cs) rooms of
                     [] -> ""
                     r:rs -> name r

-- Stanza datatype

data Stanza = Stanza {
      fig :: T.Text
    , title :: T.Text
    , slines :: [ T.Text ]
    , scoords :: [ Int ]

} deriving ( Eq, Ord, Show )

-- typed-URL renderer for Hamlet

data SPRoute = Javascript | Stylesheet


render :: SPRoute -> [(T.Text, T.Text)] -> T.Text
render Javascript _ = "stepwise.js"
render Stylesheet _ = "stepwise.css"

-- template for a list of Stanzas -> HTML

-- plus helper functions for the coordinates

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

-- allcoords: a list of all ( x, y) coordinate pairs.  The template
-- uses this as the loop to render both grids.

allcoords :: [ ( Int, Int ) ]
allcoords = [ (x, y) | x <- [ -1, 0, 1 ], y <- [ 1, 0, -1 ] ]


c2s = 40


c2size = show c2s

c2offset = 4 * c2s

height = show (3 * c2s)
width = show (7 * c2s)

-- two sets of c2class, c2svgx and c2svgy functions: Time/Deep and Elements

-- c2classTimeDeep = c2class 3 2
-- c2classElements = c2class 0 1

-- c2class :: Int -> Int ->  [ Int ] -> Int -> Int -> T.Text
-- c2class ox oy coords x y = case (cx == x && cy == y) of
--                               True -> "on"
--                               False -> "off" 
--    where cx = coords !! ox
--          cy = coords !! oy

-- c2cell is a new version of c2class which returns the Fig to 
-- link to from each non-selected stanza


c2classTime :: [ Int ] -> Int -> Int -> T.Text
c2classTime coords x y = c2class coords x y 3 2


c2classElements :: [ Int ] -> Int -> Int -> T.Text
c2classElements coords x y = c2class  coords x y 0 1


c2class :: [ Int ] -> Int -> Int -> Int -> Int -> T.Text
c2class coords x y ox oy = case (cx == x && cy == y) of
                                 True -> "on"
                                 False -> "off"
    where cx = coords !! ox
          cy = coords !! oy


-- Note for getRoom lookup: [ AirEarth FireWater Depth Time ]
  
c2clickTime :: [ Room ] -> [ Int ] -> Int -> Int -> T.Text
c2clickTime rms coords x y = case (time == x && depth == y) of
                               True -> ""
                               False -> getRoom rms [ airearth, firewater, y, x ]
    where airearth = coords !! 0
          firewater = coords !! 1 
          time = coords !! 3
          depth = coords !! 2


c2clickElements :: [ Room ] -> [ Int ] -> Int -> Int -> T.Text
c2clickElements rms coords x y = case (airearth == x && firewater == y) of
                               True -> ""
                               False -> getRoom rms [ x, y, depth, time ]
    where airearth = coords !! 0
          firewater = coords !! 1 
          time = coords !! 3
          depth = coords !! 2

-- base coordinate functions

c2svgTime x0 x = show (x0 + c2s * (1 + x))
c2svgDeep y0 y = show (y0 + c2s * (1 - y))

c2svgAirEarth x0 x = show (x0 + c2offset + c2s * (1 + x))
c2svgFireWater y0 y = show (y0 + c2s * (1 - y))

-- The ones used with boxes

c2svgTBox = c2svgTime 0
c2svgDBox = c2svgDeep 0
c2svgAEBox = c2svgAirEarth 0
c2svgFWBox = c2svgFireWater 0

-- The ones used with labels

xlaboff = 10
ylaboff = 25

c2svgTLab = c2svgTime xlaboff
c2svgDLab = c2svgDeep ylaboff
c2svgAELab = c2svgAirEarth xlaboff
c2svgFWLab = c2svgFireWater ylaboff


template :: [ Room ] -> [ Stanza ] -> HtmlUrl SPRoute
template rooms stanzas = $(hamletFile "spReader.hamlet")


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
                                             slines = filter (not . T.null) ls,
                                             scoords = []
                                           }
                         Nothing -> Nothing
toStanza _           = Nothing



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


-- addCoords stitches the room coordinates into scoords of each Stanza

addCoords :: [ Room ] -> [ Stanza ] -> [ Stanza ]
addCoords rs ss = map addroom ss
    where addroom stanza = stanza { scoords = getCoords rs (fig stanza) }

main :: IO ()
main = do
   dircontents <- getDirectoryContents poemdir
   poemfiles <- return (filter spfile dircontents)
   jsonrms <- (eitherDecode <$> getJSON) :: IO(Either String [Room])
   stanzas <- mapM parseFile poemfiles
   rooms <- case jsonrms of
     Left error -> fail ("Error parsing rooms" ++ error)
     Right rs -> return (rs)
   rstanzas <- return (addCoords rooms (concat stanzas))
   putStrLn $ renderHtml $ template rooms rstanzas render

-- (show stanzas)
