//
//  ViewController.swift
//  YTDemo
//


import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tblVideos: UITableView!
    
    @IBOutlet weak var segDisplayedContent: UISegmentedControl!
    
    @IBOutlet weak var viewWait: UIView!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sortTheTable: UIBarButtonItem!
    
    
    var apiKey = "AIzaSyDVCSOoD7E6XOJBB5C0Ew0LxCUqdhY7om8"
    
    var desiredChannelsArray = ["PewDiePie", "Apple", "Google", "willunicycleforfood"]
    
    var channelIndex = 0
    
    var channelsDataArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    var videosArray: Array<Dictionary<NSObject, AnyObject>> = []
    
    var selectedVideoIndex: Int!
    
    var videoIDArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblVideos.delegate = self
        tblVideos.dataSource = self
        txtSearch.delegate = self
        tblVideos.isScrollEnabled = true


        getChannelDetails(useChannelIDParam: false)
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "idSeguePlayer" {
            let playerViewController = segue.destination as! PlayerViewController
            playerViewController.videoID = videosArray[selectedVideoIndex]["videoID" as NSObject] as? String
        }
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func changeContent(_ sender: Any) {
        tblVideos.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableViewRowAnimation.fade)
    }
    
    
    
    // MARK: UITableView method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segDisplayedContent.selectedSegmentIndex == 0 {
            return channelsDataArray.count
        }
        else {
            return videosArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
//        if(videoIDArraySorted.count == 6) {
//
//        }
        if segDisplayedContent.selectedSegmentIndex == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellChannel", for: indexPath)
            
            let channelTitleLabel = cell.viewWithTag(10) as! UILabel
            let channelDescriptionLabel = cell.viewWithTag(11) as! UILabel
            let thumbnailImageView = cell.viewWithTag(12) as! UIImageView
            
            let channelDetails = channelsDataArray[indexPath.row]
            channelTitleLabel.text = channelDetails["title" as NSObject] as? String
            channelDescriptionLabel.text = channelDetails["description" as NSObject] as? String
            thumbnailImageView.image = UIImage(data: NSData(contentsOf: NSURL(string: (channelDetails["thumbnail" as NSObject] as? String)!)! as URL)! as Data)

        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "idCellVideo", for: indexPath)
            
            let videoTitle = cell.viewWithTag(10) as! UILabel
            let videoThumbnail = cell.viewWithTag(11) as! UIImageView
            
            let videoDetails = videosArray[indexPath.row]
            videoTitle.text = videoDetails["title" as NSObject] as? String
            videoThumbnail.image = UIImage(data: NSData(contentsOf: NSURL(string: (videoDetails["thumbnail" as NSObject] as? String)!)! as URL)! as Data)
            videoIDArray.append(videosArray[indexPath.row]["videoID" as NSObject] as! String)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
   
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segDisplayedContent.selectedSegmentIndex == 0 {
            // In this case the channels are the displayed content.
            // The videos of the selected channel should be fetched and displayed.
            
            // Switch the segmented control to "Videos".
            segDisplayedContent.selectedSegmentIndex = 1
            tblVideos.reloadData()
            // Show the activity indicator.
            viewWait.isHidden = false
            
           
            // Remove all existing video details from the videosArray array.
            videosArray.removeAll(keepingCapacity: false)
            
            // Fetch the video details for the tapped channel.
            getVideosForChannelAtIndex(index: indexPath.row)
            
        }
        else {
            selectedVideoIndex = indexPath.row
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "idSeguePlayer", sender: self)
            }
        }
    }
    
    
    // MARK: UITextFieldDelegate method implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    viewWait.isHidden = false
    
    // Specify the search type (channel, video).
    var type = "channel"
    if segDisplayedContent.selectedSegmentIndex == 1 {
        type = "video"
        videosArray.removeAll(keepingCapacity: false)
    }
    
    // Form the request URL string.
        var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(String(describing: textField.text))&type=\(type)&key=\(apiKey)"
    urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

//    urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    
    // Create a NSURL object based on the above string.
    let targetURL = NSURL(string: urlString)
    
    // Get the results.
        performGetRequest(targetURL! as URL, completion: { (data, HTTPStatusCode, error) -> Void in
        if HTTPStatusCode == 200 && error == nil {
            // Convert the JSON data to a dictionary object.
            do {
                let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<NSObject, AnyObject>
                
                // Get all search result items ("items" array).
                let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items" as NSObject] as! Array<Dictionary<NSObject, AnyObject>>
                
                // Loop through all search results and keep just the necessary data.
                for i in 0...items.count {
                    let snippetDict = items[i]["snippet" as NSObject] as! Dictionary<NSObject, AnyObject>
                    
                    // Gather the proper data depending on whether we're searching for channels or for videos.
                    if self.segDisplayedContent.selectedSegmentIndex == 0 {
                        // Keep the channel ID.
                        self.desiredChannelsArray.append(snippetDict["channelId" as NSObject] as! String)
                    }
                    else {
                        // Create a new dictionary to store the video details.
                        var videoDetailsDict = Dictionary<NSObject, AnyObject>()
                        videoDetailsDict["title" as NSObject] = snippetDict["title" as NSObject]
                        videoDetailsDict["thumbnail" as NSObject] = ((snippetDict["thumbnails" as NSObject] as! Dictionary<NSObject, AnyObject>)["default" as NSObject] as! Dictionary<NSObject, AnyObject>)["url" as NSObject]
                        videoDetailsDict["videoID" as NSObject] = (items[i]["id" as NSObject] as! Dictionary<NSObject, AnyObject>)["videoId" as NSObject]
                        
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        self.videosArray.append(videoDetailsDict)
                        
                        // Reload the tableview.
                        self.tblVideos.reloadData()
                    }
                }
            } catch {
                print(error)
            }
            
            // Call the getChannelDetails(…) function to fetch the channels.
            if self.segDisplayedContent.selectedSegmentIndex == 0 {
                self.getChannelDetails(useChannelIDParam: true)
            }
            
        }
        else {
            print("HTTP Status Code = \(HTTPStatusCode)")
            print("Error while loading channel videos: \(String(describing: error))")
        }
        
        // Hide the activity indicator.
        self.viewWait.isHidden = true
    })
    
    
    return true
}
    
    
    // MARK: Custom method implementation
    
    func performGetRequest(_ targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: NSError?) -> Void) {
        var request = URLRequest(url: targetURL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfiguration)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async(execute: { () -> Void in
                completion(data, (response as! HTTPURLResponse).statusCode, error as NSError?)
            })
        }
        
        task.resume()
    }
    
    
    func getChannelDetails(useChannelIDParam: Bool) {
        var urlString: String!
        if !useChannelIDParam {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&forUsername=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        else {
            urlString = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails,snippet&id=\(desiredChannelsArray[channelIndex])&key=\(apiKey)"
        }
        
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL! as URL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                
                do {
                    // Convert the JSON data to a dictionary.
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get the first dictionary item from the returned items (usually there's just one item).
                    let items: AnyObject! = resultsDict["items" as NSObject]
                    let firstItemDict = (items as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>
                    
                    // Get the snippet dictionary that contains the desired data.
                    let snippetDict = firstItemDict["snippet" as NSObject] as! Dictionary<NSObject, AnyObject>
                    // Create a new dictionary to store only the values we care about.
                    var desiredValuesDict: Dictionary<NSObject, AnyObject> = Dictionary<NSObject, AnyObject>()
                    desiredValuesDict["title" as NSObject] = snippetDict["title" as NSObject]
                    desiredValuesDict["description" as NSObject] = snippetDict["description" as NSObject]
                    desiredValuesDict["thumbnail" as NSObject] = ((snippetDict["thumbnails" as NSObject] as! Dictionary<NSObject, AnyObject>)["default" as NSObject] as! Dictionary<NSObject, AnyObject>)["url" as NSObject]
                    
                    // Save the channel's uploaded videos playlist ID.
                    desiredValuesDict["playlistID" as NSObject] = ((firstItemDict["contentDetails" as NSObject] as! Dictionary<NSObject, AnyObject>)["relatedPlaylists" as NSObject] as! Dictionary<NSObject, AnyObject>)["uploads" as NSObject]
                    
                    
                    // Append the desiredValuesDict dictionary to the following array.
                    self.channelsDataArray.append(desiredValuesDict)
                    
                    
                    // Reload the tableview.
                    self.tblVideos.reloadData()
                    
                    // Load the next channel data (if exist).
                    self.channelIndex += 1
                    if self.channelIndex < self.desiredChannelsArray.count {
                        self.getChannelDetails(useChannelIDParam: useChannelIDParam)
                    }
                    else {
                        self.viewWait.isHidden = true
                    }
                } catch {
                    print(error)
                }
                
            } else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel details: \(String(describing: error))")
            }
        })
    }
    
   
    func getVideosForChannelAtIndex(index: Int!) {
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        let playlistID = channelsDataArray[index]["playlistID" as NSObject] as! String
        
        // Form the request URL string.
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistID)&key=\(apiKey)"
        
        // Create a NSURL object based on the above string.
        let targetURL = NSURL(string: urlString)
        
        // Fetch the playlist from Google.
        performGetRequest(targetURL! as URL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // Convert the JSON data into a dictionary.
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    // Get all playlist items ("items" array).
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items" as NSObject] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    // Use a loop to go through all video items.
                    for i in 0...items.count - 1 {
                        let playlistSnippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet" as NSObject] as! Dictionary<NSObject, AnyObject>
                        
                        // Initialize a new dictionary and store the data of interest.
                        var desiredPlaylistItemDataDict = Dictionary<NSObject, AnyObject>()
                        
                        desiredPlaylistItemDataDict["title" as NSObject] = playlistSnippetDict["title" as NSObject]
                        desiredPlaylistItemDataDict["thumbnail" as NSObject] = ((playlistSnippetDict["thumbnails" as NSObject] as! Dictionary<NSObject, AnyObject>)["default" as NSObject] as! Dictionary<NSObject, AnyObject>)["url" as NSObject]
                        desiredPlaylistItemDataDict["videoID" as NSObject] = (playlistSnippetDict["resourceId" as NSObject] as! Dictionary<NSObject, AnyObject>)["videoId" as NSObject]
                        
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        self.videosArray.append(desiredPlaylistItemDataDict)
                        
                        // Reload the tableview.
                        self.tblVideos.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
            else {
                print("HTTP Status Code = \(HTTPStatusCode)")
                print("Error while loading channel videos: \(String(describing: error))")
            }
            
            // Hide the activity indicator.
            self.viewWait.isHidden = true
        })
    }
    var statistics = Int()
    var tupleOfThem = [("", 0)]
    var videoIDArraySorted: [String] = []
    
    func returnStatistics(i: Int) -> Int{
            let urlString = "https://www.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics&id=\(videoIDArray[i])&key=\(apiKey)"
            let targetURL = NSURL(string: urlString)
            
            performGetRequest(targetURL! as URL, completion: { (data, HTTPStatusCode, error) -> Void in
                if HTTPStatusCode == 200 && error == nil {
                    do {
                        // Convert the JSON data into a dictionary.
                        let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<NSObject, AnyObject>
                        
                        // Get all playlist items ("items" array).
                        let item: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items" as NSObject] as! Array<Dictionary<NSObject, AnyObject>>
                        let playlistSnippetDict = (item[0] as Dictionary<NSObject, AnyObject>)["statistics" as NSObject] as! Dictionary<NSObject, AnyObject>
                        var desiredPlaylistItemDataDict = String()
                        desiredPlaylistItemDataDict = playlistSnippetDict["viewCount" as NSObject] as! String
                        
                        self.statistics = Int(desiredPlaylistItemDataDict)!
                        print(self.videoIDArray)
                        let temporaryTuple = (self.videoIDArray[i], Int(desiredPlaylistItemDataDict)!)
                        self.tupleOfThem.append(temporaryTuple)
                        if self.tupleOfThem.count == self.videoIDArray.count {
                            print(self.tupleOfThem)
                            self.tupleOfThem.sort{ $0.1 > $1.1 }
                            for i in 0...self.tupleOfThem.count - 1{
                                if self.tupleOfThem[i].1 != 0 {
                                    self.videoIDArraySorted.append(self.tupleOfThem[i].0)
                                }
                            }
                            print(self.videoIDArraySorted.count)
                                var videosArraySorted: Array<Dictionary<NSObject, AnyObject>> = []

                                for i in 0...self.videoIDArraySorted.count - 1 {
                                    for j in 0...self.videosArray.count - 1{
                                    if(self.videoIDArraySorted[i] == self.videosArray[j]["videoID" as NSObject] as! String ) {
                                    videosArraySorted.append(self.videosArray[j])
                                        }
                                    }
                                }
                                print(videosArraySorted)
                                self.videosArray = videosArraySorted
                                self.tblVideos.reloadData()
                            
                        }
                        
                    } catch {
                        print(error)
                    }
                }
                else {
                    print("HTTP Status Code = \(HTTPStatusCode)")
                    print("Error while loading channel videos: \(String(describing: error))")
                }
            })
        return statistics
    }
    
    @IBAction func sortTable(_ sender: Any) {
       
}
    @IBAction func sortButton(_ sender: Any) {
        print("HEYY")
        var stats:[Int] = []
        if videoIDArray.count == 5 {
        for i in 0...videoIDArray.count - 1 {
            stats.append(returnStatistics(i: i))
        }
        }

        
    }
    
}
