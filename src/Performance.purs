module Js.Performance where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Foreign.Object as Foreign

-- | Performance Entry Types
data PerformanceEntryType
  = Mark
  | Measure
  | Resource
  | Navigation
  | Paint

-- | Performance Entry Record
type PerformanceEntry =
  { name :: String
  , entryType :: PerformanceEntryType
  , startTime :: Number
  , duration :: Number
  }

-- | Resource Timing Entry
type PerformanceResourceTiming =
  { name :: String
  , entryType :: PerformanceEntryType
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

-- | Performance Mark Options
type MarkOptions =
  { detail :: Maybe (Foreign.Object String)
  , startTime :: Maybe Number
  }

-- | Performance Measure Options
type MeasureOptions =
  { detail :: Maybe (Foreign.Object String)
  , start :: Maybe String
  , duration :: Maybe Number
  , end :: Maybe String
  }

foreign import _now :: Effect Number
foreign import _clearMarks :: String -> Effect Unit
foreign import _clearMeasures :: String -> Effect Unit
foreign import _clearResourceTimings :: Effect Unit
foreign import _getEntries :: Effect (Array PerformanceEntry)
foreign import _getEntriesByName :: String -> Effect (Array PerformanceEntry)
foreign import _getEntriesByType :: PerformanceEntryType -> Effect (Array PerformanceEntry)
foreign import _mark :: String -> MarkOptions -> Effect PerformanceEntry
foreign import _measure :: String -> MeasureOptions -> Effect PerformanceEntry
foreign import _setResourceTimingBufferSize :: Int -> Effect Unit

-- | Get current high resolution timestamp
now :: Effect Number
now = _now

-- | Clear performance marks
clearMarks :: Maybe String -> Effect Unit
clearMarks = case _ of
  Just name -> _clearMarks name
  Nothing -> _clearMarks ""

-- | Clear resource timing buffer
clearResourceTimings :: Effect Unit
clearResourceTimings = _clearResourceTimings

-- | Get all performance entries
getEntries :: Effect (Array PerformanceEntry)
getEntries = _getEntries

-- | Get performance entries by name
getEntriesByName :: String -> Effect (Array PerformanceEntry)
getEntriesByName = _getEntriesByName

-- | Get performance entries by type
getEntriesByType :: PerformanceEntryType -> Effect (Array PerformanceEntry)
getEntriesByType = _getEntriesByType

-- | Create a performance mark
mark :: String -> Maybe MarkOptions -> Effect PerformanceEntry
mark name opts = _mark name (case opts of
  Just { detail: d, startTime: st } -> 
    { detail: d
    , startTime: st 
    }
  Nothing -> {detail: Nothing, startTime: Nothing})

-- | Create a performance measure
measure :: String -> Maybe MeasureOptions -> Effect PerformanceEntry
measure name opts = _measure name (case opts of
  Just { detail: d, start: s, duration: dur, end: e } -> 
    { detail: d
    , start: s
    , duration: dur
    , end: e
    }
  Nothing -> {detail: Nothing, start: Nothing, duration: Nothing, end: Nothing})

-- | Set resource timing buffer size
setResourceTimingBufferSize :: Int -> Effect Unit
setResourceTimingBufferSize = _setResourceTimingBufferSize

-- | Clear performance measures
clearMeasures :: Maybe String -> Effect Unit
clearMeasures = case _ of 
  Just name -> _clearMeasures name
  Nothing -> _clearMeasures ""
