//
//  LoginView.swift
//  ClassManager
//
//  Created by 김남건 on 2022/11/17.
//

import SwiftUI

struct LoginView: View {
    @State private var emailInput = ""
    @State private var passwordInput = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Image("Logo")
                .resizable()
                .frame(width: 151, height: 151)
                .padding(.bottom, 27)
            
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("환영합니다.")
                    HStack(spacing: 0) {
                        Text("번트 매니저")
                            .foregroundColor(.accent)
                        Text("에 로그인해주세요.")
                    }
                }
                .font(.system(size: 17, weight: .medium))
                Spacer()
            }
            .padding(.bottom, 27)
            
            VStack(spacing: 18) {
                LoginTextField(placeHolder: "이메일을 입력하세요.", isPassword: false, text: $emailInput)
                LoginTextField(placeHolder: "비밀번호를 입력하세요.", isPassword: true, text: $passwordInput)
            }
            .font(.system(size: 15))
            .padding(.bottom, 131)
            
            Button {
                // TODO: 로그인 로직
            } label: {
                Text("로그인")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .foregroundColor(.black)
                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.accent))
                    .padding(.bottom, 19)
                    
            }

        }
        .padding(.horizontal, 20)
    }
}

struct LoginTextField: View {
    let placeHolder: String
    let isPassword: Bool
    @Binding var text: String
    
    var body: some View {
        Group {
            if isPassword {
                SecureField(placeHolder, text: $text)
            } else {
                TextField(placeHolder, text: $text)
            }
        }
        .textInputAutocapitalization(.none)
        .padding(15)
        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color("ToastBackground")))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
