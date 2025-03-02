//
//  ClassCalendarView.swift
//  ClassManager
//
//  Created by Jiyoung Park on 2022/10/12.
//

import SwiftUI

struct ClassCalendarView: View {
    @State var isShowingAddSheet = false
    @State var isShowingSaveToast = false
    @State var isShowingLinkToast = false
    
    @State private var selectedDate = Date()
    @State private var classesToday = [Class]()
    
    let link: String
    let studioID: String
    
    @State var isMonthly = true
    @State var toolbarItemImageName = "note.text"
    
    var body: some View {
        NavigationView {
            ZStack {
                if isMonthly {
                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .padding(16)
                            .datePickerStyle(.graphical)
                            .accentColor(Color("Del"))
                            .background(RoundedRectangle(cornerRadius: 13).foregroundColor(Color("Box")))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)

                        ScrollView {
                            ForEach(classesToday, id: \.self.ID) { danceClass in
                                NavigationLink(destination: AttendanceView(currentClass: danceClass)) {
                                    ClassInfoBox(danceClass: danceClass)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .onAppear {
                            if let classes = Constant.shared.classes {
                                classesToday = classes.filter{ $0.date != nil && Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
                            }
                        }
                        Spacer()
                    }
                } else {
                    WeeklyCalendarView(date: $selectedDate, isShowingSheet: $isShowingAddSheet)
                }
            }
            .toast(message: "클래스가 추가되었습니다", isShowing: $isShowingSaveToast, duration: Toast.short)
            .toast(message: "신청폼 링크가 복사되었습니다", isShowing: $isShowingLinkToast, duration: Toast.short)
            .fullScreenCover(isPresented: $isShowingAddSheet) {
                AddClassView(isShowingAddSheet: $isShowingAddSheet, isShowingToast: $isShowingSaveToast, date: selectedDate)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("클래스 관리")
                        .font(.custom(FontManager.Montserrat.semibold, size: 15))
                        .accessibilityAddTraits(.isHeader)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        UIPasteboard.general.string = link
                        isShowingLinkToast.toggle()
                    } label: {
                        Image(systemName: "link")
                            .foregroundColor(.white)
                            .padding(.leading, 14)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isMonthly.toggle()
                        toolbarItemImageName = isMonthly ? "note.text" : "calendar"
                    } label: {
                        Image(systemName: toolbarItemImageName)
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(.trailing, 14)
                    }
                }
            }
        }
        .accentColor(.white)
        .onAppear {
            if let classes = Constant.shared.classes {
                classesToday = classes.filter{ $0.date != nil && Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
            }
        }
        .onChange(of: selectedDate) { date in
            if let classes = Constant.shared.classes {
                classesToday = classes.filter{ $0.date != nil && Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
            }
        }
        .onChange(of: isShowingAddSheet) { _ in
            if let classes = Constant.shared.classes {
                classesToday = classes.filter{ $0.date != nil && Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
            }
        }
        .onChange(of: Constant.shared.classes?.count) { _ in
            if let classes = Constant.shared.classes {
                classesToday = classes.filter{ $0.date != nil && Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
            }
        }
        .task {
            if let classes = Constant.shared.classes {
                classesToday = classes.filter{ $0.date != nil && Calendar.current.isDate($0.date!, inSameDayAs: selectedDate) }
            }
        }
    }
}

struct ClassCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        ClassCalendarView(link: "", studioID: "")
    }
}
