module Hasql.Deserialization.Value where

import Hasql.Prelude
import qualified Database.PostgreSQL.LibPQ as LibPQ
import qualified PostgreSQL.Binary.Decoder as Decoder


newtype Value a =
  Value (ReaderT Bool Decoder.Decoder a)
  deriving (Functor)


{-# INLINE run #-}
run :: Value a -> Bool -> Decoder.Decoder a
run (Value imp) integerDatetimes =
  runReaderT imp integerDatetimes

{-# INLINE decoder #-}
decoder :: (Bool -> Decoder.Decoder a) -> Value a
decoder =
  {-# SCC "decoder" #-} 
  Value . ReaderT

