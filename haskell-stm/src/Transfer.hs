module Transfer where

import           Control.Monad                  ( when )
import           Control.Concurrent.STM
import           Control.Concurrent             ( forkIO
                                                , threadDelay
                                                )

type Account = TVar Int
type Name = String

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

{- 2nd example showing a late deposit and a withdrawal waiting for the amount to be present -}

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

{-
 -3rd example on 'choice' using `orElse`
 -(limitedWithdraw acc1 acc2 amt) withdraws amt from acc1,
 -if acc1 has enough money, otherwise from acc2.
 -If neither has enough, it retries.
 -}

limitedWithdraw :: Account -> Account -> Int -> STM ()
limitedWithdraw acc1 acc2 amt = orElse (withdraw acc1 amt) (withdraw acc2 amt)

delayDeposit2 :: Name -> Account -> Int -> IO ()
delayDeposit2 name acc amount = do
  threadDelay 3000000
  putStrLn ("Depositing $" ++ show amount ++ " into " ++ name)
  atomically
    (do
      bal <- readTVar acc
      writeTVar acc (bal + amount)
    )

showAcc :: Name -> Account -> IO ()
showAcc name acc = do
  bal <- readTVarIO acc
  putStrLn (name ++ ": $" ++ show bal)

main3 = do
  acc1 <- atomically (newTVar 100)
  acc2 <- atomically (newTVar 100)
  showAcc "Left pocket"  acc1
  showAcc "Right pocket" acc2
  forkIO (delayDeposit2 "Right pocket" acc2 1)
  putStrLn "Withdrawing $101 from either pocket..."
  atomically (limitedWithdraw acc1 acc2 101)
  putStrLn "Successful withdrawal!"
  showAcc "Left pocket"  acc1
  showAcc "Right pocket" acc2
