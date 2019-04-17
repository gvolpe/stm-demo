module Transfer3
  ( main3
  )
where

import           Control.Monad                  ( when )
import           Control.Concurrent.STM
import           Control.Concurrent             ( forkIO
                                                , threadDelay
                                                )

{-
 -3rd example on 'choice' using `orElse`
 -(limitedWithdraw acc1 acc2 amt) withdraws amt from acc1,
 -if acc1 has enough money, otherwise from acc2.
 -If neither has enough, it retries.
 -}

type Account = TVar Int
type Name = String

withdraw :: Account -> Int -> STM ()
withdraw acc amount = do
  bal <- readTVar acc
  check (amount <= 0 || amount <= bal)
  writeTVar acc (bal - amount)

limitedWithdraw :: Account -> Account -> Int -> STM ()
limitedWithdraw acc1 acc2 amt =
  withdraw acc2 amt `orElse` withdraw acc2 amt

delayDeposit :: Name -> Account -> Int -> IO ()
delayDeposit name acc amount = do
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
  forkIO (delayDeposit "Right pocket" acc2 1)
  putStrLn "Withdrawing $101 from either pocket..."
  atomically (limitedWithdraw acc1 acc2 101)
  putStrLn "Successful withdrawal!"
  showAcc "Left pocket"  acc1
  showAcc "Right pocket" acc2
