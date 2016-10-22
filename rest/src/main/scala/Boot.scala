import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.Http.ServerBinding
import akka.stream.ActorMaterializer

import scala.concurrent.Future

/**
  * Created by ty on 10/22/16.
  */

object Boot extends PavlovService with App{
  implicit val system = ActorSystem()
  implicit val materializer = ActorMaterializer()
  // needed for the future onFailure in the end
  implicit val executionContext = system.dispatcher

  // let's say the OS won't allow us to bind to 80.
  val (host, port) = ("localhost", 8080)
  val bindingFuture: Future[ServerBinding] =
    Http().bindAndHandle(this.route, host, port)

  bindingFuture.onFailure {
    case ex: Exception =>
      Console.err.println(ex, "Failed to bind to {}:{}!", host, port)
  }
}