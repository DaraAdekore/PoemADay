//
//  ViewController.swift
//  PoemADay
//
//  Created by Dara on 2022-08-11.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var poemTitle: UILabel!
    @IBOutlet weak var authorImage: UIImageView!
    
    @IBOutlet weak var nextPoem: UIButton!
    @IBOutlet weak var poemView: UIView!
    @IBOutlet weak var textBody: UITextView!
    @IBOutlet weak var lastName: UILabel!
    var requestEndpoint = "https://poetrydb.org/random"
    var poems:Poems?
    let accessKey = "86BR-PI6jA3QbugU9EBaiIugnzDxx7MS1H9ejFAlVps"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task{
            await getPoem(completion:getPhoto)
        }
        
        self.authorImage.layer.cornerRadius = 15
        self.poemView.layer.cornerRadius = 10
        self.poemView.layer.shadowColor = UIColor.black.cgColor
        self.poemView.layer.shadowOpacity = 1
        self.poemView.layer.shadowOffset = .zero
        self.poemView.layer.shadowRadius = 10
        
        self.nextPoem.layer.cornerRadius = 10
        self.nextPoem.layer.shadowColor = UIColor.black.cgColor
        self.nextPoem.layer.shadowOpacity = 1
        self.nextPoem.layer.shadowOffset = .zero
        self.nextPoem.layer.shadowRadius = 5
        
    }
    
    @IBAction func newPoem(_ sender: Any) {
        Task{
            await getPoem(completion: getPhoto)
        }
        
    }
    
    var getPhoto: (Poems, _ accesKey:String, _ selfView:ViewController) -> Void = { poems , accessKey , selfView in
        
        let photoApi = "https://api.unsplash.com/search/photos/?client_id=\(accessKey)&page=1&query=\(poems[0].author.split(separator: " ").joined(separator: "%20"))"
        let url = URL(string:photoApi)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {
            data, response, error in
            
            guard let data = data else{
                return
            }
            
            do{
                let photosRes = try JSONDecoder().decode(Photos.self, from: data)
                let localImage:UIImage?
                localImage =  try UIImage(data: Data(contentsOf: URL(string: photosRes.results![Int.random(in: 0...photosRes.results!.count-1)].urls!.regular! )!))!
                DispatchQueue.main.async {
                    let nameArray = poems[0].author.split(separator: " ").map{String($0)}
                    selfView.firstName.text = nameArray[0]
                    if nameArray.count > 1 {
                        selfView.lastName.text = nameArray[nameArray.count-1]
                    } else{
                        selfView.lastName.text = ""
                    }
                    
                    selfView.poemTitle.text = poems[0].title
                    selfView.textBody.text = poems[0].lines.joined(separator: "\n")
                    selfView.authorImage.image = localImage
                    
                }
                
            }catch{
                print(error)
            }
            
        })
        task.resume()
    }
    
    func getPoem(completion: @escaping (Poems, _ accessKey:String, _ selfView:ViewController) -> Void) async {
        let url = URL(string:requestEndpoint)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {
            data, response, error in
            
            guard let data = data else{
                return
            }
            
            do{
                let jsonRes = try JSONDecoder().decode(Poems.self, from: data)
                completion(jsonRes, self.accessKey, self)
            }catch{
                print(error)
            }
            
        })
        task.resume()
        
    }
    
    struct Poem: Codable {
        var title, author: String
        var lines: [String]
        var linecount: String
    }
    
    typealias Poems = [Poem]
    
    struct Photos : Codable {
        var results: [Result]?
    }
    
    struct Result: Codable {
        var urls: URLS?
    }
    
    struct URLS: Codable {
        var regular: String?
        var full: String?
    }
    
}
