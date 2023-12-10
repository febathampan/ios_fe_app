//
//  NewsTableViewController.swift
//  Feba_Thampan_FE_8953147
//
//  Created by user234888 on 12/9/23.
//

import UIKit

class NewsTableViewController: UITableViewController {
   
    let newsAPIKey = "3086c5840a9e4847839135ccaa53ce87"

    // Data model to represent news information
        struct News {
            var title: String
            var description: String
            var author: String
            var source: String
        }
    // Define the NewsAPIResponse struct to match the NewsAPI JSON structure
    /* struct NewsAPIResponse: Decodable {
        let articles: [Article]

        struct Article: Decodable {
            let title: String
            let description: String?
            let author: String
            let source: Source

            struct Source: Decodable {
                let name: String
            }
        }
    }*/

    // MARK: - Welcome
    struct NewsAPIResponse: Codable {
        let articles: [Article]
    }

    // MARK: - Article
    struct Article: Codable {
        let source: Source
        let author: String?
        let title, description: String
    }

    // MARK: - Source
    struct Source: Codable {
        let name: String
    }
    
    
    
    

        // The selected city from the home page
        var selectedCity: String?

        // Array to store news data
        var newsData: [News] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "News"

            // Fetch news data when the view loads
            fetchNews()
        }

        // Function to fetch news data from NewsAPI.org
        func fetchNews() {
            guard let city = selectedCity else {
                return
            }

            let newsURL = "https://newsapi.org/v2/everything?q=\(city)&apiKey=\(newsAPIKey)"
            print(newsURL)

            guard let url = URL(string: newsURL) else {
                print("Invalid URL")
                return
            }

            // Create a data task to fetch news data
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching news: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    // Decode JSON data into a struct representing the NewsAPI response
                    let decoder = JSONDecoder()
                    let newsAPIResponse = try decoder.decode(NewsAPIResponse.self, from: data)

                    // Extract relevant information and populate the newsData array
                    self.newsData = newsAPIResponse.articles.map {
                        News(title: $0.title, description: $0.description, author: $0.author ?? "", source: $0.source.name)
                    }

                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }

            // Start the data task
            task.resume()
        }

        // MARK: - Table view data source

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print("NewsData")
            print(newsData.count)
            return newsData.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           /* let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
            let news = newsData[indexPath.row]

            // Configure the cell with news information
            cell.textLabel?.text = news.title
            cell.detailTextLabel?.text = "\(news.description)\nAuthor: \(news.author)\nSource: \(news.source)"
            cell.detailTextLabel?.numberOfLines = 0

            return cell*/
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
                let news = newsData[indexPath.row]
                
            
            // Configure the cell with news information
                cell.textLabel?.text = news.title
                cell.detailTextLabel?.text = "Author: \(news.author)\n\(news.source)"
                cell.detailTextLabel?.numberOfLines = 0

                return cell
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Adjust the cell height based on your design
        return 220.0
    }

}
