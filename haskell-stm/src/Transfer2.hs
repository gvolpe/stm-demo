module Transfer2
  ( main2
  )
where

import           Control.Monad                  ( when )
import           Control.Concurrent.STM
import           Control.Concurrent             ( forkIO
                                                , threadDelay
                                                )

{- 2nd example showing a late deposit and a withdrawal waiting for the amount to be present -}

type Account = TVar Int

withdraw :: Account -> Int -> STM ()
withdraw acc amount = do
  bal <- readTVar acc
  check (amount <= 0 || amount <= bal)
  writeTVar acc (bal - amount)

delayDeposit :: Account -> Int -> IO ()
delayDeposit acc amount = do
  putStrLn "Getting ready to deposit money...hunting through pockets..."
  threadDelay 3000000
  putStrLn "OK! Depositing now!"
  atomically
    (do
      bal <- readTVar acc
      writeTVar acc (bal + amount)
    )

main2 = do
  acc <- atomically (newTVar 100)
  forkIO (delayDeposit acc 1)
  putStrLn "Trying to withdraw money..."
  atomically (withdraw acc 101)
  putStrLn "Successful withdrawal!"

