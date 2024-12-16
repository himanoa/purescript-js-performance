module Test.Main where

import Prelude

import Data.Array (length)
import Data.Foldable (all)
import Effect (Effect)
import Effect.Class (liftEffect)
import Js.Performance as P
import Test.Spec (Spec, describe, it, sequential)
import Test.Spec.Assertions (shouldSatisfy)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)

cleanup :: Effect Unit
cleanup = do
  P.clearMarks
  P.clearMeasures

spec :: Spec Unit
spec = do
  describe "Performance API" $ sequential do
    describe "now" $ sequential do
      it "should be monotonically increasing" do
        liftEffect cleanup
        t1 <- liftEffect P.now
        t2 <- liftEffect P.now
        t2 `shouldSatisfy` (_ >= t1)

    describe "mark" $ sequential do
      it "creates single mark when called once" do
        liftEffect cleanup
        let name = "test-mark"
        _ <- liftEffect $ P.mark name
        entries <- liftEffect $ P.getEntriesByName name
        entries `shouldSatisfy` \es -> length es == 1 && 
                                     all (\e -> e.name == name) es
                                     
      it "startTime equals to performance.now when no options" do
        liftEffect cleanup
        now <- liftEffect P.now
        entry <- liftEffect $ P.mark "test-mark"
        entry.startTime `shouldSatisfy` (_ >= now)

      it "startTime respects provided value" do
        liftEffect cleanup
        let time = 1234.0
            name = "test-mark-with-time"
        entry <- liftEffect $ P.mark' name { startTime: time }
        entry.startTime `shouldSatisfy` (_ == time)

      it "clearMark removes specific mark" do
        liftEffect cleanup
        let name1 = "mark-1"
            name2 = "mark-2"
        _ <- liftEffect $ P.mark name1
        _ <- liftEffect $ P.mark name2
        _ <- liftEffect $ P.clearMark name1
        entries <- liftEffect $ P.getEntriesByName name1
        entries `shouldSatisfy` \es -> length es == 0
        entries2 <- liftEffect $ P.getEntriesByName name2
        entries2 `shouldSatisfy` \es -> length es == 1

      it "clearMarks removes all marks" do
        liftEffect cleanup
        let name1 = "mark-1"
            name2 = "mark-2"
        _ <- liftEffect $ P.mark name1
        _ <- liftEffect $ P.mark name2
        _ <- liftEffect P.clearMarks
        entries1 <- liftEffect $ P.getEntriesByName name1
        entries2 <- liftEffect $ P.getEntriesByName name2
        (length entries1 + length entries2) `shouldSatisfy` (_ == 0)

    describe "measure" $ sequential do
      it "creates measure between marks" do
        liftEffect cleanup
        let startName = "start-mark"
            endName = "end-mark"
            measureName = "test-measure"
        _ <- liftEffect $ P.mark startName
        _ <- liftEffect $ P.mark endName
        void $ liftEffect $ P.measure' measureName
          { start: startName
          , end: endName
          }
        entries <- liftEffect $ P.getEntriesByName measureName
        entries `shouldSatisfy` \es -> 
          length es == 1 &&
          all (\e -> e.name == measureName && e.duration >= 0.0) es

      it "respects duration when provided" do
        liftEffect cleanup
        let duration = 1000.0
            name = "test-measure-duration"
            startName = "start-mark"
        _ <- liftEffect $ P.mark startName
        void $ liftEffect $ P.measure'' name
          { start: startName
          , duration: duration
          }
        entries <- liftEffect $ P.getEntriesByName name
        entries `shouldSatisfy` \es ->
          length es == 1 &&
          all (\e -> e.duration == duration) es

      it "clearMeasure removes specific measure" do
        liftEffect cleanup
        let name1 = "measure-1"
            name2 = "measure-2"
        _ <- liftEffect $ P.measure name1
        _ <- liftEffect $ P.measure name2
        _ <- liftEffect $ P.clearMeasure name1
        entries1 <- liftEffect $ P.getEntriesByName name1
        entries2 <- liftEffect $ P.getEntriesByName name2
        entries1 `shouldSatisfy` \es -> length es == 0
        entries2 `shouldSatisfy` \es -> length es == 1

      it "clearMeasures removes all measures" do
        liftEffect cleanup
        let name1 = "measure-1"
            name2 = "measure-2"
        _ <- liftEffect $ P.measure name1
        _ <- liftEffect $ P.measure name2
        _ <- liftEffect P.clearMeasures
        entries1 <- liftEffect $ P.getEntriesByName name1
        entries2 <- liftEffect $ P.getEntriesByName name2
        (length entries1 + length entries2) `shouldSatisfy` (_ == 0)

    describe "getEntries" $ sequential do
      it "getEntriesByName returns all matching entries" do
        liftEffect cleanup
        let name = "same-name"
        _ <- liftEffect $ P.mark name
        _ <- liftEffect $ P.mark name
        entries <- liftEffect $ P.getEntriesByName name
        entries `shouldSatisfy` \es -> 
          length es == 2 &&
          all (\e -> e.name == name) es

      it "getEntriesByName correctly handles marks and measures" do
        liftEffect cleanup
        let markName = "test-entry"
            measureName = "test-entry"
        _ <- liftEffect $ P.mark markName
        _ <- liftEffect $ P.measure measureName
        entries <- liftEffect $ P.getEntriesByName markName
        entries `shouldSatisfy` \es -> length es == 2

main :: Effect Unit
main = runSpecAndExitProcess [consoleReporter] spec
