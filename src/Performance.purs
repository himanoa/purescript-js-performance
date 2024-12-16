module Js.Performance 
  ( PerformanceEntry
  , PerformanceResourceTiming
  , EntryType(..)
  , now
  , mark
  , mark'
  , mark''
  , mark'''
  , measure
  , measure'
  , measure''
  , measure'''
  , measure''''
  , measure'''''
  , clearMarks
  , clearMark
  , clearMeasures
  , clearMeasure
  , clearResourceTimings
  , getEntries
  , getEntriesByName
  , getEntriesByType
  , setResourceTimingBufferSize
  ) where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Effect (Effect)
import Foreign.Object (Object)

-- | Performance Entry types
data EntryType = Mark | Measure | Resource | Navigation | Paint

derive instance Generic EntryType _
derive instance Eq EntryType
instance Show EntryType where
  show = genericShow

entryTypeToString :: EntryType -> String
entryTypeToString = case _ of
  Mark -> "mark"
  Measure -> "measure"
  Resource -> "resource"
  Navigation -> "navigation"
  Paint -> "paint"

-- | Performance Entry Record
type PerformanceEntry =
  { name :: String
  , entryType :: String
  , startTime :: Number
  , duration :: Number
  }

-- | Resource Timing Entry
type PerformanceResourceTiming =
  { name :: String
  , entryType :: String
  , startTime :: Number
  , duration :: Number
  , initiatorType :: String
  , nextHopProtocol :: String
  , workerStart :: Number
  , redirectStart :: Number
  , redirectEnd :: Number
  , fetchStart :: Number
  , domainLookupStart :: Number
  , domainLookupEnd :: Number
  , connectStart :: Number
  , connectEnd :: Number
  , secureConnectionStart :: Number
  , requestStart :: Number
  , responseStart :: Number
  , responseEnd :: Number
  , transferSize :: Number
  , encodedBodySize :: Number
  , decodedBodySize :: Number
  }

-- FFI
foreign import _now :: Effect Number
foreign import _clearMarks :: String -> Effect Unit
foreign import __clearMarks :: Effect Unit
foreign import _clearMeasures :: String -> Effect Unit
foreign import __clearMeasures :: Effect Unit
foreign import _clearResourceTimings :: Effect Unit
foreign import _getEntries :: Effect (Array PerformanceEntry)
foreign import _getEntriesByName :: String -> Effect (Array PerformanceEntry)
foreign import _getEntriesByType :: String -> Effect (Array PerformanceEntry)
foreign import _mark :: forall r. String -> { | r } -> Effect PerformanceEntry
foreign import _measure :: forall r. String -> { | r } -> Effect PerformanceEntry
foreign import _setResourceTimingBufferSize :: Int -> Effect Unit

now :: Effect Number
now = _now

mark :: String -> Effect PerformanceEntry
mark name = _mark name {}

mark' :: String -> { startTime :: Number } -> Effect PerformanceEntry
mark' name opts = _mark name opts

mark'' :: String -> { detail :: Object String } -> Effect PerformanceEntry
mark'' name opts = _mark name opts

mark''' :: String -> { detail :: Object String, startTime :: Number } -> Effect PerformanceEntry
mark''' name = _mark name

measure :: String -> Effect PerformanceEntry
measure name = _measure name {}

measure' :: String -> { start :: String, end :: String } -> Effect PerformanceEntry
measure' name opts = _measure name opts

measure'' :: String -> { start :: String, duration :: Number } -> Effect PerformanceEntry
measure'' name opts = _measure name opts

measure''' :: String -> { duration :: Number, end :: String } -> Effect PerformanceEntry
measure''' name opts = _measure name opts

measure'''' :: String -> { detail :: Object String, start :: String, end :: String } -> Effect PerformanceEntry
measure'''' name opts = _measure name opts

measure''''' :: String -> 
  { detail :: Object String
  , start :: String
  , duration :: Number
  , end :: String 
  } -> Effect PerformanceEntry
measure''''' name opts = _measure name opts

clearMarks :: Effect Unit
clearMarks = __clearMarks

clearMark :: String -> Effect Unit
clearMark = _clearMarks

clearMeasures :: Effect Unit
clearMeasures = __clearMeasures

clearMeasure :: String -> Effect Unit
clearMeasure = _clearMeasures

clearResourceTimings :: Effect Unit
clearResourceTimings = _clearResourceTimings

getEntries :: Effect (Array PerformanceEntry)
getEntries = _getEntries

getEntriesByName :: String -> Effect (Array PerformanceEntry)
getEntriesByName = _getEntriesByName

getEntriesByType :: EntryType -> Effect (Array PerformanceEntry)
getEntriesByType = _getEntriesByType <<< entryTypeToString

setResourceTimingBufferSize :: Int -> Effect Unit
setResourceTimingBufferSize = _setResourceTimingBufferSize
