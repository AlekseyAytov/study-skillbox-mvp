import UIKit

struct SearchResult: Codable {
    var searchType: String
    var expression: String
    var results: [SingleResult]
    var errorMessage: String
}

struct SingleResult: Codable {
    var id: String
    var resultType: String
    var image: String
    var title: String
    var description: String
}

var url = URL(string: "https://imdb-api.com/API/Search/k_ngzy512q")
url!.append(path: "spider")

let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
    guard let data = data, let response = response else { return }
    let result = parseDecoder(data: data)
    print(result.expression)
    print("----------------------------------")
    if let response = response as? HTTPURLResponse {
        print(response.statusCode)
    }
}
task.resume()

func parseSerialization(data: Data) -> SearchResult {
    let dict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
    
    let results = dict["results"] as! [[String: Any]]
    
    let object = SearchResult(
        searchType: dict["searchType"] as? String ?? "",
        expression: dict["expression"] as? String ?? "",
        results: Array(results.map{
            SingleResult(
                id: $0["id"] as? String ?? "",
                resultType: $0["resultType"] as? String ?? "",
                image: $0["image"] as? String ?? "",
                title: $0["title"] as? String ?? "",
                description: $0["description"] as? String ?? ""
            )}),
        errorMessage: dict["errorMessage"] as? String ?? ""
    )
    return object
}

func parseDecoder(data: Data) -> SearchResult {
    let decode = try! JSONDecoder().decode(SearchResult.self, from: data)
    return decode
}

