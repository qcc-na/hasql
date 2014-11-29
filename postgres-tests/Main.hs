{-# OPTIONS_GHC -F -pgmF htfpp #-}
import BasePrelude
import MTLPrelude
import Test.Framework
import qualified Hasql as H
import qualified Hasql.Postgres as HP


main = 
  htfMain $ htf_thisModulesTests

test_wrongRowParserArity =
  flip assertThrowsIO (\case H.UnparsableRow _ -> True; _ -> False) $
  session $ do
    H.tx Nothing $ do
      H.unit [H.q|DROP TABLE IF EXISTS data|]
      H.unit [H.q|CREATE TABLE data (
                      field1    DECIMAL NOT NULL,
                      field2    BIGINT  NOT NULL,
                      PRIMARY KEY (field1)
                  )|]
      H.unit [H.q|INSERT INTO data (field1, field2) VALUES (0, 0)|]
    mrow :: Maybe (Double, Int64, String) <- 
      H.tx Nothing $  
        H.single $ [H.q|SELECT * FROM data|]
    return ()


session :: (forall s. H.Session HP.Postgres s IO r) -> IO r
session =
  H.session backendSettings poolSettings
  where
    backendSettings = HP.Postgres "localhost" 5432 "postgres" "" "postgres"
    poolSettings = fromJust $ H.sessionSettings 6 30