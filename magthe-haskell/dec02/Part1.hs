#! /usr/bin/env stack
{- stack runghc -}

module Main
  where

import Control.Arrow
import Data.List
import System.Environment

data Instruction = U | D | L | R
  deriving (Eq, Read, Show)

readInstructions :: FilePath -> IO [[Instruction]]
readInstructions fn = fmap (map parseLine) $ fmap lines $ readFile fn
  where
    parseLine = map (read . (:[]))

-- up - down - right - left
data Key = Nil | Key Char Key Key Key Key

keypadStart =
  let key1 = Key '1' Nil key4 key2 Nil
      key2 = Key '2' Nil key5 key3 key1
      key3 = Key '3' Nil key6 Nil key2
      key4 = Key '4' key1 key7 key5 Nil
      key5 = Key '5' key2 key8 key6 key4
      key6 = Key '6' key3 key9 Nil key5
      key7 = Key '7' key4 Nil key8 Nil
      key8 = Key '8' key5 Nil key9 key7
      key9 = Key '9' key6 Nil Nil key8
  in key5

step :: Key -> Instruction -> Key
step k@(Key _ Nil _ _ _) U = k
step (Key _ nk _ _ _) U = nk
step k@(Key _ _ Nil _ _) D = k
step (Key _ _ nk _ _) D = nk
step k@(Key _ _ _ Nil _) R = k
step (Key _ _ _ nk _) R = nk
step k@(Key _ _ _ _ Nil) L = k
step (Key _ _ _ _ nk) L = nk

keyChar :: Key -> Char
keyChar (Key s _ _ _ _) = s

getCode :: [[Instruction]] -> String
getCode = snd . mapAccumL getDigit keypadStart
  where
    getDigit kp = (id &&& keyChar) . foldl step kp

main :: IO ()
main = fmap head getArgs >>= readInstructions >>= putStrLn . getCode
