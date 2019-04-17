package io.github.gvolpe

import scalaz.zio._
import scalaz.zio.clock.Clock
import scalaz.zio.duration._
import scalaz.zio.stm._
import transfer._

object transfer3 {

  def withdraw(account: Account, amount: Int): STM[Nothing, Unit] =
    account.ref.get.flatMap { balance =>
      STM.check(amount <= 0 || amount <= balance) *>
        account.ref.set(balance - amount)
    }

  def limitedWithdraw(acc1: Account, acc2: Account, amount: Int): STM[Nothing, Unit] =
    withdraw(acc1, amount).orElse(withdraw(acc2, amount))

  def delayDeposit(name: Name, account: Account, amount: Int): ZIO[Clock, Nothing, Unit] =
    for {
      _ <- ZIO.sleep(3.seconds)
      _ <- putStrLn("Depositing $" + amount + s" into ${name.value}")
      _ <- STM.atomically(account.ref.update(_ + amount))
    } yield ()

  def showAccount(name: Name, account: Account): UIO[Unit] =
    account.ref.get.commit.flatMap { balance =>
      putStrLn(name.value + ": $" + balance)
    }

  val leftPocket = Name("Left pocket")
  val rightPocket = Name("Right pocket")

  def main: ZIO[Clock, Nothing, Unit] =
    for {
      acc1 <- STM.atomically(TRef.make(100)).map(Account)
      acc2 <- STM.atomically(TRef.make(100)).map(Account)
      _    <- showAccount(leftPocket, acc1)
      _    <- showAccount(rightPocket, acc2)
      _    <- delayDeposit(rightPocket, acc2, 1).fork.void
      _    <- putStrLn("Withdrawing $101 from either pocket...")
      _    <- STM.atomically(limitedWithdraw(acc1, acc2, 101))
      _    <- putStrLn("Successful withdrawal!")
      _    <- showAccount(leftPocket, acc1)
      _    <- showAccount(rightPocket, acc2)
    } yield ()

}

