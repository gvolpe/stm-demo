module Transfer where

import           System.IO
import           Control.Concurrent.STM

type Account = TVar Int

withdraw :: Account -> Int -> STM ()
withdraw acc amount = do
  bal <- readTVar acc
  writeTVar acc (bal - amount)

deposit :: Account -> Int -> STM ()
deposit acc amount = withdraw acc (-amount)

transfer :: Account -> Account -> Int -> IO ()
transfer from to amount = atomically
  (do
    deposit to amount
    withdraw from amount
  )

showAccount :: Account -> IO Int
showAccount acc = atomically (readTVar acc)
