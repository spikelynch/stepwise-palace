{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

import Data.Aeson
import Data.Text
import Control.Applicative
import Control.Monad
import qualified Data.ByteString.Lazy as B
import GHC.Generics
import qualified Data.Map as M

data Room = Room {
      name :: !Text
    , coords :: [ Int ]
} deriving (Show, Generic)

instance FromJSON Room
instance ToJSON Room

jsonFile :: FilePath
jsonFile = "coords.json"

getJSON :: IO B.ByteString
getJSON = B.readFile jsonFile


getCoords :: [ Room ] -> Text -> [ Int ]
getCoords rooms fig = case Prelude.filter (\x -> name x == fig) rooms of
                      [] -> []
                      r:rs -> coords r



main :: IO ()
main = do
  d <- (eitherDecode <$> getJSON) :: IO(Either String [Room])
  case d of
    Left err -> putStrLn err
    Right ps -> print (getCoords ps "NOOONE")





