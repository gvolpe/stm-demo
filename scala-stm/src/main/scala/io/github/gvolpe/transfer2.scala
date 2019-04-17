package io.github.gvolpe

import scalaz.zio._
import scalaz.zio.clock.Clock
import scalaz.zio.duration._
import scalaz.zio.stm._
import transfer._

object transfer2 {

  def withdraw(account: Account, amount: Int): STM[Nothing, Unit] =
    account.ref.get.flatMap { balance =>
      STM.check(amount <= 0 || amount <= balance) *>
        account.ref.set(balance - amount)
    }

  def delayDeposit(account: Account, amount: Int): ZIO[Clock, Nothing, Unit] =
    for {
      _ <- putStrLn("Getting ready to deposit money...hunting through pockets...")
      _ <- ZIO.sleep(3.seconds)
      _ <- putStrLn("OK! Depositing now!")
      _ <- STM.atomically(account.ref.update(_ + amount))
    } yield ()

  def main: ZIO[Clock, Nothing, Unit] =
    for {
      from <- STM.atomically(TRef.make(100)).map(Account)
      _    <- delayDeposit(from, 1).fork.void
      _    <- putStrLn("Trying to withdraw money...")
      _    <- STM.atomically(withdraw(from, 101))
      _    <- putStrLn("Successful withdrawal!")
    } yield ()

}

