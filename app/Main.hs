module Main where

import           Control.Concurrent.STM
import           System.IO
import           Transfer

showBalance :: Account -> Account -> IO ()
showBalance from to = do
  x <- showAccount from
  y <- showAccount to
  putStrLn $ "FROM balance: $" <> show x
  putStrLn $ "TO balance: $" <> show y

main :: IO ()
main = do
  from <- atomically (newTVar 200)
  to   <- atomically (newTVar 200)
  showBalance from to
  putStrLn "Transfering $50 from 'FROM' to 'TO'"
  transfer from to 50
  putStrLn "Done!"
  showBalance from to
