//
//  LoginViewModel.swift
//  MVVM-withDelegate
//
//  Created by Jaimini Shah on 19/05/25.
//

import Foundation

protocol LoginViewModelDelegate: AnyObject {
    func didStartLoading()
    func didStopLoading()
    func didLoginSuccessfully()
    func didFailWithError(_ error: NetworkServiceError)
    func didFailWithValidationError(_ message: String)
}

final class LoginViewModel {
    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    private let validationService: ValidationServiceProtocol
    weak var delegate: LoginViewModelDelegate?
    private var loginData: LoginModel?
    
    // MARK: - Initialization
    init(networkService: NetworkServiceProtocol = NetworkService.shared,
         validationService: ValidationServiceProtocol = ValidationService.shared) {
        self.networkService = networkService
        self.validationService = validationService
    }
    
    // MARK: - Public Methods
    func login(username: String, password: String) {
        delegate?.didStartLoading()
        Task {
            do {
                let loginAPI = try await networkService.request(model: LoginModel.self, endPoint: EndPointItem.login(userName: username, password: password))
                self.loginData = loginAPI
                await MainActor.run {
                    self.delegate?.didStopLoading()
                    self.delegate?.didLoginSuccessfully()
                }
            } catch {
                await MainActor.run {
                    self.delegate?.didStopLoading()
                    if let networkError = error as? NetworkServiceError {
                        self.delegate?.didFailWithError(networkError)
                    } else {
                        self.delegate?.didFailWithError(NetworkServiceError.custom(error.localizedDescription))
                    }
                }
            }
        }
    }
}


