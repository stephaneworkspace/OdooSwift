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
    
    func getWork(cred: Cred, date: Date) -> DayWork {
        let empty = ""
        let empty_day_work = DayWork.init(day: "", work: Array.init())
        let e_cstring = empty.cString(using: String.Encoding.utf8)
        let url = cred.url?.cString(using: String.Encoding.utf8) ?? e_cstring
        let db = cred.db?.cString(using: String.Encoding.utf8) ?? e_cstring
        let username = cred.username?.cString(using: String.Encoding.utf8) ?? e_cstring
        let password = cred.password?.cString(using: String.Encoding.utf8) ?? e_cstring
        let calendar = Calendar.current
        let year = Int32(calendar.component(.year, from: date))
        let month = UInt32(calendar.component(.month, from: date))
        let day = UInt32(calendar.component(.day, from: date))
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
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @State var day_work: DayWork = DayWork.init(day: "", work: Array.init())
    @State var workDay = Date()
    @State var odoo: Odoo = Odoo.init()
    @State var cred: Cred = Cred.init()
    @State var loading = false
    
    func format_program(activity: String, product_name: String ) -> some View {
        let s = String("["+activity+"] " + product_name);
        return Text(s)
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    func total() -> some View {
        var total_hour = 0.0;
        var total_chf = 0.0;
        for i in 0..<day_work.work!.count {
            total_hour += day_work.work![i].worked_hour ?? 0.0
            total_chf += day_work.work![i].price_raw ?? 0.0
        }
        let s = String(format: "%.2f %.2f CHF", total_hour, total_chf)
        return Text(s)
    }

    
    var body: some View {
        NavigationView {
        VStack {
            VStack/*(spacing: 1)*/ {
                List {
                    ForEach(0..<day_work.work!.count, id: \.self) { i in
                        Section {
                            HStack {
                                self.format_program(activity: day_work.work![i].activity ?? "", product_name: day_work.work![i].product_name ?? "").padding()
                                Spacer()
                                Text(String(format: "%.2f", day_work.work![i].worked_hour ?? 0.0)).padding()
                                Spacer()
                                //Text(String(format: "%.2f", day_work.work![i].product_list_price ?? 0.0)).padding()
                                Text(String(format: "CHF %.2f", day_work.work![i].price_raw ?? 0.0)).padding()
                            }
                            HStack {
                                Text(String(day_work.work![i].product_description_sale ?? "???")).padding()
                                Spacer()
                                Text(String(day_work.work![i].note ?? "???")).padding()
                            }
                        }//.background(i.isMultiple(of: 2) ?Color(.secondarySystemBackground): Color(.systemBackground))
                    }
                }.navigationBarTitle(day_work.day ?? "???").frame(minHeight: minRowHeight, maxHeight: minRowHeight * 6).listStyle(GroupedListStyle()).environment(\.horizontalSizeClass, .regular).padding(1).font(.system(size: 10))
                self.total()
                DatePicker(selection: $workDay, in: ...Date(), displayedComponents: .date){
                    EmptyView()
                }.labelsHidden().datePickerStyle(WheelDatePickerStyle()).clipped().environment(\.locale, Locale.init(identifier: "fr"))
                Button(action: {
                        day_work = odoo.getWork(cred: cred, date: workDay)
                    }) {
                        Text("This day")
                    }
                }
            }
        }.onAppear(perform: fetch)
    }
    
    private func fetch() {
        odoo = Odoo.init();
        cred = odoo.readJSONFromFile(fileName: "cred")!
        // print(cred?.username ?? "User is nil")
        day_work = odoo.getWork(cred: cred, date: workDay)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}