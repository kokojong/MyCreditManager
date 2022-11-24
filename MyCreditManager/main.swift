//
//  main.swift
//  MyCreditManager
//
//  Created by kokojong on 2022/11/23.
//

import Foundation

var db: [String: Grades] = [:] // [ 이름 : [ 과목명 : 평점 ] ]

private func showIntroMsg() {
    print("원하는 기능을 입력해주세요\n1: 학생추가, 2: 학생삭제, 3: 성적추가(변경), 4: 성적삭제, 5: 평점 보기, X: 종료")
    guard let menu = menuOptions(rawValue: readLine() ?? "") else { return showInputErrorMsg() }
    getMenuOptions(menu)
}

private func getMenuOptions(_ menu: menuOptions) {
    switch menu {
    case .registerStudent:
        registerStudent()
    case .deleteStudent:
        deleteStudent()
    case .updateGrade:
        updateGrade()
    case .deleteGrade:
        deleteGrade()
    case .getGrade:
        getGrade()
    case .quit:
        quit()
    }
}

// MARK: main func
private func registerStudent() {
    print("추가할 학생의 이름을 입력해주세요.")
    guard let name = readLine() else { return }
    if name.trimmingCharacters(in: .whitespaces).count > 0  {
        if db[name] == nil {
            db[name] = Grades()  // 새로 등록
            print("\(name) 학생을 추가했습니다.")
        } else {
            print("\(name)은 이미 존재하는 학생입니다. 추가하지 않습니다")
        }
    } else { // 공백으로만 이뤄진 이름
        showCommonErrorMsg()
    }
    showIntroMsg()
}

private func deleteStudent() {
    print("삭제할 학생의 이름을 입력해주세요.")
    guard let name = readLine() else { return }
    if db[name] != nil {
        db[name] = nil // db 갱신
        print("\(name) 학생을 삭제했습니다.")
    } else {
        print("\(name) 학생을 찾지 못했습니다.")
    }
    showIntroMsg()
}

private func updateGrade() {
    print("성적을 추가할 학생의 이름, 과목 이름, 성적(A+, A, F 등)을 띄어쓰기로 구분하여 차례로 작성해주세요. \n입력예) kokojong Swift F \n만약 학생의 성적 중 해당 과목이 존재하면 기존 점수가 갱신 됩니다.")
    guard let input = readLine() else { return }
    let inputInfo = input.split(separator: " ").map { String($0) }
    if inputInfo.count != 3 {
        showCommonErrorMsg()
    } else {
        let name = inputInfo[0]
        let subject = inputInfo[1]
        let grade = inputInfo[2]
        if checkToUpdateGrade(name: inputInfo[0], subject: inputInfo[1], grade: inputInfo[2]) {
            let grades = db[name]! // 앞서서 nil 체크 완료
            db[name]!.grades[subject] = Grade(rawValue: grade)
            print("\(name) 학생의 \(subject) 과목이 \(grade)로 추가(변경) 되었습니다.")
//            print("db is", db)
        }
    }
    showIntroMsg()
}

private func deleteGrade() {
    print("성적을 삭제할 학생의 이름, 과목 이름을 띄어쓰기로 구분하여 차례로 작성해주세요. \n입력예) kokojong Swift")
    guard let input = readLine() else { return }
    let inputInfo = input.split(separator: " ").map { String($0) }
    if inputInfo.count != 2 {
        showCommonErrorMsg()
    } else {
        let name = inputInfo[0]
        let subject = inputInfo[1]
        if checkIsStudentExist(name: name) {
            let grades = db[name]!
            if grades.grades.keys.contains(subject) {
                db[name]!.grades[subject] = nil
                print("\(name) 학생의 \(subject) 과목의 성적이 삭제 되었습니다.")
//                print("db is", db)
            } else {
                showCommonErrorMsg()
            }
        }
    }
    showIntroMsg()
}

private func getGrade() {
    print("평점을 알고싶은 학생의 이름을 입력해주세요")
    guard let name = readLine() else { return }
    if name.trimmingCharacters(in: .whitespaces).count > 0 {
        if db[name] != nil {
            let grades = db[name]!.grades
            var totalPoint: Double = 0
            grades.forEach { key, value in
                print("\(key): \(value.rawValue)")
                totalPoint += convertGradeToPoint(grade: value)
            }
            var avg: Double = totalPoint / Double(grades.keys.count)
            print("평점 : \(String(format: "%.2f", avg))")
        } else {
            print("\(name) 학생을 찾지 못했습니다.")
        }
    } else {
        showCommonErrorMsg()
    }
    showIntroMsg()
}

private func quit() {
    print("프로그램을 종료합니다...")
}

// MARK: sub func
private func checkToUpdateGrade(name: String, subject: String, grade: String) -> Bool {
    guard let grade = Grade(rawValue: grade) else {
        showCommonErrorMsg()
        return false
    }
    
    if checkIsStudentExist(name: name) == false {
        print("\(name) 학생을 찾을 수 없습니다.")
        return false
    }
    return true
}

func checkIsStudentExist(name: String) -> Bool {
    if db[name] == nil { return false }
    return true
}

// errorMsg
func showInputErrorMsg() {
    print("뭔가 입력이 잘못되었습니다. 1~5사이의 숫자 혹은 X를 입력해주세요.")
    showIntroMsg() // 입력 메세지 출력
}

func showCommonErrorMsg() {
    print("입력이 잘못되었습니다. 다시 확인해주세요.")
}

// MARK: model
struct Grades {
    var grades: [String: Grade] = [:]
}

enum menuOptions: String {
    case registerStudent = "1"
    case deleteStudent = "2"
    case updateGrade = "3"
    case deleteGrade = "4"
    case getGrade = "5"
    case quit = "X"
}

enum Grade: String {
    case aPlus = "A+"
    case a = "A"
    case bPlus = "B+"
    case b = "B"
    case cPlus = "C+"
    case c = "C"
    case dPlus = "D+"
    case d = "D"
    case f = "F"
}

func convertGradeToPoint(grade: Grade) -> Double {
    switch grade {
    case .aPlus:
        return 4.5
    case .a:
        return 4.0
    case .bPlus:
        return 3.5
    case .b:
        return 3.0
    case .cPlus:
        return 2.5
    case .c:
        return 2.0
    case .dPlus:
        return 1.5
    case .d:
        return 1.0
    case .f:
        return 0.0
    }
}

// 실행
showIntroMsg()
