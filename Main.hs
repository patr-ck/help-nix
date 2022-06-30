{-# LANGUAGE OverloadedStrings #-}

module Main where

import Prelude

import Reflex.Dom

main :: IO ()
main = mainWidget $ display =<< count =<< button "ClickMe"
