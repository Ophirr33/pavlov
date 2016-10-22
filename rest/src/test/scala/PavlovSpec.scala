import org.scalatest.{ Matchers, WordSpec }
import akka.http.scaladsl.model.StatusCodes
import akka.http.scaladsl.testkit.ScalatestRouteTest

/**
  * Created by ty on 10/22/16.
  */
class PavlovSpec extends WordSpec with Matchers with ScalatestRouteTest with PavlovService {

  "Pavlov" should {
    "return a ping" in {
      Get("/ping") ~> route ~> check {
        println(response)
      }
    }
  }

}
