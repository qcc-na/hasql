module Hasql.InteractUnauthenticated where

import Hasql.Prelude
import Hasql.Model
import qualified Hasql.Request as A


newtype Interact result =
  Interact (F A.Request result)
  deriving (Functor, Applicative, Monad)

{-# INLINE request #-}
request :: A.Request result -> Interact result
request = Interact . liftF

{-# INLINE startUp #-}
startUp :: ByteString -> Maybe ByteString -> [(ByteString, ByteString)] -> Interact AuthenticationResult
startUp username databaseMaybe runtimeParameters =
  request (A.startUp username databaseMaybe runtimeParameters)

{-# INLINE clearTextPassword #-}
clearTextPassword :: ByteString -> Interact AuthenticationResult
clearTextPassword password =
  request (A.clearTextPassword password)

{-# INLINE md5Password #-}
md5Password :: ByteString -> ByteString -> ByteString -> Interact AuthenticationResult
md5Password username password salt =
  request (A.md5Password username password salt)

{-# INLINE handshake #-}
handshake :: ByteString -> ByteString -> Maybe ByteString -> [(ByteString, ByteString)] -> Interact (Either Text Bool)
handshake username password databaseMaybe runtimeParameters =
  startUp username databaseMaybe runtimeParameters >>= handleFirstAuthenticationResult
  where
    handleFirstAuthenticationResult =
      \case
        OkAuthenticationResult idt -> return (Right idt)
        NeedClearTextPasswordAuthenticationResult -> clearTextPassword password >>= handleSecondAuthenticationResult
        NeedMD5PasswordAuthenticationResult salt -> md5Password username password salt >>= handleSecondAuthenticationResult
    handleSecondAuthenticationResult =
      \case
        OkAuthenticationResult idt -> return (Right idt)
        _ -> return (Left "Can't authenticate")
