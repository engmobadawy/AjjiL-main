//  LifeCare
//
//AuthDependancy.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation

extension DependencyContainer {
    class AuthDependency {

      static let shared = AuthDependency()

        // Repositories
        private(set) lazy var authRepository: AuthRepository = AuthRepositoryImp(networkService: DependencyContainer.shared.networkService)

        // SignUp
        private(set) lazy var signUpUseCase: SignUpUseCase = SignUpUseCase(authRepo: authRepository)
        private(set) lazy var signUpViewModel: SignUpViewModel = SignUpViewModel(signUpUseCase: signUpUseCase, userValidationUseCase: ValidationDependency.shared.userValidationUseCase)

        // Login
        private(set) lazy var loginUseCase: LoginUseCase = LoginUseCase(authRepo: authRepository)
        private(set) lazy var loginViewModel: LoginViewModel = LoginViewModel(loginUseCase: loginUseCase, userDataUseCase: UserTokenDependency.shared.userDataUseCase, userValidationUseCase: ValidationDependency.shared.userValidationUseCase, sendCodeUseCase: sendOTPUseCase)

//       forget password
      private(set) lazy var sendOTPUseCase: SendOTPUseCase = SendOTPUseCase(authRepo: authRepository)
      private(set) lazy var forgetViewModel: ForgetPasswordViewModel = ForgetPasswordViewModel(/*sendCodeUseCase: sendOTPUseCase,*/ userValidationUseCase: ValidationDependency.shared.userValidationUseCase)

      // OTP
//      private(set) lazy var verifyCodeUseCase: VerifyCodeUseCase = VerifyCodeUseCase(authRepo: authRepository)
//      private(set) lazy var verifyEmailUseCase: VerifyEmailUseCase = VerifyEmailUseCase(authRepo: authRepository)
//      private(set) lazy var otpViewModel: OTPViewModel = OTPViewModel(verifyEmailUseCase: verifyEmailUseCase, verifyOTPUseCase: verifyCodeUseCase, userValidationUseCase: ValidationDependency.shared.userValidationUseCase, userDataUseCase: UserTokenDependency.shared.userDataUseCase)

        
       // Forget Password
      private(set) lazy var forgetPasswordUseCase: ForgetPasswordUseCase = ForgetPasswordUseCase(authRepo: authRepository)
//      private(set) lazy var resetNewPasswordViewModel: NewPasswordViewModel = NewPasswordViewModel(forgetPasswordUseCase: forgetPasswordUseCase, userValidationUseCase: ValidationDependency.shared.userValidationUseCase, userDataUseCase: UserTokenDependency.shared.userDataUseCase)
    }
}
