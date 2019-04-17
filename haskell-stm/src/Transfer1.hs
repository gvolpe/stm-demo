module Transfer1
  ( main1
  )
where

import           Control.Monad                  ( when )
import           Control.Concurrent.STM

type Account = TVar Int

withdraw :: Account -> Int -> STM ()
withdraw acc amount = do
  bal <- readTVar acc
  check (amount <= 0 || amount <= bal)
  writeTVar acc (bal - amount)

deposit :: Account -> Int -> STM ()
deposit acc amount = do
  bal <- readTVar acc
  when (amount > 0) $ writeTVar acc (bal + amount)

transfer :: Account -> Account -> Int -> IO ()
transfer from to amount = atomically
  (do
    deposit to amount
    withdraw from amount
  )

showAccount :: Account -> IO Int
showAccount = readTVarIO

showBalance :: Account -> Account -> IO ()
showBalance from to = do
  x <- showAccount from
  y <- showAccount to
  putStrLn $ "FROM balance: $" <> show x
  putStrLn $ "TO balance: $" <> show y

main1 = do
  from <- atomically (newTVar 200)
  to   <- atomically (newTVar 200)
  showBalance from to
  putStrLn "Transfering $50 from 'FROM' to 'TO'"
  transfer from to 50
  putStrLn "Done!"
  showBalance from to

