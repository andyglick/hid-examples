{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RecordWildCards #-}

module FilmInfo where

import Data.String
import Data.Int
import Data.Text (Text)
import Data.Text.IO as T
import TextShow

newtype FilmId = FilmId Int64
newtype CatId = CatId Int64
newtype FilmLength = FilmLength Int32

data Rating = G | PG | PG13 | R | NC17
  deriving Show

fromRating :: IsString p => Rating -> p
fromRating G = "G"
fromRating PG = "PG"
fromRating PG13 = "PG-13"
fromRating R = "R"
fromRating NC17 = "NC-17"

toMaybeRating :: (Eq p, IsString p) => p -> Maybe Rating
toMaybeRating "G" = Just G
toMaybeRating "PG" = Just PG
toMaybeRating "PG-13" = Just PG13
toMaybeRating "R" = Just R
toMaybeRating "NC-17" = Just NC17
toMaybeRating _ = Nothing

data FilmInfo = FilmInfo {
    filmId :: FilmId
  , title :: Text
  , description :: Maybe Text
  , filmLength :: FilmLength
  , rating :: Maybe Rating
  }

data FilmCategories = FilmCategories FilmInfo [Text]

data PrintDesc = WithDescription | NoDescription

instance TextShow FilmLength where
  showb (FilmLength l) = showb l <> " min"

instance TextShow FilmInfo where
  showb = filmBuilder NoDescription

filmBuilder :: PrintDesc -> FilmInfo -> Builder
filmBuilder printDescr FilmInfo {..} =
  fromText title <> " (" <> showb filmLength
  <> case rating of
       Just r -> ", " <> fromRating r <> ")"
       Nothing -> ")"
  <> case (printDescr, description) of
       (WithDescription, Just desc) -> "\n" <> fromText desc
       _ -> ""

printFilm :: FilmInfo -> IO ()
printFilm = T.putStrLn . toText . filmBuilder WithDescription

instance TextShow FilmCategories where
  showb (FilmCategories f cats) = showb f <> "\n" <> showbList cats
