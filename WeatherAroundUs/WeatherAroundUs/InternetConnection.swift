//
//  InternetSearch.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/11.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol InternetConnectionDelegate: class {
    optional func getSmallImageOfCity(image: UIImage, reference: String, cityName:String)
}

class InternetConnection: NSObject {
    
    var delegate : InternetConnectionDelegate?

    var passData: [String: AnyObject]!
    
    func getSmallPictureOfACity(location: CLLocationCoordinate2D, name: String){
        
        // avoid crash when there is space
        let city = name.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var req = Alamofire.request(.GET, NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(city)&location=\(location.latitude),\(location.longitude))&language=en&radius=5000&key=AIzaSyDHwdGU463x3_aJfg4TNWm0fijTjr9VEdg")!).responseJSON { (_, response, JSON, error) in

            if error == nil && JSON != nil {
                let result = JSON as! [String : AnyObject]
                // get a more detailed information    avoid conflict name
                var searchText = name
                
                if (result["predictions"] as! [AnyObject]).count > 0{
                    if(((result["predictions"] as! [AnyObject])[0] as! [String : AnyObject])["terms"] as! [AnyObject]).count == 1{
                        searchText = (((((result["predictions"] as! [AnyObject])[0] as! [String : AnyObject])["terms"] as! [AnyObject])[0] as! [String : AnyObject])["value"] as! String)
                    }else if (((result["predictions"] as! [AnyObject])[0] as! [String : AnyObject])["terms"] as! [AnyObject]).count >= 2{
                        searchText = (((((result["predictions"] as! [AnyObject])[0] as! [String : AnyObject])["terms"] as! [AnyObject])[0] as! [String : AnyObject])["value"] as! String) + " " + (((((result["predictions"] as! [AnyObject])[0] as! [String : AnyObject])["terms"] as! [AnyObject])[1] as! [String : AnyObject])["value"] as! String)
                    }
                }
                
                println(searchText)

                if !self.checkIfContainsChinese(searchText){
                    searchText = searchText.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    let url = NSURL(string: "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=\(searchText)&imgtype=photo&imgsz=xlarge%7Cxxlarge%7Chuge&imgc=color&hl=en")!
                    // request for the image
                    var req = Alamofire.request(.GET, url).responseJSON { (_, response, JSON, error) in
                        
                        if error == nil && JSON != nil {
                            let result = JSON as! [String : AnyObject]
                            
                            println(searchText)

                            for result in (result["responseData"] as! [String : AnyObject])["results"] as! [AnyObject]{
                                if result.description.rangeOfString("wikipedia") != nil{
                                    let tbUrl = (result as! [String : AnyObject])["tbUrl"] as! String
                                    let imageUrl = (result as! [String : AnyObject])["unescapedUrl"] as! String
                                    println(imageUrl)
                                    return
                                }
                            }
                            let tbUrl = (((result["responseData"] as! [String : AnyObject])["results"] as! [AnyObject])[0] as! [String : AnyObject])["tbUrl"] as! String
                            let imageUrl = (((result["responseData"] as! [String : AnyObject])["results"] as! [AnyObject])[0] as! [String : AnyObject])["unescapedUrl"] as! String
                            println(imageUrl)

                        }
                    }
                }else{
                    //has chinese
                }
                
                
              
            }
        
        }
    }
    
    func checkIfContainsChinese(str: String)->Bool{
        
        let nsstr = str as NSString
        let length = nsstr.length
        
        for var index = 0; index < length; index++ {
            var range = NSMakeRange(index, 1)
            var subString:NSString = nsstr.substringWithRange(range)
            var cString = subString.UTF8String
            if strlen(cString) == 3
            {
                return true
            }
        }
        return false
    }

}
/*
[responseStatus: 200, responseDetails: <null>, responseData: {
    results =     (
        {
            GsearchResultClass = GimageSearch;
            content = "Transportation[edit]";
            contentNoFormatting = "Transportation[edit]";
            height = 2304;
            imageId = "ANd9GcRekABJ9DZW6_5npnJHMK8eWGWM-ZsbPf4e-CItySjYz5hWVd0Eh2f1OgPZ";
            originalContextUrl = "http://en.wikipedia.org/wiki/Sunnyvale,_California";
            tbHeight = 100;
            tbUrl = "http://t3.gstatic.com/images?q=tbn:ANd9GcRekABJ9DZW6_5npnJHMK8eWGWM-ZsbPf4e-CItySjYz5hWVd0Eh2f1OgPZ";
            tbWidth = 150;
            title = "<b>Sunnyvale</b>, <b>California</b> - Wikipedia, the free encyclopedia";
            titleNoFormatting = "Sunnyvale, California - Wikipedia, the free encyclopedia";
            unescapedUrl = "http://upload.wikimedia.org/wikipedia/commons/9/9a/El_camino_and_mathilda.jpg";
            url = "http://upload.wikimedia.org/wikipedia/commons/9/9a/El_camino_and_mathilda.jpg";
            visibleUrl = "en.wikipedia.org";
            width = 3456;
        },
        {
            GsearchResultClass = GimageSearch;
            content = "63178_Sunriseof<b>Sunnyvale</b>_ ...";
            contentNoFormatting = "63178_SunriseofSunnyvale_ ...";
            height = 792;
            imageId = "ANd9GcSWSQPydIA290Qr8n7l721tFTg8j4Rz-GC1a8fsN4Gbl6iYY7bgp5vit1Y";
            originalContextUrl = "http://www.sunriseseniorliving.com/communities/sunrise-of-sunnyvale/overview.aspx";
            tbHeight = 103;
            tbUrl = "http://t0.gstatic.com/images?q=tbn:ANd9GcSWSQPydIA290Qr8n7l721tFTg8j4Rz-GC1a8fsN4Gbl6iYY7bgp5vit1Y";
            tbWidth = 150;
            title = "63178_Sunriseof<b>Sunnyvale</b>_ ...";
            titleNoFormatting = "63178_SunriseofSunnyvale_ ...";
            unescapedUrl = "http://www.sunriseseniorliving.com/~/media/New-Community-Images/CA/63178/63178_SunriseofSunnyvale_Sunnyvale_CA_Exterior.jpg";
            url = "http://www.sunriseseniorliving.com/~/media/New-Community-Images/CA/63178/63178_SunriseofSunnyvale_Sunnyvale_CA_Exterior.jpg";
            visibleUrl = "www.sunriseseniorliving.com";
            width = 1152;
        },
        {
            GsearchResultClass = GimageSearch;
            content = "Las-Palmas-Park-1.jpg";
            contentNoFormatting = "Las-Palmas-Park-1.jpg";
            height = 1200;
            imageId = "ANd9GcRivVoGEuFzZTgfBBOo3j2FAdgzg-Tvzz7-MURZzx802Sb9ek-1tx1iXu0";
            originalContextUrl = "http://www.stynesgroup.com/silicon-valley-real-estate/sunnyvale-real-estate/";
            tbHeight = 113;
            tbUrl = "http://t2.gstatic.com/images?q=tbn:ANd9GcRivVoGEuFzZTgfBBOo3j2FAdgzg-Tvzz7-MURZzx802Sb9ek-1tx1iXu0";
            tbWidth = 150;
            title = "Las-Palmas-Park-1.jpg";
            titleNoFormatting = "Las-Palmas-Park-1.jpg";
            unescapedUrl = "http://www.stynesgroup.com/wp-content/uploads/2009/02/Las-Palmas-Park-1.jpg";
            url = "http://www.stynesgroup.com/wp-content/uploads/2009/02/Las-Palmas-Park-1.jpg";
            visibleUrl = "www.stynesgroup.com";
            width = 1600;
        },
        {
            GsearchResultClass = GimageSearch;
            content = "<b>Sunnyvale CA</b>";
            contentNoFormatting = "Sunnyvale CA";
            height = 823;
            imageId = "ANd9GcRDupRNi32yreaV8z3LoqjPQoHtYgyK37_TEorE0YOuecT6AtyQEZyRUwKk";
            originalContextUrl = "http://home-design.science/apartments/apartments-for-rent-in-sunnyvale-ca-76-rentals.html";
            tbHeight = 95;
            tbUrl = "http://t2.gstatic.com/images?q=tbn:ANd9GcRDupRNi32yreaV8z3LoqjPQoHtYgyK37_TEorE0YOuecT6AtyQEZyRUwKk";
            tbWidth = 150;
            title = "Apartments For Rent In <b>Sunnyvale Ca</b> 76 Rentals | HDS - Home design <b>...</b>";
            titleNoFormatting = "Apartments For Rent In Sunnyvale Ca 76 Rentals | HDS - Home design ...";
            unescapedUrl = "http://thumbs.trulia-cdn.com/pictures/thumbs_6/ps.67/4/1/9/8/picture-uh=9d1c47ee75704533384dfebfe7a6f7b1-ps=41984ad5c2128b2d94e7bbbedd05a64-The-Meadows-1000-Escalon-Ave-Sunnyvale-CA-94085.jpg";
            url = "http://thumbs.trulia-cdn.com/pictures/thumbs_6/ps.67/4/1/9/8/picture-uh%3D9d1c47ee75704533384dfebfe7a6f7b1-ps%3D41984ad5c2128b2d94e7bbbedd05a64-The-Meadows-1000-Escalon-Ave-Sunnyvale-CA-94085.jpg";
            visibleUrl = "home-design.science";
            width = 1295;
        }
    );
}]
*/