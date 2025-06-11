//
//  importPaymentView.swift
//  GaGaISo
//
//  Created by marty.academy on 6/8/25.
//

import SwiftUI
import iamport_ios

struct IamportPaymentView: UIViewControllerRepresentable {
    let orderCode: String
    let totalPrice: Int
    let storeName: String
    let onCompletion: (IamportResponse?) -> Void
    
    func makeUIViewController(context: Context) -> IamportPaymentViewController {
        let viewController = IamportPaymentViewController()
        viewController.orderCode = orderCode
        viewController.totalPrice = totalPrice
        viewController.storeName = storeName
        viewController.onCompletion = onCompletion
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: IamportPaymentViewController, context: Context) {}
}

class IamportPaymentViewController: UIViewController {
    var orderCode: String = ""
    var totalPrice: Int = 0
    var storeName: String = ""
    var onCompletion: ((IamportResponse?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .pageSheet
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.requestIamportPayment()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // 아임포트 SDK 결제 요청
    func requestIamportPayment() {
        let userCode = IamportKey.USER_CODE
        let payment = createPaymentData()
        
        Iamport.shared.payment(
            viewController: self,
            userCode: userCode,
            payment: payment
        ) { [weak self] response in
            DispatchQueue.main.async {
                self?.onCompletion?(response)
            }
        }
    }
    
    // 아임포트 결제 데이터 생성
    func createPaymentData() -> IamportPayment {
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: orderCode, // 서버에서 받은 orderCode 사용
            amount: "\(totalPrice)"
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = "\(storeName) 주문"
            $0.buyer_name = "가가이소 사용자"
            $0.app_scheme = "gagaiso" // Info.plist의 URL Scheme과 일치해야 함
            
        }
    }
}
