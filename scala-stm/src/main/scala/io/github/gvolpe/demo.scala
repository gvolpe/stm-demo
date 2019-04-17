package io.github.gvolpe

import scalaz.zio._
import scalaz.zio.clock.Clock
import scalaz.zio.stm._
import transfer._

object demo extends App {

  implicit val runtime: Runtime[Environment] = this

  def run(args: List[String]): ZIO[Clock, Nothing, Int] =
    transfer3.main.map(_ => 0)

  //def run(args: List[String]): UIO[Int] =
    //transfer1.main.map(_ => 0)

}

object transfer {
  def putStrLn[A](a: A): UIO[Unit] = UIO(println(a))

  case class Account(ref: TRef[Int]) extends AnyVal
  case class Name(value: String) extends AnyVal
}

