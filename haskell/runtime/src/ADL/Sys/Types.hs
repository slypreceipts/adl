{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}
module ADL.Sys.Types(
    Either,
    Error,
    Map,
    MapEntry(..),
    Maybe,
    Pair,
    Result(..),
    Set,
    mkMapEntry,
) where

import ADL.Core
import Control.Applicative( (<$>), (<*>), (<|>) )
import Prelude( ($) )
import qualified Data.Aeson as JS
import qualified Data.HashMap.Strict as HM
import qualified Data.Map as Map
import qualified Data.Proxy
import qualified Data.Set as Set
import qualified Data.Text as T
import qualified Prelude


type Either = Prelude.Either


type Error a  = Prelude.Either T.Text a


type Map k v = Map.Map k v

data MapEntry k v = MapEntry
    { mapEntry_key :: k
    , mapEntry_value :: v
    }
    deriving (Prelude.Eq,Prelude.Ord,Prelude.Show)

mkMapEntry :: k -> v -> MapEntry k v
mkMapEntry key value = MapEntry key value

instance (AdlValue k, AdlValue v) => AdlValue (MapEntry k v) where
    atype _ = T.concat
        [ "sys.types.MapEntry"
        , "<", atype (Data.Proxy.Proxy :: Data.Proxy.Proxy k)
        , ",", atype (Data.Proxy.Proxy :: Data.Proxy.Proxy v)
        , ">" ]
    
    jsonGen = genObject
        [ genField "k" mapEntry_key
        , genField "v" mapEntry_value
        ]
    
    jsonParser = MapEntry
        <$> parseField "k"
        <*> parseField "v"


type Maybe = Prelude.Maybe


type Pair a b = (a,b)

data Result t e
    = Result_ok t
    | Result_error e
    deriving (Prelude.Eq,Prelude.Ord,Prelude.Show)

instance (AdlValue t, AdlValue e) => AdlValue (Result t e) where
    atype _ = T.concat
        [ "sys.types.Result"
        , "<", atype (Data.Proxy.Proxy :: Data.Proxy.Proxy t)
        , ",", atype (Data.Proxy.Proxy :: Data.Proxy.Proxy e)
        , ">" ]
    
    jsonGen = genUnion (\jv -> case jv of
        Result_ok v -> genUnionValue "ok" v
        Result_error v -> genUnionValue "error" v
        )
    
    jsonParser = parseUnion $ \disc -> case disc of
        "ok" ->  parseUnionValue Result_ok
        "error" ->  parseUnionValue Result_error
        _ -> parseFail "expected a discriminator for Result (ok,error)" 


type Set v = Set.Set v