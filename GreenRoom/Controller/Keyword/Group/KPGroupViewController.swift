//
//  KPGroupViewController.swift
//  GreenRoom
//
//  Created by SangWoo's MacBook on 2022/09/01.
//

import UIKit

class KPGroupViewController: BaseViewController {
    //MARK: - Properties
    let viewModel: KeywordViewModel
    let groupView = GroupView().then {
        $0.groupCountingLabel.text = "그룹을 추가해주세요 :)"
    }
    
    //MARK: - Init
    init(viewModel: KeywordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configureNavigationBar()
    }
    
    //MARK: - Selector
    @objc func didTapScrap(_ sender: UIButton){
        print("didTapScrap")
    }
    
    override func setupBinding() {
        //그룹뷰 테이블 뷰 바인딩
    }
    
    //MARK: - ConfigureUI
    override func configureUI() {
        let keywordLabel = UILabel().then {
            $0.text = "키워드연습"
            $0.textColor = .mainColor
            $0.font = .sfPro(size: 20, family: .Bold)
            
            self.view.addSubview($0)
            $0.snp.makeConstraints{ make in
                make.leading.equalToSuperview().offset(38)
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(26)
            }
        }
        
        let findQuestionButton = ChevronButton(type: .system).then {
            $0.setConfigure(title: "면접 질문 찾기",
                            bgColor: .mainColor,
                            radius: 15)
            
            self.view.addSubview($0)
            $0.snp.makeConstraints{ make in
                make.leading.equalToSuperview().offset(38)
                make.trailing.equalToSuperview().offset(-38)
                make.top.equalTo(keywordLabel.snp.bottom).offset(33)
                make.height.equalTo(55)
            }
        }
        
        let participatedQuestionsButton = ChevronButton(type: .system).then {
            $0.setConfigure(title: "참여한 질문",
                            bgColor: .sub,
                            radius: 15)
        
            self.view.addSubview($0)
            $0.snp.makeConstraints{ make in
                make.leading.equalToSuperview().offset(38)
                make.trailing.equalToSuperview().offset(-38)
                make.top.equalTo(findQuestionButton.snp.bottom).offset(12)
                make.height.equalTo(55)
            }
        }
        
        self.view.addSubview(self.groupView)
        self.groupView.snp.makeConstraints{ make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(participatedQuestionsButton.snp.bottom).offset(40)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        iconView.image = UIImage(named: "GreenRoomIcon")?.withRenderingMode(.alwaysOriginal)
        iconView.contentMode = .scaleAspectFit
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iconView)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "bookmark"),
                style: .plain,
                target: self,
                action: #selector(self.didTapScrap(_:)))
        ]
        
        navigationController?.navigationBar.tintColor = .mainColor
    }
    
}
