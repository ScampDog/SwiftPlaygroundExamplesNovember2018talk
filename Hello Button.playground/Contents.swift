import UIKit
import PlaygroundSupport

class ViewController: UIViewController {
    
    var aButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hello Button"
        view.backgroundColor =  .blue
        
        aButton = UIButton(type: .system)
        aButton.setTitle("Change background", for: .normal)
        aButton.backgroundColor =  .white
        aButton.layer.borderColor = UIColor.gray.cgColor
        aButton.layer.borderWidth = 2
        aButton.layer.cornerRadius = 5
        view.addSubview(aButton)
        let buttonWidth = 200
        let x = 250 - buttonWidth/2
        aButton.frame = CGRect(x: x, y: 200, width: 200, height: 100)
        
        aButton.addTarget(self, action: #selector(ViewController.changeBackgroundColor), for: .touchUpInside)
        
    }
    
    @objc func changeBackgroundColor(){
        if view.backgroundColor == .blue {
            view.backgroundColor = .green
        } else {
            view.backgroundColor = .blue
        }
    }
}

let controller = ViewController()

PlaygroundPage.current.liveView = UINavigationController(rootViewController: controller)
