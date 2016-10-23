import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.Http.ServerBinding
import akka.stream.ActorMaterializer

import scala.concurrent.Future


/**
  * Created by ty on 10/22/16.
  */

object Boot extends PavlovService {
  def main(args: Array[String]): Unit = {
    println("Booting up!")
    val (host, port) = if (args.length == 3) (args(1), args(2).toInt) else ("localhost", 9090)
    implicit val system = ActorSystem()
    implicit val materializer = ActorMaterializer()
    // needed for the future onFailure in the end
    implicit val executionContext = system.dispatcher

    val bindingFuture: Future[ServerBinding] =
      Http().bindAndHandle(this.route, host, port)

    bindingFuture.onFailure {
      case ex: Exception =>
        Console.err.println(ex, "Failed to bind to {}:{}!", host, port)
    }
  }
}

object Foo {
  def main(args: Array[String]): Unit = {
    println("hello")
  }
}