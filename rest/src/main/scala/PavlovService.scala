import akka.http.scaladsl.server.Route
import akka.http.scaladsl.server.Directives.{get, complete, path}

trait PavlovService {
  def route:Route = get {
    path("ping") {
      complete("pong")
    }
  }

}