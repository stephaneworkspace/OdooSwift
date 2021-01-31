//
//  ContentView.swift
//  Odoo
//
//  Created by Stéphane Bressani on 31.01.21.
//

import SwiftUI
import Foundation

class Odoo {
    func HelloWorld() -> String {
        let text = "ok"
        let cstr = text.cString(using: String.Encoding.utf8)
        var res = ""
        if let res_cstr = odoo_swift(cstr) {
            res = String.init(cString: res_cstr)
            free_string(res_cstr)
        } else {
            res = "Returned string was null!"
        }
        return res
    }
    func getWork(cred: Cred) -> DayWork {
        let empty = ""
        let empty_day_work = DayWork.init(day: "", work: Array.init())
        let e_cstring = empty.cString(using: String.Encoding.utf8)
        let url = cred.url?.cString(using: String.Encoding.utf8) ?? e_cstring
        let db = cred.db?.cString(using: String.Encoding.utf8) ?? e_cstring
        let username = cred.username?.cString(using: String.Encoding.utf8) ?? e_cstring
        let password = cred.password?.cString(using: String.Encoding.utf8) ?? e_cstring
        let year = 2021 as Int32
        let month = 01 as UInt32
        let day = 22 as UInt32
        var res = ""
        if let res_cstr = get_work(url, db, username, password, year, month, day) {
            res = String.init(cString: res_cstr)
            free_string(res_cstr)
        } else {
            res = "{}"
        }
        var json: DayWork?;
        let decoder = JSONDecoder();
        let jsonData = res.data(using: String.Encoding.utf8)
        do {
            json = try decoder.decode(DayWork.self, from: jsonData!)
        } catch {
            debugPrint("Error parsing json odoo work hour")
        }
        return json ?? empty_day_work
    }
    
    func readJSONFromFile(fileName: String) -> Cred? {
        var json: Cred?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                // parse JSON
                let decoder = JSONDecoder();
                do {
                    json = try decoder.decode(Cred.self, from: data)
                    print(json?.username ?? "User is nil")
                } catch {
                    debugPrint("Error parsing json")
                }
            } catch {
                // Handle error here
                print("Error loading file")
            }
        }
        return json
    }
}

struct ContentView: View {
    @State var day_work: DayWork = DayWork.init(day: "", work: Array.init())
    var body: some View {
        VStack {
            ForEach(0 ..< day_work.work!.count, id: \.self) {
                i in HStack {
                    Text("\(day_work.work![i].activity ?? "???")")
                }
            }
        Text("My Odoo")
            .padding()
            Button(action: {
                let odoo = Odoo.init();

                let cred = odoo.readJSONFromFile(fileName: "cred");
                // print(cred?.username ?? "User is nil")
                day_work = odoo.getWork(cred: cred!) // TODO safe
                //string = odoo.HelloWorld()
            }) {
                Text("This day")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
