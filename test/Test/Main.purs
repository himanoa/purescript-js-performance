module Test.Main where

import Prelude

import Data.Array (length, sort)
import Data.Foldable (all)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Js.Performance as P
import Test.Spec (Spec, describe, it, itOnly)
import Test.Spec.Assertions (shouldSatisfy)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)

spec :: Spec Unit
spec = do
  describe "Performance API" do
    describe "now" do
      it "should be monotonically increasing" do
        t1 <- liftEffect P.now
        t2 <- liftEffect P.now
        t2 `shouldSatisfy` (_ >= t1)

      it "should return positive values" do
        t <- liftEffect P.now
        t `shouldSatisfy` (_ >= 0.0)

    describe "marks" do
      itOnly "should create a mark" do
        _ <- liftEffect $ P.mark "test-mark" Nothing
        entries <- liftEffect $ P.getEntriesByName "test-mark"
        entries `shouldSatisfy` \es -> 
          length es == 1 && 
          map _.name es == ["test-mark"] &&
          map _.entryType es == ["test-mark"]

      it "mark order should be preserved" do
        _ <- liftEffect $ P.mark "test-mark-1" Nothing
        _ <- liftEffect $ P.mark "test-mark-2" Nothing
        entries <- liftEffect $ P.getEntries
        let names = map _.name entries
        names `shouldSatisfy` \ns -> sort ns == ns

      it "clearMarks should remove all marks when called with Nothing" do
        _ <- liftEffect $ P.mark "test-mark" Nothing
        _ <- liftEffect $ P.clearMarks Nothing
        entries <- liftEffect $ P.getEntriesByType "mark"
        length entries `shouldSatisfy` (_ == 0)

      it "clearMarks should only remove specified mark" do
        _ <- liftEffect $ P.mark "test-mark-1" Nothing
        _ <- liftEffect $ P.mark "test-mark-2" Nothing
        _ <- liftEffect $ P.clearMarks (Just "test-mark-1")
        entries <- liftEffect $ P.getEntriesByType "mark"
        entries `shouldSatisfy` \es -> 
          length es == 1 && 
          map _.name es == ["test-mark-2"]

    describe "measures" do
      it "should create a measure" do
        _ <- liftEffect $ P.mark "start-mark" Nothing
        _ <- liftEffect $ P.mark "end-mark" Nothing
        let opts = 
              { detail: Nothing
              , start: Just "start-mark"
              , duration: Nothing
              , end: Just "end-mark"
              }
        entry <- liftEffect $ P.measure "test-measure" (Just opts)
        entry `shouldSatisfy` \e ->
          e.name == "test-measure" &&
          e.duration >= 0.0

      it "should clear specific measure" do
        _ <- liftEffect $ P.measure "test-measure-1" Nothing
        _ <- liftEffect $ P.measure "test-measure-2" Nothing
        _ <- liftEffect $ P.clearMeasures (Just "test-measure-1")
        entries <- liftEffect $ P.getEntriesByType "measure"
        entries `shouldSatisfy` \es ->
          length es == 1 &&
          map _.name es == ["test-measure-2"]

      it "should clear all measures" do
        _ <- liftEffect $ P.measure "test-measure-1" Nothing
        _ <- liftEffect $ P.measure "test-measure-2" Nothing
        _ <- liftEffect $ P.clearMeasures Nothing
        entries <- liftEffect $ P.getEntriesByType "measure"
        length entries `shouldSatisfy` (_ == 0)

    describe "resource timing" do
      it "should clear resource timings" do
        _ <- liftEffect P.clearResourceTimings
        entries <- liftEffect $ P.getEntriesByType "resource"
        length entries `shouldSatisfy` (_ == 0)

    describe "entries" do
      it "getEntries should return all entries" do
        _ <- liftEffect $ P.clearMarks Nothing
        _ <- liftEffect $ P.mark "test-mark" Nothing
        _ <- liftEffect $ P.measure "test-measure" Nothing
        entries <- liftEffect P.getEntries
        entries `shouldSatisfy` \es -> 
          length es == 2 &&
          map _.name es == ["test-mark", "test-measure"]

      it "getEntriesByName should return matching entries" do
        _ <- liftEffect $ P.clearMarks Nothing
        _ <- liftEffect $ P.mark "test-mark" Nothing
        _ <- liftEffect $ P.mark "test-mark" Nothing
        entries <- liftEffect $ P.getEntriesByName "test-mark"
        entries `shouldSatisfy` \es ->
          length es == 2 &&
          all (\e -> e.name == "test-mark") es

      it "getEntriesByType should return entries of specified type" do
        _ <- liftEffect $ P.clearMarks Nothing
        _ <- liftEffect $ P.mark "test-mark" Nothing
        _ <- liftEffect $ P.measure "test-measure" Nothing
        entries <- liftEffect $ P.getEntriesByType "mark"
        entries `shouldSatisfy` \es ->
          length es == 1 &&
          all (\e -> e.entryType == "mark") es

main :: Effect Unit
main = runSpecAndExitProcess [consoleReporter] spec
