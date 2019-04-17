package io.github.gvolpe

import scalaz.zio._
import scalaz.zio.stm._
import transfer._

object transfer1 {

  def withdraw(account: Account, amount: Int): STM[Nothing, Unit] =
    account.ref.get.flatMap { balance =>
      STM.check(amount <= 0 || amount <= balance) *>
        account.ref.set(balance - amount)
    }

  def deposit(account: Account, amount: Int): STM[Nothing, Unit] =
    account.ref.get.flatMap { balance =>
      if (amount > 0) account.ref.set(balance + amount)
      else STM.unit
    }

  def transfer(from: Account, to: Account, amount: Int): UIO[Unit] =
    STM.atomically {
      deposit(to, amount) *> withdraw(from, amount)
    }

  def showAccount(account: Account): UIO[Int] =
    account.ref.get.commit

  def showBalance(from: Account, to: Account): UIO[Unit] =
    for {
      x <- showAccount(from)
      y <- showAccount(to)
      _ <- putStrLn("FROM balance: $" + x)
      _ <- putStrLn("TO balance: $" + y)
    } yield ()

  def main: UIO[Unit] =
    for {
      from <- STM.atomically(TRef.make(200)).map(Account)
      to   <- STM.atomically(TRef.make(200)).map(Account)
      _    <- showBalance(from, to)
      _    <- putStrLn("Transfering $50 from 'FROM' to 'TO'")
      _    <- transfer(from, to, 50)
      _    <- putStrLn("Done!")
      _    <- showBalance(from, to)
    } yield ()

}

