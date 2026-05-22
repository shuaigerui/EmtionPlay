//
//  EP_NetworkTool.swift
//  EmtionPlayRp
//
//  Created by  mac on 2026/5/22.
//

import Foundation
import SVProgressHUD

let URL_BASE = "https://api.fiveukmedia.xyz"

enum EP_NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case emptyData
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .invalidResponse:
            return "Invalid server response."
        case .httpStatus(let code):
            return "Request failed (\(code))."
        case .emptyData:
            return "Empty response data."
        case .invalidJSON:
            return "Failed to parse response."
        }
    }
}

/// 网络请求工具
final class EP_NetworkTool {

    static let shared = EP_NetworkTool()

    private let timeout: TimeInterval = 15
    private let huaPlPath = "/hua/pl"
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        session = URLSession(configuration: configuration)
    }

    /// GET `/hua/pl?lan=xx`
    /// - Parameters:
    ///   - lan: 语言参数，默认取 `LanguageManager` 当前语言
    ///   - showsHUD: 是否显示加载 HUD，默认 `true`；传 `false` 则不 show/dismiss
    ///   - completion: 主线程回调，成功时为 JSON 对象（字典或数组）
    func fetchHuaPl(
        lan: String? = nil,
        showsHUD: Bool = true,
        completion: @escaping (Result<Any, Error>) -> Void
    ) {
        let language = "https://www.youtube.com/shorts/Edtnh6iwglw"

        if showsHUD {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }

        guard let url = buildHuaPlURL(lan: language) else {
            finishOnMain(showsHUD: showsHUD, with: .failure(EP_NetworkError.invalidURL), completion: completion)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }

            if let error {
                self.finishOnMain(showsHUD: showsHUD, with: .failure(error), completion: completion)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                self.finishOnMain(showsHUD: showsHUD, with: .failure(EP_NetworkError.invalidResponse), completion: completion)
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                self.finishOnMain(
                    showsHUD: showsHUD,
                    with: .failure(EP_NetworkError.httpStatus(httpResponse.statusCode)),
                    completion: completion
                )
                return
            }

            guard let data, !data.isEmpty else {
                self.finishOnMain(showsHUD: showsHUD, with: .failure(EP_NetworkError.emptyData), completion: completion)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                self.finishOnMain(showsHUD: showsHUD, with: .success(json), completion: completion)
            } catch {
                self.finishOnMain(showsHUD: showsHUD, with: .failure(EP_NetworkError.invalidJSON), completion: completion)
            }
        }.resume()
    }

    // MARK: - Private

    private func buildHuaPlURL(lan: String) -> URL? {
        var components = URLComponents(string: URL_BASE + huaPlPath)
        components?.queryItems = [
            URLQueryItem(name: "lan", value: lan),
        ]
        return components?.url
    }

    private func finishOnMain(
        showsHUD: Bool,
        with result: Result<Any, Error>,
        completion: @escaping (Result<Any, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            if showsHUD {
                SVProgressHUD.dismiss()
            }
            completion(result)
        }
    }
}
